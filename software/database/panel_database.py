#
# SteamMachine UM790
#
# database.panel_database
#
# Relaciona UID de panel NFC con plataforma (03_Software_Architecture.md, seccion 6).
#

import json
from pathlib import Path
from typing import Optional

from core.logger import get_logger

logger = get_logger()

DEFAULT_PATH = Path(__file__).resolve().parent.parent / "config" / "panel_database.json"


class PanelDatabase:
    """
    Gestiona los paneles NFC: carga, guarda, busca y modifica.
    """

    def __init__(self, path: Path = DEFAULT_PATH):
        self._path = path
        self._panels: dict[str, dict] = {}

    def load(self) -> dict:
        if not self._path.exists():
            logger.warning("panel_database.json no encontrado en {}", self._path)
            self._panels = {}
            return self._panels
        try:
            with open(self._path, "r", encoding="utf-8") as f:
                self._panels = json.load(f)
        except Exception as e:
            logger.error("Error leyendo panel_database.json: {}", e)
            self._panels = {}
        return self._panels

    def save(self) -> None:
        self._path.parent.mkdir(exist_ok=True)
        try:
            with open(self._path, "w", encoding="utf-8") as f:
                json.dump(self._panels, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logger.error("Error guardando panel_database.json: {}", e)

    def find(self, uid: str) -> Optional[dict]:
        return self._panels.get(uid.upper())

    def add(self, uid: str, name: str, launcher: str, led: str, icon: str = "") -> None:
        self._panels[uid.upper()] = {
            "name": name,
            "launcher": launcher,
            "led": led,
            "icon": icon,
        }

    def remove(self, uid: str) -> None:
        self._panels.pop(uid.upper(), None)

    def update(self, uid: str, **fields) -> None:
        entry = self._panels.get(uid.upper())
        if entry:
            entry.update(fields)

    def all(self) -> dict:
        return dict(self._panels)
