#
# SteamMachine UM790
#
# launcher.hotd_remake_plugin
#
# Lanza THE HOUSE OF THE DEAD: Remake (AppID Steam 1694600) directamente,
# via steam://rungameid/. Juego nativo de Steam (Proton) — sustituye a
# TeknoParrot para el panel de disparos/zombies por su mejor compatibilidad
# con Linux/Bazzite.
#

from launcher.base_plugin import BasePlugin


class HotdRemakePlugin(BasePlugin):
    name = "hotd_remake"

    def launch(self) -> bool:
        return self._spawn()
