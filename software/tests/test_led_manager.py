#
# SteamMachine UM790
#
# tests.test_led_manager
#

import time

import pytest

from devices.led_manager import LEDManager, _hex_to_rgb, _rgb_to_hex
from tests.fakes import FakeESP32Controller


@pytest.fixture
def esp32():
    return FakeESP32Controller()


@pytest.fixture
def leds(esp32):
    return LEDManager(esp32)


# -- Comandos directos ----------------------------------------------------


def test_set_color_sends_led_command(leds, esp32):
    leds.set_color("#00FF00")
    assert esp32.calls_of("set_led") == [("#00FF00",)]


def test_set_brightness_sends_brightness_command(leds, esp32):
    leds.set_brightness(128)
    assert esp32.calls_of("set_brightness") == [(128,)]


def test_animation_sends_animation_command(leds, esp32):
    leds.animation("launch")
    assert esp32.calls_of("animation") == [("launch",)]


def test_animation_with_unknown_name_still_forwards_it(leds, esp32, caplog):
    # El nombre no esta en la lista de 04_Communication_Protocol.md, pero se
    # envia igual: el firmware es quien decide si lo reconoce.
    leds.animation("disco")
    assert esp32.calls_of("animation") == [("disco",)]


def test_off_sends_black(leds, esp32):
    leds.off()
    assert esp32.calls_of("set_led") == [("#000000",)]


# -- flash() ----------------------------------------------------------------


def test_flash_alternates_color_and_restore(leds, esp32):
    leds.set_color("#0055FF")  # color de reposo actual
    esp32.calls.clear()

    leds.flash("#FF0000", times=2, interval=0.02)
    time.sleep(0.02 * 2 * 2 + 0.1)  # 2 ciclos x (color+restore) + margen

    colors = [args[0] for args in esp32.calls_of("set_led")]
    assert colors == ["#FF0000", "#0055FF", "#FF0000", "#0055FF"]


def test_flash_restores_to_explicit_color_when_given(leds, esp32):
    leds.set_color("#0055FF")
    esp32.calls.clear()

    leds.flash("#FF0000", times=1, interval=0.02, restore_to="#00FF00")
    time.sleep(0.02 * 2 + 0.1)

    colors = [args[0] for args in esp32.calls_of("set_led")]
    assert colors == ["#FF0000", "#00FF00"]


# -- fade() -------------------------------------------------------------


def test_fade_ends_exactly_on_target_color(leds, esp32):
    leds.set_color("#000000")
    esp32.calls.clear()

    leds.fade("#FF0000", duration=0.05, steps=5)
    time.sleep(0.15)

    colors = [args[0] for args in esp32.calls_of("set_led")]
    assert len(colors) == 5
    assert colors[-1] == "#FF0000"


def test_fade_interpolates_monotonically(leds, esp32):
    leds.set_color("#000000")
    esp32.calls.clear()

    leds.fade("#FF0000", duration=0.05, steps=5)
    time.sleep(0.15)

    red_component = [_hex_to_rgb(args[0])[0] for args in esp32.calls_of("set_led")]
    assert red_component == sorted(red_component)  # sube de forma monotona hacia 255


# -- Cancelacion entre animaciones -----------------------------------------


def test_new_command_cancels_ongoing_fade(leds, esp32):
    leds.set_color("#000000")
    leds.fade("#FF0000", duration=1.0, steps=100)  # animacion larga
    time.sleep(0.05)

    leds.set_color("#00FF00")  # deberia cortar el fade en marcha

    calls_at_cutoff = len(esp32.calls)
    time.sleep(0.3)  # si el fade no se cancelo, seguiria mandando comandos aqui

    assert esp32.calls[-1] == ("set_led", ("#00FF00",))
    assert len(esp32.calls) == calls_at_cutoff  # nada mas se envio tras el corte


def test_new_command_cancels_ongoing_flash(leds, esp32):
    leds.flash("#FF0000", times=50, interval=0.05)  # parpadeo largo
    time.sleep(0.03)

    leds.animation("idle")

    assert esp32.calls_of("animation") == [("idle",)]
    # el ultimo comando enviado debe ser la animacion, no un color del flash cancelado
    assert esp32.calls[-1][0] == "animation"


# -- Helpers de color -----------------------------------------------------


def test_hex_rgb_roundtrip():
    assert _rgb_to_hex(_hex_to_rgb("#0055FF")) == "#0055FF"


def test_rgb_to_hex_clamps_out_of_range_values():
    assert _rgb_to_hex((300, -10, 128)) == "#FF0080"
