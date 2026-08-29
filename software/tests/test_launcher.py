#
# SteamMachine UM790
#
# tests.test_launcher
#
# Usa procesos python reales de corta duracion en vez de steam/flatpak/lutris
# (no estan instalados en este entorno), para ejercitar BasePlugin de verdad
# (spawn, running(), stop(), status()) sin depender del sistema operativo real.
#

import sys
import time

import pytest

from launcher.launcher import Launcher


def sleep_command(seconds: float) -> list:
    return [sys.executable, "-c", f"import time; time.sleep({seconds})"]


@pytest.fixture
def platforms_config():
    return {
        "steam": {"command": sleep_command(2)},
        "retrodeck": {"command": ["este-binario-no-existe-xyz"]},
        # "hotd_remake" se omite a proposito: sin comando configurado.
    }


@pytest.fixture
def launcher(platforms_config):
    return Launcher(platforms_config)


# -- construccion -------------------------------------------------------


def test_platform_without_command_is_not_registered(launcher):
    # "hotd_remake" no tenia "command" en la config -> sin plugin, sin crash.
    assert launcher.launch("hotd_remake") is False
    assert launcher.running("hotd_remake") is False
    assert launcher.status("hotd_remake") is None


def test_unknown_platform_returns_false(launcher):
    assert launcher.launch("plataforma-inventada") is False


# -- lanzar / estado / parar --------------------------------------------


def test_launch_starts_a_real_process_and_reports_running(launcher):
    ok = launcher.launch("steam")
    assert ok is True
    assert launcher.running("steam") is True

    launcher.stop("steam")  # limpieza


def test_stop_terminates_the_process(launcher):
    launcher.launch("steam")
    assert launcher.running("steam") is True

    launcher.stop("steam")
    time.sleep(0.3)  # margen para que el SO complete la terminacion

    assert launcher.running("steam") is False


def test_launch_missing_executable_returns_false_without_raising(launcher):
    ok = launcher.launch("retrodeck")
    assert ok is False
    assert launcher.running("retrodeck") is False


def test_status_reports_name_running_and_pid(launcher):
    launcher.launch("steam")

    status = launcher.status("steam")

    assert status["name"] == "steam"
    assert status["running"] is True
    assert isinstance(status["pid"], int)

    launcher.stop("steam")


def test_status_without_platform_returns_all(launcher):
    status = launcher.status()
    assert set(status.keys()) == {"steam", "retrodeck"}  # hotd_remake no registrado


def test_running_without_platform_returns_all(launcher):
    running = launcher.running()
    assert running == {"steam": False, "retrodeck": False}
