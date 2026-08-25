#
# SteamMachine UM790
#
# devices.led_manager
#
# Controla la barra LED a traves de ESP32Controller (08_Software_API.md,
# clase LEDManager: set_color, set_brightness, animation, off, flash, fade).
#
# El protocolo (04_Communication_Protocol.md) solo define comandos discretos
# ("led", "brightness", "animation" con nombres fijos: idle/loading/launch/
# rainbow/error/success/shutdown) - no hay "flash" ni "fade" nativos en el
# firmware. Se implementan aqui enviando una secuencia de comandos "led"
# espaciados en el tiempo, en un hilo en segundo plano. Si mas adelante el
# firmware incorpora animaciones nativas con mejor temporizacion, esto puede
# simplificarse a un unico "cmd":"animation" y dejar de mandar tantos
# mensajes por el puerto serie.
#

from __future__ import annotations

import threading
import time
from typing import Optional

from core.logger import get_logger

logger = get_logger()

ANIMATIONS = {"idle", "loading", "launch", "rainbow", "error", "success", "shutdown"}


def _hex_to_rgb(color: str) -> tuple[int, int, int]:
    color = color.lstrip("#")
    return tuple(int(color[i : i + 2], 16) for i in (0, 2, 4))


def _rgb_to_hex(rgb: tuple[float, float, float]) -> str:
    return "#{:02X}{:02X}{:02X}".format(*(max(0, min(255, round(c))) for c in rgb))


class LEDManager:
    def __init__(self, esp32):
        self._esp32 = esp32
        self._stop_event = threading.Event()
        self._thread: Optional[threading.Thread] = None
        self._current_color = "#000000"

    # -- Comandos directos (pasan tal cual al protocolo) ------------------

    def set_color(self, color: str) -> None:
        self._cancel_animation()
        self._current_color = color
        self._esp32.set_led(color)

    def set_brightness(self, value: int) -> None:
        self._esp32.set_brightness(value)

    def animation(self, name: str) -> None:
        if name not in ANIMATIONS:
            logger.warning("Animacion '{}' no esta en la lista conocida; se envia igualmente", name)
        self._cancel_animation()
        self._esp32.animation(name)

    def off(self) -> None:
        self.set_color("#000000")

    # -- Animaciones por software (secuencias de "led") -------------------

    def flash(self, color: str, times: int = 3, interval: float = 0.15, restore_to: Optional[str] = None) -> None:
        """Parpadea `color` `times` veces; al terminar vuelve a `restore_to` (o al color previo). No bloquea."""
        self._cancel_animation()
        restore = restore_to if restore_to is not None else self._current_color
        self._stop_event.clear()
        self._thread = threading.Thread(
            target=self._flash_loop, args=(color, times, interval, restore), daemon=True
        )
        self._thread.start()

    def fade(self, to_color: str, duration: float = 0.6, steps: int = 20) -> None:
        """Transicion suave desde el color actual hasta `to_color`. No bloquea."""
        self._cancel_animation()
        from_color = self._current_color
        self._stop_event.clear()
        self._thread = threading.Thread(
            target=self._fade_loop, args=(from_color, to_color, duration, steps), daemon=True
        )
        self._thread.start()

    # -- Internos -----------------------------------------------------------

    def _flash_loop(self, color: str, times: int, interval: float, restore: str) -> None:
        for _ in range(times):
            if self._stop_event.is_set():
                return
            self._esp32.set_led(color)
            time.sleep(interval)
            if self._stop_event.is_set():
                return
            self._esp32.set_led(restore)
            time.sleep(interval)
        self._current_color = restore

    def _fade_loop(self, from_color: str, to_color: str, duration: float, steps: int) -> None:
        start_rgb = _hex_to_rgb(from_color)
        end_rgb = _hex_to_rgb(to_color)
        delay = duration / max(steps, 1)
        for i in range(1, steps + 1):
            if self._stop_event.is_set():
                return
            t = i / steps
            rgb = tuple(start_rgb[c] + (end_rgb[c] - start_rgb[c]) * t for c in range(3))
            self._esp32.set_led(_rgb_to_hex(rgb))
            time.sleep(delay)
        self._current_color = to_color

    def _cancel_animation(self) -> None:
        """Si hay un flash/fade en curso, lo corta antes de aceptar un comando nuevo."""
        if self._thread and self._thread.is_alive():
            self._stop_event.set()
            self._thread.join(timeout=1)
        self._stop_event.clear()
