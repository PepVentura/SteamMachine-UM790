#
# SteamMachine UM790
#
# devices.esp32_controller
#
# Oculta completamente el protocolo serie (04_Communication_Protocol.md).
# El resto del software nunca accede directamente al puerto serie.
#

from __future__ import annotations

from typing import Optional

from core.events import Event, EventManager
from core.logger import get_logger
from devices.serial_manager import SerialManager, SimulatedSerialManager

logger = get_logger()


class ESP32Controller:
    """
    API de alto nivel hacia el ESP32. Traduce eventos ESP32 -> PC al
    EventManager, y expone comandos PC -> ESP32 como metodos Python.
    """

    def __init__(self, config, event_manager: EventManager):
        self._config = config
        self._events = event_manager

        simulate = config.get("serial.simulate", True)
        if simulate:
            self._serial = SimulatedSerialManager(on_message=self._on_message)
        else:
            self._serial = SerialManager(
                port=config.get("serial.port", "auto"),
                baudrate=config.get("serial.baudrate", 115200),
                vid_pid=config.get("serial.esp32_vid_pid", []),
                reconnect_interval=config.get("serial.reconnect_interval_seconds", 3),
                on_message=self._on_message,
            )

    # -- Ciclo de vida ---------------------------------------------------

    def connect(self) -> bool:
        return self._serial.connect()

    def disconnect(self) -> None:
        self._serial.disconnect()

    def is_connected(self) -> bool:
        return self._serial.is_connected()

    @property
    def simulated(self) -> bool:
        return isinstance(self._serial, SimulatedSerialManager)

    def inject_simulated_event(self, message: dict) -> None:
        """Solo tiene efecto en modo simulado; ver SimulatedSerialManager.inject()."""
        if isinstance(self._serial, SimulatedSerialManager):
            self._serial.inject(message)

    # -- Comandos PC -> ESP32 (04_Communication_Protocol.md) ------------

    def oled(self, text: str) -> None:
        self._serial.send({"cmd": "oled", "text": text})

    def oled_lines(self, line1: str, line2: str) -> None:
        self._serial.send({"cmd": "oled2", "line1": line1, "line2": line2})

    def clear_oled(self) -> None:
        self._serial.send({"cmd": "oled_clear"})

    def set_led(self, color: str) -> None:
        self._serial.send({"cmd": "led", "color": color})

    def set_brightness(self, value: int) -> None:
        value = max(0, min(255, value))
        self._serial.send({"cmd": "brightness", "value": value})

    def animation(self, name: str) -> None:
        self._serial.send({"cmd": "animation", "name": name})

    def restart(self) -> None:
        self._serial.send({"cmd": "restart"})

    def request_status(self) -> None:
        self._serial.send({"cmd": "status"})

    # -- Eventos ESP32 -> PC ---------------------------------------------

    def _on_message(self, message: dict) -> None:
        event = message.get("event")

        if event == "boot":
            self._events.publish(Event.BOOT, firmware=message.get("firmware"))
        elif event == "tag":
            self._events.publish(Event.TAG_DETECTED, uid=message.get("uid"))
        elif event == "tag_removed":
            self._events.publish(Event.TAG_REMOVED)
        elif event == "button":
            self._events.publish(Event.BUTTON)
        elif event == "error":
            self._events.publish(Event.ERROR, code=message.get("code"))
        elif event == "status":
            logger.info("Estado ESP32: {}", message)
        else:
            logger.warning("Evento ESP32 desconocido: {}", message)
