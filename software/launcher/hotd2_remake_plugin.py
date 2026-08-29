#
# SteamMachine UM790
#
# launcher.hotd2_remake_plugin
#
# Lanza THE HOUSE OF THE DEAD 2: Remake (AppID Steam 3376690) directamente,
# via steam://rungameid/. Juego nativo de Steam (Proton), companero del
# panel de disparos/zombies junto a hotd_remake_plugin.
#

from launcher.base_plugin import BasePlugin


class Hotd2RemakePlugin(BasePlugin):
    name = "hotd2_remake"

    def launch(self) -> bool:
        return self._spawn()
