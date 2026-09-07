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
from tests.fakes import (
    FakeDatabase,
    FakeLauncher,
    FakeLEDManager,
    FakeOLEDManager,
    FakeProcessWatcher,
    FakeStatusManager,
)


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


def test_on_tag_detected_panel_with_profile_shows_profile_idle_lines(app):
    # docs/12_Profile_System.md: un panel con "profile" usa oled.idle
    # del perfil (hasta 2 lineas) en vez de panel["name"].
    app._database = FakeDatabase(
        {
            "04A1C8B2": {
                "name": "Steam",
                "profile": "STEAM",
                "launcher": "steam",
                "led": "#0055FF",
            },
        }
    )
    app._profiles.load()  # perfiles reales de config/profiles (incluye steam.json)

    app._on_tag_detected("04A1C8B2")

    assert app._oled.calls_of("show_status") == [("STEAM MACHINE", "Steam")]
    assert app._leds.calls_of("fade") == [("#0055FF", 0.6, 20)]


def test_on_tag_detected_panel_with_unknown_profile_id_falls_back_to_name(app):
    # Retrocompatibilidad: si "profile" no resuelve a nada cargado,
    # se comporta exactamente igual que un panel sin "profile".
    app._database = FakeDatabase(
        {
            "04A1C8B2": {
                "name": "Steam",
                "profile": "NO_EXISTE_TODAVIA",
                "launcher": "steam",
                "led": "#0055FF",
            },
        }
    )
    # app._profiles ya es un ProfileManager() vacio (sin .load()), como en el resto de tests.

    app._on_tag_detected("04A1C8B2")

    assert app._oled.calls_of("show_text") == [("Steam",)]


def test_on_tag_detected_retro_panel_shows_profile_idle_lines(app):
    # Segundo perfil migrado (docs/12_Profile_System.md): mismo
    # mecanismo generico que STEAM, con su propio color e idle lines.
    app._database = FakeDatabase(
        {
            "E76DC103": {
                "name": "RetroDECK",
                "profile": "RETRO",
                "launcher": "retrodeck",
                "led": "#8800FF",
            },
        }
    )
    app._profiles.load()  # perfiles reales de config/profiles (incluye retro.json)

    app._on_tag_detected("E76DC103")

    assert app._oled.calls_of("show_status") == [("STEAM MACHINE", "RETRO")]
    assert app._leds.calls_of("fade") == [("#8800FF", 0.6, 20)]


def test_on_tag_detected_disparos_panel_shows_profile_idle_lines(app):
    # DISPAROS: el panel Zombies muestra la identidad del PERFIL
    # ("DISPAROS"), no un juego concreto - el boton abre siempre Steam
    # Big Picture (decidido 2026-09-03: la lista de juegos es una
    # Coleccion de Steam organizada a mano, no un menu del proyecto).
    app._database = FakeDatabase(
        {
            "112FC103": {
                "name": "Zombies",
                "profile": "DISPAROS",
                "launcher": "steam",
                "led": "#FF3300",
            },
        }
    )
    app._profiles.load()

    app._on_tag_detected("112FC103")

    assert app._oled.calls_of("show_status") == [("STEAM MACHINE", "DISPAROS")]
    assert app._leds.calls_of("fade") == [("#FF3300", 0.6, 20)]


def test_on_button_disparos_panel_always_opens_steam_big_picture(app):
    # Decidido 2026-09-03: DISPAROS ya no lanza un juego concreto por
    # panel - siempre abre Steam Big Picture; el usuario navega su
    # propia Coleccion de Steam con los juegos de disparos desde ahi.
    app._database = FakeDatabase(
        {
            "112FC103": {
                "name": "Zombies",
                "profile": "DISPAROS",
                "launcher": "steam",
                "led": "#FF3300",
            },
        }
    )
    app._profiles.load()
    app._on_tag_detected("112FC103")

    app._on_button()

    assert app._launcher.launch_calls == ["steam"]


def test_on_tag_detected_maintenance_panel_fills_template_from_status_provider(app):
    # MAINTENANCE (docs/12_Profile_System.md): perfil informativo, con
    # oled.idle_template relleno a partir del StatusProvider indicado
    # en "status_provider". Foto fija tomada al detectar el panel, no
    # en vivo (ver "Pendiente" del documento de diseno).
    app._database = FakeDatabase(
        {
            "AABBCCDD": {
                "name": "Maintenance",
                "profile": "MAINTENANCE",
                "launcher": None,
                "led": "#FFFFFF",
            },
        }
    )
    app._profiles.load()
    app._status = FakeStatusManager(
        {"system_stats": {"cpu_temp": 42.0, "ram_percent": 55, "ram_used_gb": 7.2, "ram_total_gb": 16.0}}
    )

    app._on_tag_detected("AABBCCDD")

    assert app._oled.calls_of("show_status") == [("CPU 42.0C RAM55%", "7.2/16.0GB")]
    assert app._leds.calls_of("fade") == [("#FFFFFF", 0.6, 20)]


