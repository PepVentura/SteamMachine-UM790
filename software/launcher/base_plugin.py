#
# SteamMachine UM790
#
# launcher.base_plugin
#
# Todos los lanzadores heredan de BasePlugin (08_Software_API.md).
#

from __future__ import annotations

import subprocess
from abc import ABC, abstractmethod
from typing import Optional

from core.logger import get_logger

logger = get_logger()


class BasePlugin(ABC):
    """
    Interfaz obligatoria para cualquier plataforma lanzable.
    Los plugins nunca acceden directamente al hardware (solo a procesos del SO).
    """

    name: str = "base"

    def __init__(self, command: list[str]):
        self._command = command
        self._process: Optional[subprocess.Popen] = None

    @abstractmethod
    def launch(self) -> bool:
        ...

    def stop(self) -> bool:
        if self._process and self._process.poll() is None:
            self._process.terminate()
            logger.info("{}: proceso detenido", self.name)
            return True
        return False

    def running(self) -> bool:
        return self._process is not None and self._process.poll() is None

    def status(self) -> dict:
        return {
            "name": self.name,
            "running": self.running(),
            "pid": self._process.pid if self._process else None,
        }

    def configuration(self) -> dict:
        return {"command": self._command}

    def _spawn(self) -> bool:
        try:
            self._process = subprocess.Popen(self._command)
            logger.info("{}: lanzado ({})", self.name, " ".join(self._command))
            return True
        except FileNotFoundError:
            logger.error("{}: comando no encontrado: {}", self.name, self._command[0])
            return False
        except Exception as e:
            logger.error("{}: error al lanzar: {}", self.name, e)
            return False
