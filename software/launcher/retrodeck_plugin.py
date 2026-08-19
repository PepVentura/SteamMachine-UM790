#
# SteamMachine UM790
#
# launcher.retrodeck_plugin
#
# Lanza RetroDECK (paquete Flatpak todo-en-uno de emulacion retro).
#

from launcher.base_plugin import BasePlugin


class RetroDeckPlugin(BasePlugin):
    name = "retrodeck"

    def launch(self) -> bool:
        return self._spawn()
