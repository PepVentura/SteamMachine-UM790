#
# SteamMachine UM790
#
# core.events
#
# EventManager: toda la comunicacion interna entre modulos usa eventos
# (03_Software_Architecture.md, principio de diseno).
#

from collections import defaultdict
from enum import Enum, auto
from typing import Callable

from core.logger import get_logger

logger = get_logger()


class Event(Enum):
    BOOT = auto()
    TAG_DETECTED = auto()
    TAG_REMOVED = auto()
    BUTTON = auto()
    LAUNCH = auto()
    STOP = auto()
    ERROR = auto()
    SHUTDOWN = auto()


class EventManager:
    """
    Bus de eventos interno, simple pub/sub sincrono.
    """

    def __init__(self):
        self._subscribers: dict[Event, list[Callable]] = defaultdict(list)

    def subscribe(self, event: Event, callback: Callable) -> None:
        self._subscribers[event].append(callback)
        logger.debug("Suscrito {} a {}", getattr(callback, "__name__", callback), event.name)

    def unsubscribe(self, event: Event, callback: Callable) -> None:
        if callback in self._subscribers.get(event, []):
            self._subscribers[event].remove(callback)

    def publish(self, event: Event, **data) -> None:
        logger.debug("Evento publicado: {} {}", event.name, data)
        for callback in list(self._subscribers.get(event, [])):
            try:
                callback(**data)
            except Exception as e:
                logger.error("Error en callback de {}: {}", event.name, e)
