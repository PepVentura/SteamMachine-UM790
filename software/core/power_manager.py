#
# SteamMachine UM790
#
# core.power_manager
#
# Apagado ordenado del mini PC (panel NFC "APAGAR", docs/12_Profile_System.md).
#
# Motivo: cortar la corriente de golpe a veces deja Bazzite sin poder
# arrancar (ver "El mini PC se queda en un prompt grub>" en
# GUIA_INICIO.md). Un apagado ordenado deja que systemd desmonte los
# sistemas de ficheros y termine los servicios antes de cortar.
#
# Se usa "systemctl poweroff" tal cual, sin sudo: en una sesion grafica
# local activa (la del servicio de usuario steammachine.service) polkit
# permite apagar sin contrasena. Si algo bloquea el apagado (p.ej. una
# actualizacion de rpm-ostree en curso, un "inhibitor lock" de bloqueo),
# systemctl devuelve un codigo distinto de 0 y aqui se traduce en
# poweroff() -> False, para que Application avise en la OLED en vez de
# quedarse mostrando "Apagando..." sin que pase nada.
#
# dry_run: lo activa Application cuando el ESP32 esta simulado
# (serial.simulate=true). El modo simulado solo finge el ESP32; el resto
# (lanzador, comandos) es real, y un panel APAGAR tecleado en la consola
# de simulacion apagaria de verdad la maquina de desarrollo. En dry_run
# el apagado se registra en el log pero NO se ejecuta.
#

from __future__ import annotations

import subprocess
from typing import Optional

from core.logger import get_logger

logger = get_logger()

DEFAULT_POWEROFF_COMMAND = ["systemctl", "poweroff"]

# "systemctl poweroff" encola el trabajo y vuelve casi al instante; si tarda
# mas que esto es que algo va mal (bus D-Bus colgado, polkit esperando...).
DEFAULT_TIMEOUT_SECONDS = 15.0


class PowerManager:
    """
    Ejecuta el apagado ordenado del sistema. Nunca lanza excepciones:
    cualquier fallo se registra y se devuelve como False.
    """

    def __init__(
        self,
        command: Optional[list[str]] = None,
        timeout: float = DEFAULT_TIMEOUT_SECONDS,
        dry_run: bool = False,
    ):
        if command is None:
            command = DEFAULT_POWEROFF_COMMAND
        elif not self._is_valid_command(command):
            logger.warning(
                "power.poweroff_command invalido ({!r}); se usa {}",
                command,
                " ".join(DEFAULT_POWEROFF_COMMAND),
            )
            command = DEFAULT_POWEROFF_COMMAND

        self._command = list(command)
        self._timeout = timeout
        self._dry_run = dry_run

    @staticmethod
    def _is_valid_command(command) -> bool:
        return (
            isinstance(command, list)
            and len(command) > 0
            and all(isinstance(part, str) and part for part in command)
        )

    def configuration(self) -> dict:
        return {"command": list(self._command), "timeout": self._timeout, "dry_run": self._dry_run}

    def poweroff(self) -> bool:
        """True si el sistema acepto la orden de apagado; False en cualquier otro caso."""
        if self._dry_run:
            logger.warning(
                "SIMULACION: apagado solicitado pero NO ejecutado ('{}'). "
                "El modo simulado nunca apaga la maquina.",
                " ".join(self._command),
            )
            return True

        logger.info("Solicitando apagado ordenado: {}", " ".join(self._command))
        try:
            result = subprocess.run(
                self._command,
                capture_output=True,
                text=True,
                timeout=self._timeout,
            )
        except FileNotFoundError:
            logger.error("Apagado: comando no encontrado: {}", self._command[0])
            return False
        except subprocess.TimeoutExpired:
            logger.error("Apagado: '{}' no respondio en {}s", " ".join(self._command), self._timeout)
            return False
        except Exception as e:
            logger.error("Apagado: error inesperado al ejecutar el comando: {}", e)
            return False

        if result.returncode != 0:
            detail = (result.stderr or result.stdout or "").strip()
            logger.error(
                "Apagado rechazado por el sistema (codigo {}): {}",
                result.returncode,
                detail or "sin mensaje",
            )
            return False

        logger.info("Orden de apagado aceptada por el sistema")
        return True
