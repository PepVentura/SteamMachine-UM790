#
# SteamMachine UM790
#
# launcher.retroarch_plugin
#
# Lanza RetroArch (Flatpak org.libretro.RetroArch) directamente, sin pasar
# por RetroDECK. Util para paneles dedicados a un sistema/nucleo concreto
# (o a un playlist .lpl especifico) sin la capa extra del frontend de
# RetroDECK. Pendiente: asignar panel NFC dedicado.
#

from launcher.base_plugin import BasePlugin


class RetroArchPlugin(BasePlugin):
    name = "retroarch"

    def launch(self) -> bool:
        return self._spawn()
