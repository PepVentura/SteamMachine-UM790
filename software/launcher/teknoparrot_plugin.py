#
# SteamMachine UM790
#
# launcher.teknoparrot_plugin
#
# Lanza TeknoParrot (recreativas) via Lutris.
#

from launcher.base_plugin import BasePlugin


class TeknoParrotPlugin(BasePlugin):
    name = "teknoparrot"

    def launch(self) -> bool:
        return self._spawn()
