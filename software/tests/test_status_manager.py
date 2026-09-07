#
# SteamMachine UM790
#
# tests.test_status_manager
#

from status.status_manager import StatusManager


def test_snapshot_returns_empty_dict_for_none_or_empty_provider_name():
    manager = StatusManager()

    assert manager.snapshot(None) == {}
    assert manager.snapshot("") == {}


def test_snapshot_returns_empty_dict_for_unknown_provider_without_crashing():
    manager = StatusManager()

    assert manager.snapshot("NO_EXISTE") == {}


def test_snapshot_dispatches_to_the_registered_system_stats_provider():
    manager = StatusManager()

    snapshot = manager.snapshot("system_stats")

    # No se puede saber el valor exacto (depende de la maquina real),
    # pero si que tiene que traer estas claves, con o sin psutil.
    assert set(snapshot.keys()) == {"cpu_temp", "ram_used_gb", "ram_total_gb", "ram_percent"}
