#
# SteamMachine UM790
#
# tests.test_power_manager
#
# Igual que test_launcher.py: procesos python reales de corta duracion en
# vez de "systemctl poweroff" (que apagaria la maquina que corre los tests).
#

import sys

from core.power_manager import DEFAULT_POWEROFF_COMMAND, PowerManager


def python_command(code: str) -> list:
    return [sys.executable, "-c", code]


def test_poweroff_returns_true_when_command_succeeds():
    manager = PowerManager(python_command("import sys; sys.exit(0)"))

    assert manager.poweroff() is True


def test_poweroff_returns_false_when_system_rejects_it():
    # Caso real: un inhibitor lock (p.ej. rpm-ostree actualizando) hace que
    # systemctl devuelva un codigo distinto de 0.
    manager = PowerManager(python_command("import sys; sys.stderr.write('Operation inhibited'); sys.exit(1)"))

    assert manager.poweroff() is False


def test_poweroff_returns_false_without_raising_when_binary_is_missing():
    manager = PowerManager(["este-binario-no-existe-xyz", "poweroff"])

    assert manager.poweroff() is False


def test_poweroff_returns_false_on_timeout():
    manager = PowerManager(python_command("import time; time.sleep(5)"), timeout=0.3)

    assert manager.poweroff() is False


def test_default_command_is_systemctl_poweroff():
    assert PowerManager().configuration()["command"] == ["systemctl", "poweroff"]
    assert DEFAULT_POWEROFF_COMMAND == ["systemctl", "poweroff"]


def test_custom_command_from_config_is_used():
    manager = PowerManager(["loginctl", "poweroff"])

    assert manager.configuration()["command"] == ["loginctl", "poweroff"]


def test_invalid_command_falls_back_to_default_instead_of_crashing():
    # config.json editado a mano con algo que no es una lista de cadenas.
    for bad in ("systemctl poweroff", [], [""], [1, 2], {"command": "x"}):
        assert PowerManager(bad).configuration()["command"] == ["systemctl", "poweroff"]


def test_command_is_never_run_through_a_shell():
    # Una cadena con metacaracteres de shell es simplemente un ejecutable
    # inexistente, no se interpreta.
    manager = PowerManager(["echo hola; touch /tmp/no_debe_existir_steammachine"])

    assert manager.poweroff() is False


def test_dry_run_never_executes_the_command_but_reports_success(tmp_path):
    # Modo simulado: el comando podria apagar la maquina de desarrollo.
    marker = tmp_path / "no_deberia_existir"
    manager = PowerManager(
        python_command(f"open({str(marker)!r}, 'w').write('ejecutado')"),
        dry_run=True,
    )

    assert manager.poweroff() is True
    assert not marker.exists()
    assert manager.configuration()["dry_run"] is True


def test_without_dry_run_the_command_really_runs(tmp_path):
    marker = tmp_path / "debe_existir"
    manager = PowerManager(python_command(f"open({str(marker)!r}, 'w').write('ok')"))

    assert manager.poweroff() is True
    assert marker.read_text() == "ok"
