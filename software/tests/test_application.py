#
# SteamMachine UM790
#
# tests.test_application
#
# Prueba la logica de eventos de Application (04_Communication_Protocol.md,
# "Secuencia tipica") sin pasar por initialize(): se inyectan dobles
# directamente en los atributos privados en vez de crear un ESP32Controller
# o un Launcher reales. Es la misma frontera que ya usamos para
# LEDManager/OLEDManager, aplicada un nivel mas arriba.
#

import pytest

from core.application import Application, IDLE_COLOR
from tests.fakes import FakeDatabase, FakeLauncher, FakeLEDManager, FakeOLEDManager


@pytest.fixture
def app():
    application = Application()
    application._oled = FakeOLEDManager()
    application._leds = FakeLEDManager()
    application._launcher = FakeLauncher()
    application._database = FakeDatabase(
        {
            "04A1C8B2": {"name": "Steam", "launcher": "steam", "led": "#0055FF", "icon": ""},
        }
    )
    return application


# -- boot ---------------------------------------------------------------


def test_on_boot_shows_welcome_text_and_idle_color(app):
    app._on_boot(firmware="1.0.0")

    assert app._oled.calls_of("show_text") == [("SteamMachine",)]
    assert app._leds.calls_of("set_color") == [(IDLE_COLOR,)]


# -- tag detectado --------------------------------------------------------


def test_on_tag_detected_known_panel_sets_pending_and_updates_ui(app):
    app._on_tag_detected("04A1C8B2")

    assert app._pending_panel == {"name": "Steam", "launcher": "steam", "led": "#0055FF", "icon": ""}
    assert app._oled.calls_of("show_text") == [("Steam",)]
    assert app._leds.calls_of("fade") == [("#0055FF", 0.6, 20)]


def test_on_tag_detected_unknown_uid_flashes_red_and_clears_pending(app):
    app._pending_panel = {"name": "Steam", "launcher": "steam", "led": "#0055FF"}  # panel previo

    app._on_tag_detected("FFFFFFFF")

    assert app._pending_panel is None
    assert app._oled.calls_of("show_status") == [("Panel", "no reconocido")]
    flash_calls = app._leds.calls_of("flash")
    assert flash_calls == [("#FF0000", 3, 0.15, IDLE_COLOR)]


# -- tag retirado -----------------------------------------------------------


def test_on_tag_removed_clears_pending_sleeps_oled_and_fades_to_idle(app):
    app._pending_panel = {"name": "Steam", "launcher": "steam", "led": "#0055FF"}

    app._on_tag_removed()

    assert app._pending_panel is None
    assert app._oled.calls_of("sleep") == [()]
    assert app._leds.calls_of("fade") == [(IDLE_COLOR, 0.6, 20)]


# -- boton ------------------------------------------------------------------


def test_on_button_without_pending_panel_does_nothing(app):
    app._pending_panel = None

    app._on_button()

    assert app._launcher.launch_calls == []
    assert app._leds.calls == []
    assert app._oled.calls == []


def test_on_button_launches_platform_and_shows_success_animation(app):
    app._pending_panel = {"name": "Steam", "launcher": "steam", "led": "#0055FF"}
    app._launcher.launch_result = True

    app._on_button()

    assert app._launcher.launch_calls == ["steam"]
    assert app._oled.calls_of("show_status") == [("Steam", "Launching...")]
    animations = app._leds.calls_of("animation")
    assert animations == [("launch",), ("success",)]


def test_on_button_launch_failure_shows_error_animation(app):
    app._pending_panel = {"name": "Steam", "launcher": "steam", "led": "#0055FF"}
    app._launcher.launch_result = False

    app._on_button()

    animations = app._leds.calls_of("animation")
    assert animations == [("launch",), ("error",)]


def test_on_button_uses_pending_panels_launcher_key(app):
    app._pending_panel = {"name": "RetroDECK", "launcher": "retrodeck", "led": "#8800FF"}

    app._on_button()

    assert app._launcher.launch_calls == ["retrodeck"]
