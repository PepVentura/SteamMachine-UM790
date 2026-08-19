#
# SteamMachine UM790
#
# launcher.launcher
#
# Responsable de iniciar plataformas. Cada plataforma tiene su propio plugin
# (03_Software_Architecture.md, seccion "Launcher").
#

from __future__ import annotations

from typing import Optional

from core.logger import get_logger
from launcher.base_plugin import BasePlugin
from launcher.retrodeck_plugin import RetroDeckPlugin
from launcher.steam_plugin import SteamPlugin
from launcher.teknoparrot_plugin import TeknoParrotPlugin

logger = get_logger()

PLUGIN_CLASSES = {
    "steam": SteamPlugin,
    "retrodeck": RetroDeckPlugin,
    "teknoparrot": TeknoParrotPlugin,
}


class Launcher:
    """
    Registro de plugins de plataforma y punto unico de lanzamiento/parada.
    """

    def __init__(self, platforms_config: dict):
        self._plugins: dict[str, BasePlugin] = {}
        for key, plugin_cls in PLUGIN_CLASSES.items():
            command = platforms_config.get(key, {}).get("command")
            if command:
                self._plugins[key] = plugin_cls(command)
            else:
                logger.warning("Sin comando configurado para la plataforma '{}'", key)

    def launch(self, platform: str) -> bool:
        plugin = self._plugins.get(platform)
        if not plugin:
            logger.error("Plataforma desconocida: {}", platform)
            return False
        return plugin.launch()

    def stop(self, platform: str) -> bool:
        plugin = self._plugins.get(platform)
        return plugin.stop() if plugin else False

    def running(self, platform: Optional[str] = None) -> bool | dict:
        if platform:
            plugin = self._plugins.get(platform)
            return plugin.running() if plugin else False
        return {name: p.running() for name, p in self._plugins.items()}

    def status(self, platform: Optional[str] = None):
        if platform:
            plugin = self._plugins.get(platform)
            return plugin.status() if plugin else None
        return {name: p.status() for name, p in self._plugins.items()}
