#
# SteamMachine UM790
#
# tests.test_oled_manager
#

import pytest

from devices.oled_manager import OLEDManager
from tests.fakes import FakeESP32Controller


@pytest.fixture
def esp32():
    return FakeESP32Controller()


@pytest.fixture
def oled(esp32):
    return OLEDManager(esp32)


def test_show_text_sends_oled_command(oled, esp32):
    oled.show_text("Steam")
    assert esp32.calls_of("oled") == [("Steam",)]


def test_show_status_sends_oled2_command(oled, esp32):
    oled.show_status("Steam", "Launching...")
    assert esp32.calls_of("oled_lines") == [("Steam", "Launching...")]


def test_show_logo_falls_back_to_uppercase_text(oled, esp32):
    # El protocolo no soporta iconos todavia (ver TODO en oled_manager.py).
    oled.show_logo("steam")
    assert esp32.calls_of("oled") == [("STEAM",)]


def test_clear_sends_oled_clear(oled, esp32):
    oled.clear()
    assert esp32.calls_of("clear_oled") == [()]


def test_sleep_clears_screen(oled, esp32):
    oled.show_text("Steam")
    esp32.calls.clear()

    oled.sleep()
    assert esp32.calls_of("clear_oled") == [()]


def test_sleep_twice_only_clears_once(oled, esp32):
    oled.show_text("Steam")
    esp32.calls.clear()

    oled.sleep()
    oled.sleep()
    assert esp32.calls_of("clear_oled") == [()]


def test_wake_restores_last_text(oled, esp32):
    oled.show_text("Steam")
    oled.sleep()
    esp32.calls.clear()

    oled.wake()
    assert esp32.calls_of("oled") == [("Steam",)]


def test_wake_restores_last_two_line_status(oled, esp32):
    oled.show_status("Steam", "Launching...")
    oled.sleep()
    esp32.calls.clear()

    oled.wake()
    assert esp32.calls_of("oled_lines") == [("Steam", "Launching...")]


def test_wake_without_prior_sleep_does_nothing(oled, esp32):
    oled.show_text("Steam")
    esp32.calls.clear()

    oled.wake()  # nunca durmio, no deberia mandar nada
    assert esp32.calls == []


def test_wake_with_no_prior_content_does_nothing(oled, esp32):
    # sleep() sin haber mostrado nunca nada antes -> nada que restaurar
    oled.sleep()
    esp32.calls.clear()

    oled.wake()
    assert esp32.calls == []


def test_show_text_after_sleep_clears_asleep_flag(oled, esp32):
    oled.show_text("Steam")
    oled.sleep()
    esp32.calls.clear()

    oled.show_text("RetroDECK")  # actividad normal, no una llamada a wake()
    oled.wake()  # ya no deberia estar "dormido": no debe reenviar nada

    assert esp32.calls_of("oled") == [("RetroDECK",)]
