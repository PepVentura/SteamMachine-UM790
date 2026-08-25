#
# SteamMachine UM790
#
# tests.test_panel_database
#

import json

import pytest

from database.panel_database import PanelDatabase


@pytest.fixture
def db_path(tmp_path):
    return tmp_path / "panel_database.json"


@pytest.fixture
def db(db_path):
    return PanelDatabase(db_path)


# -- load() -----------------------------------------------------------------


def test_load_missing_file_returns_empty_dict_without_crashing(db):
    result = db.load()
    assert result == {}


def test_load_reads_existing_file(db_path, db):
    db_path.write_text(json.dumps({"04A1C8B2": {"name": "Steam", "launcher": "steam", "led": "#0055FF", "icon": ""}}))

    result = db.load()

    assert result == {"04A1C8B2": {"name": "Steam", "launcher": "steam", "led": "#0055FF", "icon": ""}}


def test_load_malformed_json_returns_empty_dict_without_crashing(db_path, db):
    db_path.write_text("{ esto no es json valido")

    result = db.load()

    assert result == {}


# -- find() -----------------------------------------------------------------


def test_find_is_case_insensitive(db_path, db):
    db_path.write_text(json.dumps({"04A1C8B2": {"name": "Steam", "launcher": "steam", "led": "#0055FF", "icon": ""}}))
    db.load()

    assert db.find("04a1c8b2")["name"] == "Steam"
    assert db.find("04A1C8B2")["name"] == "Steam"


def test_find_unknown_uid_returns_none(db):
    db.load()
    assert db.find("DEADBEEF") is None


# -- add() / remove() / update() ---------------------------------------------


def test_add_then_find(db):
    db.load()
    db.add("04B2D9C3", name="RetroDECK", launcher="retrodeck", led="#8800FF", icon="retrodeck.png")

    panel = db.find("04b2d9c3")
    assert panel == {"name": "RetroDECK", "launcher": "retrodeck", "led": "#8800FF", "icon": "retrodeck.png"}


def test_remove_deletes_panel(db):
    db.load()
    db.add("04B2D9C3", name="RetroDECK", launcher="retrodeck", led="#8800FF")

    db.remove("04b2d9c3")

    assert db.find("04B2D9C3") is None


def test_remove_unknown_uid_does_not_raise(db):
    db.load()
    db.remove("DEADBEEF")  # no debe lanzar excepcion aunque no exista


def test_update_modifies_existing_fields_only(db):
    db.load()
    db.add("04B2D9C3", name="RetroDECK", launcher="retrodeck", led="#8800FF", icon="retrodeck.png")

    db.update("04b2d9c3", led="#FF00FF")

    panel = db.find("04B2D9C3")
    assert panel["led"] == "#FF00FF"
    assert panel["name"] == "RetroDECK"  # el resto de campos no se toca


def test_update_unknown_uid_does_not_raise(db):
    db.load()
    db.update("DEADBEEF", led="#FF00FF")  # no debe lanzar excepcion


# -- all() --------------------------------------------------------------


def test_all_top_level_copy_does_not_leak_new_keys_into_internal_state(db):
    db.load()
    db.add("04B2D9C3", name="RetroDECK", launcher="retrodeck", led="#8800FF")

    snapshot = db.all()
    snapshot["04FFFFFF"] = {"name": "Intruso", "launcher": "x", "led": "#000000"}

    assert db.find("04FFFFFF") is None  # anadir una clave nueva al snapshot no toca la base real


def test_all_nested_panel_dicts_are_shared_references(db):
    # all() hace "dict(self._panels)": copia superficial. Anadir/quitar
    # claves de nivel superior no afecta al original (ver test de arriba),
    # pero mutar el dict de un panel existente SI lo afecta, porque es la
    # misma referencia. Se deja documentado aqui para que quede constancia
    # del comportamiento real en vez de asumir una copia profunda.
    db.load()
    db.add("04B2D9C3", name="RetroDECK", launcher="retrodeck", led="#8800FF")

    snapshot = db.all()
    snapshot["04B2D9C3"]["led"] = "#000000"

    assert db.find("04B2D9C3")["led"] == "#000000"


# -- save() / round-trip -----------------------------------------------------


def test_save_then_reload_round_trips(db_path):
    db1 = PanelDatabase(db_path)
    db1.load()
    db1.add("04A1C8B2", name="Steam", launcher="steam", led="#0055FF", icon="steam.png")
    db1.save()

    db2 = PanelDatabase(db_path)
    db2.load()

    assert db2.find("04A1C8B2") == {"name": "Steam", "launcher": "steam", "led": "#0055FF", "icon": "steam.png"}
