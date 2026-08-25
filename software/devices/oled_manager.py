#
# SteamMachine UM790
#
# devices.oled_manager
#
# Controla la pantalla OLED a traves de ESP32Controller (08_Software_API.md,
# clase OLEDManager: show_text, show_logo, show_status, clear, sleep, wake).
#
# El protocolo (04_Communication_Protocol.md) solo soporta texto ("oled",
# "oled2", "oled_clear") - no hay comandos para iconos/bitmaps ni para
# apagar la pantalla en el firmware. show_logo() usa texto como
# aproximacion (pendiente de icono real, ver 04, seccion "Futuras
# ampliaciones"); sleep()/wake() se aproximan con oled_clear + recordar
# el ultimo contenido mostrado, para poder restaurarlo.
#

from __future__ import annotations

from typing import Optional


class OLEDManager:
    def __init__(self, esp32):
        self._esp32 = esp32
        self._last_state: Optional[tuple] = None  # ("text", value) o ("lines", l1, l2)
        self._asleep = False

    def show_text(self, text: str) -> None:
        self._asleep = False
        self._last_state = ("text", text)
        self._esp32.oled(text)

    def show_status(self, line1: str, line2: str) -> None:
        self._asleep = False
        self._last_state = ("lines", line1, line2)
        self._esp32.oled_lines(line1, line2)

    def show_logo(self, platform: str) -> None:
        # TODO: sin soporte de iconos en el protocolo todavia; aproximado con texto.
        self.show_text(platform.upper())

    def clear(self) -> None:
        self._asleep = False
        self._last_state = None
        self._esp32.clear_oled()

    def sleep(self) -> None:
        if self._asleep:
            return
        self._asleep = True
        self._esp32.clear_oled()

    def wake(self) -> None:
        if not self._asleep:
            return
        self._asleep = False
        if not self._last_state:
            return
        if self._last_state[0] == "text":
            self._esp32.oled(self._last_state[1])
        else:
            self._esp32.oled_lines(self._last_state[1], self._last_state[2])
