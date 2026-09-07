#
# SteamMachine UM790
#
# devices.serial_manager
#
# Abre el puerto serie, lee/envia mensajes JSON (uno por linea, terminado en LF),
# con reconexion automatica. Sigue 04_Communication_Protocol.md.
#
# Incluye tambien SimulatedSerialManager: mismo interfaz publico, pero sin
# hardware real. Permite desarrollar y probar el Core mientras el firmware
# del ESP32 todavia no existe (ver config.serial.simulate).
#

from __future__ import annotations

import json
import threading
import time
from queue import Empty, Queue
from typing import Callable, Optional

from core.logger import get_logger

logger = get_logger()


class SerialManager:
    """
    Gestiona la comunicacion serie real (USB) entre el PC y el ESP32.
    """

    def __init__(
        self,
        port: str = "auto",
        baudrate: int = 115200,
        vid_pid: Optional[list[str]] = None,
        reconnect_interval: int = 3,
        on_message: Optional[Callable[[dict], None]] = None,
    ):
        self._port_setting = port
        self._baudrate = baudrate
        self._vid_pid = set(v.upper() for v in (vid_pid or []))
        self._reconnect_interval = reconnect_interval
        self._on_message = on_message

        self._serial = None
        self._stop_event = threading.Event()
        self._thread: Optional[threading.Thread] = None

    # -- API publica -------------------------------------------------

    def connect(self) -> bool:
        if self.is_connected():
            return True
        opened_now = self._open_port()

        # El hilo de lectura arranca siempre, haya tenido éxito o no este
        # intento concreto — _read_loop() ya sabe reintentar por su
        # cuenta mientras no este conectado (ver mas abajo). Sin esto, si
        # el primer intento fallaba (p.ej. el ESP32 tarda en aparecer
        # tras un arranque con systemd), Application.initialize() decia
        # "reintentando en segundo plano" pero ningun hilo llegaba a
        # arrancar nunca — confirmado en hardware real (2026-09-06).
        if not self._thread or not self._thread.is_alive():
            self._stop_event.clear()
            self._thread = threading.Thread(target=self._read_loop, daemon=True)
            self._thread.start()

        return opened_now

    def _open_port(self) -> bool:
        """
        Abre el puerto serie, sin tocar el hilo de lectura. Separado de
        connect() para que _read_loop() pueda reabrir el puerto tras una
        desconexion (reintento automatico) SIN arrancar un hilo nuevo —
        connect() siempre crea+arranca un threading.Thread, así que
        llamarlo desde dentro de _read_loop en cada reintento iba
        acumulando un hilo nuevo por cada ciclo de desconexion/reconexion,
        sin cerrar nunca los anteriores (confirmado en revisión de código,
        2026-09-06, al corregir el fallo de autoarranque con systemd).
        """
        import serial  # pyserial

        port = self._resolve_port()
        if not port:
            logger.warning("No se encontro ningun ESP32 conectado por USB")
            return False

        try:
            self._serial = serial.Serial(port, self._baudrate, timeout=1)
            logger.info("Conectado al ESP32 en {} @ {} bps", port, self._baudrate)
            return True
        except Exception as e:
            logger.error("No se pudo abrir el puerto {}: {}", port, e)
            self._serial = None
            return False

    def disconnect(self) -> None:
        self._stop_event.set()
        self._close_serial()
        if self._thread and threading.current_thread() is not self._thread:
            self._thread.join(timeout=2)

    def _close_serial(self) -> None:
        """
        Cierra el puerto serie sin tocar _stop_event ni el hilo — para
        usar dentro de _read_loop tras un error de lectura, donde
        queremos reintentar la conexion, no detener el hilo del todo
        (eso es lo que hace disconnect(), pensado para un cierre
        intencional desde fuera del hilo).
        """
        if self._serial:
            try:
                self._serial.close()
            except Exception:
                pass
        self._serial = None

    def send(self, message: dict) -> bool:
        if not self.is_connected():
            logger.warning("send() ignorado: puerto serie no conectado ({})", message)
            return False
        try:
            line = json.dumps(message, ensure_ascii=False) + "\n"
            self._serial.write(line.encode("utf-8"))
            return True
        except Exception as e:
            logger.error("Error enviando por serie: {}", e)
            return False

    def is_connected(self) -> bool:
        return self._serial is not None and self._serial.is_open

    # -- Internos ------------------------------------------------------

    def _resolve_port(self) -> Optional[str]:
        import serial.tools.list_ports as list_ports

        if self._port_setting and self._port_setting != "auto":
            return self._port_setting

        for p in list_ports.comports():
            if p.vid is None or p.pid is None:
                continue
            id_str = f"{p.vid:04X}:{p.pid:04X}"
            if not self._vid_pid or id_str in self._vid_pid:
                return p.device
        return None

    def _read_loop(self) -> None:
        while not self._stop_event.is_set():
            try:
                if not self.is_connected():
                    time.sleep(self._reconnect_interval)
                    self._open_port()
                    continue

                raw = self._serial.readline()
                if not raw:
                    continue
                self._handle_line(raw)
            except Exception as e:
                logger.error("Error en el hilo de lectura serie: {}", e)
                # _close_serial(), no disconnect(): esto se ejecuta dentro
                # del propio hilo de lectura, y disconnect() está pensado
                # para un cierre intencional desde fuera de el (detiene el
                # hilo del todo). Aqui solo cerramos el puerto para que el
                # propio bucle reintente la conexion en la siguiente
                # vuelta, sin salir de _read_loop.
                self._close_serial()
                time.sleep(self._reconnect_interval)

    def _handle_line(self, raw: bytes) -> None:
        try:
            text = raw.decode("utf-8", errors="replace").strip()
        except Exception:
            return
        if not text:
            return
        try:
            message = json.loads(text)
        except json.JSONDecodeError:
            logger.warning("Linea serie no es JSON valido: {!r}", text)
            return

        if self._on_message:
            self._on_message(message)


class SimulatedSerialManager:
    """
    Sustituto de SerialManager sin hardware real. Los mensajes ESP32 -> PC
    se inyectan desde un hilo de teclado (ver utils/simulator_console.py) o
    programaticamente con inject().

    Interfaz publica identica a SerialManager, para que ESP32Controller
    no necesite saber cual de los dos esta usando.
    """

    def __init__(self, on_message: Optional[Callable[[dict], None]] = None):
        self._on_message = on_message
        self._connected = False
        self._queue: Queue = Queue()
        self._stop_event = threading.Event()
        self._thread: Optional[threading.Thread] = None

    def connect(self) -> bool:
        self._connected = True
        self._stop_event.clear()
        self._thread = threading.Thread(target=self._dispatch_loop, daemon=True)
        self._thread.start()
        logger.info("SerialManager simulado activo (sin hardware ESP32 real)")
        self.inject({"event": "boot", "firmware": "simulated"})
        return True

    def disconnect(self) -> None:
        self._connected = False
        self._stop_event.set()
        if self._thread:
            self._thread.join(timeout=1)

    def send(self, message: dict) -> bool:
        # En simulacion, solo lo mostramos: representa lo que el ESP32 real recibiria.
        logger.info("[SIM -> ESP32] {}", message)
        return True

    def is_connected(self) -> bool:
        return self._connected

    def inject(self, message: dict) -> None:
        """Inyecta un mensaje como si viniera del ESP32 (usado por la consola de simulacion)."""
        self._queue.put(message)

    def _dispatch_loop(self) -> None:
        while not self._stop_event.is_set():
            try:
                message = self._queue.get(timeout=0.5)
            except Empty:
                continue
            if self._on_message:
                self._on_message(message)
