#
# SteamMachine UM790
#
# tests.conftest
#
# Asegura que "software/" (raiz del paquete: core, devices, database,
# launcher) esta en sys.path aunque pytest se ejecute desde otro sitio.
#

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
