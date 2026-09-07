#
# SteamMachine UM790
#
# status.base_provider
#
# Interfaz comun de los StatusProvider (docs/12_Profile_System.md,
# seccion "Perfiles con contenido en vivo"): "dame un dict de variables
# para rellenar la plantilla". Cada provider debe devolver SIEMPRE un
# dict (nunca lanzar), usando valores "N/D" para lo que no pueda leer -
# un fallo al leer un sensor no debe tumbar la OLED.
#

from __future__ import annotations


class BaseStatusProvider:
    def snapshot(self) -> dict:
        raise NotImplementedError
