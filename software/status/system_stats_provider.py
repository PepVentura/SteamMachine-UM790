#
# SteamMachine UM790
#
# status.system_stats_provider
#
# Metricas de sistema para el perfil MAINTENANCE (docs/12_Profile_System.md).
# Alcance de esta primera version: solo CPU (temperatura) y RAM (uso),
# porque son las unicas dos que se pueden leer de forma razonablemente
# generica con psutil en Linux. GPU y FAN se han dejado fuera a
# proposito - psutil no tiene una API generica para ninguna de las dos
# (sensors_fans() depende del nombre exacto que le de la placa base, y
# la temperatura de GPU necesita el driver especifico del fabricante) -
# ver CHANGELOG para el detalle. Mejor no mostrar un dato inventado que
# mostrar uno mal etiquetado.
#
# psutil se inyecta por constructor (por defecto, el modulo real) para
# poder sustituirlo por un doble en los tests sin depender de que la
# maquina de pruebas tenga sensores reales.
#

from __future__ import annotations

from core.logger import get_logger
from status.base_provider import BaseStatusProvider

logger = get_logger()

NOT_AVAILABLE = "N/D"


_UNSET = object()


class SystemStatsProvider(BaseStatusProvider):
    def __init__(self, psutil_module=_UNSET):
        if psutil_module is _UNSET:
            try:
                import psutil as psutil_module
            except ImportError:
                logger.warning("psutil no esta instalado; SystemStatsProvider dara 'N/D' en todo")
                psutil_module = None
        self._psutil = psutil_module

    def snapshot(self) -> dict:
        return {
            "cpu_temp": self._cpu_temp(),
            "ram_used_gb": self._ram_used_gb(),
            "ram_total_gb": self._ram_total_gb(),
            "ram_percent": self._ram_percent(),
        }

    # -- lecturas individuales, cada una con su propio try/except -----
    # (un sensor que falle no debe tirar abajo el resto de la foto)

    def _cpu_temp(self):
        if not self._psutil:
            return NOT_AVAILABLE
        try:
            sensors = self._psutil.sensors_temperatures()
            for readings in sensors.values():
                if readings:
                    return round(readings[0].current, 1)
            return NOT_AVAILABLE
        except Exception as e:
            logger.warning("No se pudo leer la temperatura de CPU: {}", e)
            return NOT_AVAILABLE

    def _ram_used_gb(self):
        if not self._psutil:
            return NOT_AVAILABLE
        try:
            return round(self._psutil.virtual_memory().used / (1024**3), 1)
        except Exception as e:
            logger.warning("No se pudo leer el uso de RAM: {}", e)
            return NOT_AVAILABLE

    def _ram_total_gb(self):
        if not self._psutil:
            return NOT_AVAILABLE
        try:
            return round(self._psutil.virtual_memory().total / (1024**3), 1)
        except Exception as e:
            logger.warning("No se pudo leer el total de RAM: {}", e)
            return NOT_AVAILABLE

    def _ram_percent(self):
        if not self._psutil:
            return NOT_AVAILABLE
        try:
            return round(self._psutil.virtual_memory().percent, 0)
        except Exception as e:
            logger.warning("No se pudo leer el porcentaje de RAM: {}", e)
            return NOT_AVAILABLE
