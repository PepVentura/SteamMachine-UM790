#
# SteamMachine UM790
#
# core.application
#
# Clase principal. Inicializacion, gestion de eventos, coordinacion de
# modulos y ciclo principal (08_Software_API.md, seccion Core).
#

from __future__ import annotations

import signal
import time

from core.config import ConfigurationManager
from core.events import Event, EventManager
from core.logger import get_logger, setup_logger
from database.panel_database import PanelDatabase
from devices.esp32_controller import ESP32Controller
from devices.led_manager import LEDManager
from devices.oled_manager import OLEDManager
from launcher.launcher import Launcher

IDLE_COLOR = "#0055FF"

logger = get_logger()


class Application:
    """
    SteamMachine Core.

    Flujo (04_Communication_Protocol.md):
        panel colocado -> tag -> buscar perfil -> oled + led ->
        esperar boton -> lanzar aplicacion -> animation launch
    """

    def __init__(self):
        self._config = ConfigurationManager()
        self._events = EventManager()
        self._database = PanelDatabase()
        self._esp32: ESP32Controller | None = None
        self._oled: OLEDManager | None = None
        self._leds: LEDManager | None = None
        self._launcher: Launcher | None = None

        self._running = False
        self._pending_panel: dict | None = None  # panel detectado, a la espera del boton

    # -- Ciclo de vida -----------------------------------------------

    def initialize(self) -> None:
        self.load_configuration()
        setup_logger(self._config.get("log_level", "INFO"))
        logger.info("SteamMachine Core iniciando...")

        self._database.load()
        self._launcher = Launcher(self._config.get("platforms", {}))
        self._esp32 = ESP32Controller(self._config, self._events)
        self._oled = OLEDManager(self._esp32)
        self._leds = LEDManager(self._esp32)

        self._subscribe_events()

        if not self._esp32.connect():
            logger.warning("No se pudo conectar con el ESP32; reintentando en segundo plano")

    def run(self) -> None:
        self.initialize()
        self._running = True

        signal.signal(signal.SIGINT, lambda *_: self.shutdown())
        signal.signal(signal.SIGTERM, lambda *_: self.shutdown())

        if self._esp32.simulated:
            self._start_simulation_console()

        logger.info("SteamMachine Core listo. Esperando eventos...")
        try:
            while self._running:
                time.sleep(0.2)
        except KeyboardInterrupt:
            self.shutdown()

    def shutdown(self) -> None:
        logger.info("Cerrando SteamMachine Core...")
        self._running = False
        if self._esp32:
            self._esp32.disconnect()

    def restart(self) -> None:
        self.shutdown()
        self.run()

    def load_configuration(self) -> dict:
        return self._config.load()

    def save_configuration(self) -> None:
        self._config.save()

    # -- Eventos --------------------------------------------------------

    def _subscribe_events(self) -> None:
        self._events.subscribe(Event.BOOT, self._on_boot)
        self._events.subscribe(Event.TAG_DETECTED, self._on_tag_detected)
        self._events.subscribe(Event.TAG_REMOVED, self._on_tag_removed)
        self._events.subscribe(Event.BUTTON, self._on_button)
        self._events.subscribe(Event.ERROR, self._on_error)

    def _on_boot(self, firmware: str = None) -> None:
        logger.info("ESP32 arrancado (firmware={})", firmware)
        self._oled.show_text("SteamMachine")
        self._leds.set_color(IDLE_COLOR)

    def _on_tag_detected(self, uid: str) -> None:
        logger.info("Panel detectado: {}", uid)
        panel = self._database.find(uid)

        if not panel:
            logger.warning("UID desconocido: {}", uid)
            self._oled.show_status("Panel", "no reconocido")
            self._leds.flash("#FF0000", times=3, restore_to=IDLE_COLOR)
            self._pending_panel = None
            return

        self._pending_panel = panel
        self._oled.show_text(panel["name"])
        self._leds.fade(panel["led"])
        logger.info("Perfil '{}' listo. Esperando pulsador...", panel["name"])

    def _on_tag_removed(self) -> None:
        logger.info("Panel retirado")
        self._pending_panel = None
        self._oled.sleep()
        self._leds.fade(IDLE_COLOR)

    def _on_button(self) -> None:
        if not self._pending_panel:
            logger.debug("Boton pulsado sin panel activo, se ignora")
            return

        platform = self._pending_panel["launcher"]
        logger.info("Lanzando plataforma: {}", platform)
        self._leds.animation("launch")
        self._oled.show_status(self._pending_panel["name"], "Launching...")

        ok = self._launcher.launch(platform)
        self._leds.animation("success" if ok else "error")

    def _on_error(self, code: int = None) -> None:
        logger.error("Error reportado por el ESP32 (codigo {})", code)

    # -- Modo simulado ----------------------------------------------------

    def _start_simulation_console(self) -> None:
        """
        En modo simulado no hay ESP32 real. Lanza un hilo que lee comandos
        de teclado y los inyecta como eventos ESP32 -> PC, para poder probar
        todo el Core sin hardware ni firmware.
        """
        import threading

        def console_loop():
            print("\n--- Consola de simulacion ESP32 ---")
            print("Panels disponibles: " + ", ".join(self._database.all().keys()))
            print("Comandos: <UID> = colocar panel | r = retirar panel | b = pulsar boton | q = salir\n")
            while self._running:
                try:
                    cmd = input("sim> ").strip()
                except EOFError:
                    break
                if not cmd:
                    continue
                if cmd == "q":
                    self.shutdown()
                    break
                elif cmd == "b":
                    self._esp32.inject_simulated_event({"event": "button"})
                elif cmd == "r":
                    self._esp32.inject_simulated_event({"event": "tag_removed"})
                else:
                    self._esp32.inject_simulated_event({"event": "tag", "uid": cmd.upper()})

        threading.Thread(target=console_loop, daemon=True).start()
