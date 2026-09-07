#
# SteamMachine UM790
#
# status.status_manager
#
# Registro de StatusProvider (docs/12_Profile_System.md), mismo patron
# que launcher.launcher.Launcher: un dict fijo de clases, se instancian
# todas al arrancar, y se accede por nombre.
#

from __future__ import annotations

from typing import Optional

from core.logger import get_logger
from status.system_stats_provider import SystemStatsProvider

logger = get_logger()

STATUS_PROVIDER_CLASSES = {
    "system_stats": SystemStatsProvider,
}


class StatusManager:
    def __init__(self):
        self._providers = {name: cls() for name, cls in STATUS_PROVIDER_CLASSES.items()}

    def snapshot(self, provider_name: Optional[str]) -> dict:
        if not provider_name:
            return {}
        provider = self._providers.get(provider_name)
        if not provider:
            logger.warning("StatusProvider desconocido: '{}'", provider_name)
            return {}
        return provider.snapshot()
