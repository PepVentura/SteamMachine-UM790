#
# SteamMachine UM790
#
# core.config
#
# ConfigurationManager: lee, guarda y valida config/config.json
#

import json
from pathlib import Path
from typing import Any

from core.logger import get_logger

logger = get_logger()

CONFIG_DIR = Path(__file__).resolve().parent.parent / "config"
CONFIG_PATH = CONFIG_DIR / "config.json"

DEFAULT_CONFIG = {
    "serial": {
        # "auto" busca el primer puerto que coincida con esp32_vid_pid;
        # tambien se puede fijar un puerto explicito, p.ej. "/dev/ttyUSB0".
        "port": "auto",
        "baudrate": 115200,
        "esp32_vid_pid": ["10C4:EA60", "1A86:7523", "303A:1001"],
        # Modo simulado: no requiere ESP32 ni firmware. Los eventos (tag/button)
        # se generan desde teclado. Util para desarrollo; con hardware real
        # (ya montado) se deja en False para conectar al ESP32 de verdad.
        "simulate": False,
        "reconnect_interval_seconds": 3,
    },
    "log_level": "INFO",
    "platforms": {
        "steam": {"command": ["steam", "steam://open/bigpicture"]},
        "retrodeck": {"command": ["flatpak", "run", "net.retrodeck.retrodeck"]},
        "teknoparrot": {"command": ["lutris", "lutris:rungame/teknoparrot"]},
    },
}


class ConfigurationManager:
    """
    Responsable de leer, guardar y validar la configuracion de la aplicacion.
    """

    def __init__(self, path: Path = CONFIG_PATH):
        self._path = path
        self._data: dict = {}

    def load(self) -> dict:
        if not self._path.exists():
            logger.warning("config.json no encontrado, creando uno por defecto en {}", self._path)
            self._data = json.loads(json.dumps(DEFAULT_CONFIG))
            self.save()
            return self._data

        try:
            with open(self._path, "r", encoding="utf-8") as f:
                self._data = json.load(f)
            self._data = self._merge_defaults(self._data)
        except Exception as e:
            logger.error("Error leyendo config.json, usando valores por defecto: {}", e)
            self._data = json.loads(json.dumps(DEFAULT_CONFIG))

        return self._data

    def save(self) -> None:
        CONFIG_DIR.mkdir(exist_ok=True)
        try:
            with open(self._path, "w", encoding="utf-8") as f:
                json.dump(self._data, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logger.error("Error guardando config.json: {}", e)

    def reset(self) -> None:
        self._data = json.loads(json.dumps(DEFAULT_CONFIG))
        self.save()

    def get(self, key: str, default: Any = None) -> Any:
        """Acceso por clave punteada, p.ej. get('serial.baudrate')."""
        node = self._data
        for part in key.split("."):
            if not isinstance(node, dict) or part not in node:
                return default
            node = node[part]
        return node

    def set(self, key: str, value: Any) -> None:
        parts = key.split(".")
        node = self._data
        for part in parts[:-1]:
            node = node.setdefault(part, {})
        node[parts[-1]] = value

    @staticmethod
    def _merge_defaults(data: dict) -> dict:
        """Rellena claves que falten en config.json con el valor por defecto (config forward-compatible)."""
        def merge(default, actual):
            if isinstance(default, dict):
                result = dict(default)
                if isinstance(actual, dict):
                    for k, v in actual.items():
                        result[k] = merge(default.get(k, v), v)
                return result
            return actual

        return merge(DEFAULT_CONFIG, data)
