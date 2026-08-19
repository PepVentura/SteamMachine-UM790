#
# SteamMachine UM790
#
# launcher.steam_plugin
#
# Lanza Steam en modo Big Picture (Bazzite lo trae preinstalado).
#

from launcher.base_plugin import BasePlugin


class SteamPlugin(BasePlugin):
    name = "steam"

    def launch(self) -> bool:
        return self._spawn()
