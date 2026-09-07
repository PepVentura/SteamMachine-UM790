#
# SteamMachine UM790
#
# core.profile_manager
#
# Carga los perfiles de docs/12_Profile_System.md desde
# config/profiles/*.json y los resuelve a partir del campo opcional
# "profile" de un panel de PanelDatabase.
#
# Retrocompatibilidad: un panel sin "profile" no pasa por aqui -
# Application sigue usando panel["launcher"] / panel["led"] / panel["name"]
# directamente, igual que antes de que existiera este modulo. Este
# gestor solo entra en juego para los paneles migrados explicitamente
# al nuevo esquema (de momento, solo "STEAM" - ver CHANGELOG).
#

from __future__ import annotations

import json
from pathlib import Path
from typing import Optional

from core.logger import get_logger

logger = get_logger()

DEFAULT_PATH = Path(__file__).resolve().parent.parent / "config" / "profiles"


class ProfileManager:
    """
    Registro de perfiles (id -> definicion completa: launcher, led, oled).
    """

    def __init__(self, path: Path = DEFAULT_PATH):
        self._path = path
        self._profiles: dict[str, dict] = {}

    def load(self) -> dict:
        self._profiles = {}
        if not self._path.exists():
            logger.warning("Carpeta de perfiles no encontrada en {}", self._path)
            return self._profiles

        for file in sorted(self._path.glob("*.json")):
            try:
                with open(file, "r", encoding="utf-8") as f:
                    data = json.load(f)
            except Exception as e:
                logger.error("Error leyendo perfil '{}': {}", file.name, e)
                continue

            profile_id = data.get("id") or file.stem
            self._profiles[profile_id] = data

        return self._profiles

    def get(self, profile_id: Optional[str]) -> Optional[dict]:
        if not profile_id:
            return None
        profile = self._profiles.get(profile_id)
        if profile is None:
            logger.warning("Perfil desconocido: '{}'", profile_id)
        return profile

    def all(self) -> dict:
        return dict(self._profiles)