def test_on_tag_detected_maintenance_falls_back_to_static_idle_if_template_variable_missing(app):
    # Si el StatusProvider no trae una variable que pide la plantilla
    # (p.ej. psutil no instalado -> "N/D" en vez de un numero no rompe
    # el .format, pero una clave que directamente no exista en el dict
    # si podria) se cae al oled.idle estatico en vez de reventar.
    app._database = FakeDatabase(
        {
            "AABBCCDD": {
                "name": "Maintenance",
                "profile": "MAINTENANCE",
                "launcher": None,
                "led": "#FFFFFF",
            },
        }
    )
    app._profiles.load()
    app._status = FakeStatusManager({"system_stats": {}})  # sin ninguna clave

    app._on_tag_detected("AABBCCDD")

    assert app._oled.calls_of("show_status") == [("STEAM MACHINE", "MAINTENANCE")]


def test_on_button_maintenance_panel_without_launcher_does_nothing(app):
    # launcher=null a proposito (perfil informativo, no lanza nada) -
    # no debe intentar Launcher.launch(None) ni mostrar animacion de
    # error (eso daria a entender que algo ha fallado).
    app._database = FakeDatabase(
        {
            "AABBCCDD": {
                "name": "Maintenance",
                "profile": "MAINTENANCE",
                "launcher": None,
                "led": "#FFFFFF",
            },
        }
    )
    app._on_tag_detected("AABBCCDD")

    app._on_button()

    assert app._launcher.launch_calls == []
    assert app._leds.calls_of("animation") == []


# -- tag retirado -----------------------------------------------------------


def test_on_tag_removed_clears_pending_sleeps_oled_and_fades_to_idle(app):
    app._pending_panel = {"name": "Steam", "launcher": "steam", "led": "#0055FF"}

    app._on_tag_removed()

    assert app._pending_panel is None
    assert app._oled.calls_of("sleep") == [()]
    assert app._leds.calls_of("fade") == [(IDLE_COLOR, 0.6, 20)]


# -- AUTO (docs/12_Profile_System.md) ----------------------------------------


def test_on_tag_removed_starts_the_process_watcher(app):
    app._process_watcher = FakeProcessWatcher()

    app._on_tag_removed()

    assert app._process_watcher.start_calls == 1


def test_on_tag_detected_stops_the_process_watcher_even_for_unknown_uid(app):
    # Un panel fisico manda siempre por encima de AUTO - incluso si el
    # UID resulta ser desconocido, ProcessWatcher se para igualmente.
    app._process_watcher = FakeProcessWatcher()

    app._on_tag_detected("FFFFFFFF")

    assert app._process_watcher.stop_calls == 1


def test_on_auto_profile_changed_none_sleeps_oled_and_fades_to_idle(app):
    app._on_auto_profile_changed(None)

    assert app._oled.calls_of("sleep") == [()]
    assert app._leds.calls_of("fade") == [(IDLE_COLOR, 0.6, 20)]


def test_on_auto_profile_changed_applies_the_detected_profiles_oled_and_led(app):
    app._profiles.load()  # perfiles reales de config/profiles (incluye steam.json)

    app._on_auto_profile_changed("STEAM")

    assert app._oled.calls_of("show_status") == [("STEAM MACHINE", "Steam")]
    assert app._leds.calls_of("fade") == [("#0055FF", 0.6, 20)]


def test_on_auto_profile_changed_unknown_profile_id_does_nothing(app):
    # Defensivo: si ProcessWatcher devolviera un id que ya no existe
    # (perfil borrado entre medias, etc.), no debe reventar ni tocar
    # la OLED/LEDs con datos a medias.
    app._on_auto_profile_changed("NO_EXISTE")

    assert app._oled.calls_of("show_status") == []
    assert app._oled.calls_of("sleep") == []


def test_build_auto_match_table_reads_auto_match_from_loaded_profiles(app):
    app._profiles.load()  # perfiles reales (steam.json: auto_match ["steam"])

    table = app._build_auto_match_table()

    assert table.get("steam") == "STEAM"
    assert table.get("retroarch") == "RETRO"


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
