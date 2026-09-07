#
# SteamMachine UM790
#
# core.process_watcher
#
# docs/12_Profile_System.md, perfil AUTO: cuando no hay panel fisico
# puesto, vigila que procesos corren en Bazzite (por nombre, via
# psutil) y avisa con el id de perfil correspondiente - mismo mecanismo
# de "cargar perfil" que un panel fisico, con un proceso detectado como
# disparador en vez de un tag NFC.
#
# No decide el mapeo proceso -> perfil por si mismo: recibe una tabla
# ya construida (match_table: {substring_en_minusculas: profile_id}),
# que Application arma a partir del campo "auto_match" de cada perfil
# (ver profiles/steam.json / retro.json). Mantiene el mismo patron de
# psutil inyectable que SystemStatsProvider, para poder testear sin
# depender de los procesos reales de la maquina.
#

from __future__ import annotations

import threading
from typing import Callable, Optional

from core.logger import get_logger

logger = get_logger()

DEFAULT_POLL_INTERVAL_SECONDS = 5.0
_UNSET = object()


class ProcessWatcher:
    def __init__(
        self,
        match_table: dict[str, str],
        on_profile_changed: Callable[[Optional[str]], None],
        poll_interval: float = DEFAULT_POLL_INTERVAL_SECONDS,
        psutil_module=_UNSET,
    ):
        self._match_table = match_table
        self._on_profile_changed = on_profile_changed
        self._poll_interval = poll_interval

        if psutil_module is _UNSET:
            try:
                import psutil as psutil_module
            except ImportError:
                logger.warning("psutil no esta instalado; ProcessWatcher no detectara nada")
                psutil_module = None
        self._psutil = psutil_module

        self._thread: threading.Thread | None = None
        self._stop_event = threading.Event()
        self._last_profile = _UNSET  # fuerza el primer aviso, sea cual sea

    # -- ciclo de vida ----------------------------------------------------

    def start(self) -> None:
        if self._thread and self._thread.is_alive():
            return
        self._stop_event.clear()
        self._last_profile = _UNSET
        self._thread = threading.Thread(target=self._loop, daemon=True)
        self._thread.start()

    def stop(self) -> None:
        self._stop_event.set()
        if self._thread:
            self._thread.join(timeout=1.0)
        self._thread = None

    def _loop(self) -> None:
        while not self._stop_event.is_set():
            self.check_once()
            self._stop_event.wait(self._poll_interval)

    # -- deteccion ----------------------------------------------------------

    def check_once(self) -> Optional[str]:
        """
        Hace una lectura y, si el perfil detectado cambio desde la
        ultima vez, llama a on_profile_changed(). Publico (no solo
        para _loop()) para poder testear sin threads ni esperas.
        """
        profile_id = self._detect_active_profile()
        if profile_id != self._last_profile:
            self._last_profile = profile_id
            self._on_profile_changed(profile_id)
        return profile_id

    def _detect_active_profile(self) -> Optional[str]:
        if not self._psutil or not self._match_table:
            return None
        try:
            names = [
                (p.info.get("name") or "").lower()
                for p in self._psutil.process_iter(["name"])
            ]
        except Exception as e:
            logger.warning("No se pudo listar procesos: {}", e)
            return None

        for substring, profile_id in self._match_table.items():
            if any(substring in name for name in names):
                return profile_id
        return None
