#
# SteamMachine UM790
#
# tests.test_profile_manager
#

import json

import pytest

from core.profile_manager import ProfileManager


@pytest.fixture
def profiles_dir(tmp_path):
    return tmp_path / "profiles"


@pytest.fixture
def manager(profiles_dir):
    return ProfileManager(profiles_dir)


def write_profile(profiles_dir, filename, data):
    profiles_dir.mkdir(exist_ok=True)
    (profiles_dir / filename).write_text(json.dumps(data), encoding="utf-8")


# -- load() -------------------------------------------------------------


def test_load_missing_folder_returns_empty_dict_without_crashing(manager):
    result = manager.load()
    assert result == {}


def test_load_reads_every_json_file_in_the_folder(profiles_dir, manager):
    write_profile(profiles_dir, "steam.json", {"id": "STEAM", "launcher": "steam"})
    write_profile(profiles_dir, "retro.json", {"id": "RETRO", "launcher": "retrodeck"})

    result = manager.load()

    assert set(result.keys()) == {"STEAM", "RETRO"}
    assert result["STEAM"]["launcher"] == "steam"


def test_load_uses_filename_as_id_when_id_field_is_missing(profiles_dir, manager):
    write_profile(profiles_dir, "maintenance.json", {"launcher": "none"})

    result = manager.load()

    assert "maintenance" in result


def test_load_skips_malformed_json_without_crashing(profiles_dir, manager):
    profiles_dir.mkdir(exist_ok=True)
    (profiles_dir / "broken.json").write_text("{ esto no es json", encoding="utf-8")
    write_profile(profiles_dir, "steam.json", {"id": "STEAM", "launcher": "steam"})

    result = manager.load()

    assert set(result.keys()) == {"STEAM"}


# -- get() ----------------------------------------------------------------


def test_get_returns_none_for_empty_or_none_profile_id(profiles_dir, manager):
    write_profile(profiles_dir, "steam.json", {"id": "STEAM", "launcher": "steam"})
    manager.load()

    assert manager.get(None) is None
    assert manager.get("") is None


def test_get_returns_none_and_warns_for_unknown_profile_id(profiles_dir, manager):
    manager.load()
    assert manager.get("DOES_NOT_EXIST") is None


def test_get_returns_the_full_profile_dict(profiles_dir, manager):
    write_profile(
        profiles_dir,
        "steam.json",
        {"id": "STEAM", "launcher": "steam", "oled": {"idle": ["STEAM MACHINE", "Steam"]}},
    )
    manager.load()

    profile = manager.get("STEAM")

    assert profile["launcher"] == "steam"
    assert profile["oled"]["idle"] == ["STEAM MACHINE", "Steam"]


# -- all() ------------------------------------------------------------------


def test_all_returns_a_copy_not_the_internal_dict(profiles_dir, manager):
    write_profile(profiles_dir, "steam.json", {"id": "STEAM", "launcher": "steam"})
    manager.load()

    result = manager.all()
    result["STEAM"] = "mutated"

    assert manager.get("STEAM")["launcher"] == "steam"


# -- carpeta real de config/profiles ------------------------------------
#
# A diferencia de los tests de arriba (carpeta sintetica en tmp_path),
# estos cargan la carpeta real del proyecto (ProfileManager() con su
# path por defecto) para detectar errores de tipeo o ficheros que
# falten, sin necesidad de arrancar la Application completa.


def test_default_profiles_directory_has_steam_and_retro():
    manager = ProfileManager()
    manager.load()

    steam = manager.get("STEAM")
    retro = manager.get("RETRO")

    assert steam is not None and steam["launcher"] == "steam"
    assert retro is not None and retro["launcher"] == "retrodeck"
    assert len(steam["oled"]["idle"]) <= 2
    assert len(retro["oled"]["idle"]) <= 2


def test_default_profiles_directory_has_disparos_with_games_catalog():
    # DISPAROS agrupa varios juegos (games[]) bajo un unico panel fisico.
    # Decidido 2026-09-03: el boton siempre abre Steam Big Picture
    # (launcher del perfil = "steam"); la lista real de juegos vive en
    # una Coleccion de Steam organizada a mano, games[] es solo un
    # registro de referencia, no lo lee ningun codigo todavia.
    manager = ProfileManager()
    manager.load()

    disparos = manager.get("DISPAROS")

    assert disparos is not None
    assert disparos["launcher"] == "steam"
    assert len(disparos["oled"]["idle"]) <= 2
    game_launchers = {g["launcher"] for g in disparos["games"]}
    assert game_launchers == {"hotd_remake", "hotd2_remake"}
