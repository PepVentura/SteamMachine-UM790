#
# SteamMachine UM790
#
# core.logger
#
# Configuracion centralizada de logging (loguru).
# Ningun modulo debe usar print() para depuracion permanente (09_Coding_Standards.md).
#

import sys
from pathlib import Path

from loguru import logger

LOG_DIR = Path(__file__).resolve().parent.parent / "logs"


def setup_logger(level: str = "INFO") -> None:
    """
    Configura los sinks de logging: consola (coloreada) y fichero rotativo.
    Debe llamarse una unica vez, al arrancar la aplicacion.
    """
    LOG_DIR.mkdir(exist_ok=True)

    logger.remove()

    logger.add(
        sys.stderr,
        level=level,
        colorize=True,
        format="<green>{time:HH:mm:ss}</green> | <level>{level: <8}</level> | "
        "<cyan>{name}</cyan>:<cyan>{function}</cyan> - <level>{message}</level>",
    )

    logger.add(
        LOG_DIR / "steammachine.log",
        level="DEBUG",
        rotation="1 MB",
        retention=5,
        encoding="utf-8",
    )


def get_logger():
    """Devuelve la instancia global de loguru, ya configurada por setup_logger()."""
    return logger
