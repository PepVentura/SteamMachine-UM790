#
# SteamMachine UM790
#
# tests.test_process_watcher
#

import time

from core.process_watcher import ProcessWatcher


class FakeProcessInfo:
    def __init__(self, name):
        self.info = {"name": name}


class FakePsutil:
    def __init__(self, process_names=None, raise_on_iter=False):
        self._process_names = process_names or []
        self._raise_on_iter = raise_on_iter

    def process_iter(self, attrs=None):
        if self._raise_on_iter:
            raise OSError("no se pudo listar procesos")
        return [FakeProcessInfo(name) for name in self._process_names]


def make_watcher(process_names, match_table, on_changed):
    fake_psutil = FakePsutil(process_names=process_names)
    return ProcessWatcher(match_table, on_changed, psutil_module=fake_psutil)


# -- check_once() (sin hilos, deterministico) --------------------------------


def test_check_once_matches_profile_by_substring_case_insensitive():
    calls = []
    watcher = make_watcher(["Steam.exe", "systemd"], {"steam": "STEAM"}, calls.append)

    result = watcher.check_once()

    assert result == "STEAM"
    assert calls == ["STEAM"]


def test_check_once_returns_none_when_nothing_matches():
    calls = []
    watcher = make_watcher(["systemd", "bash"], {"steam": "STEAM"}, calls.append)

    result = watcher.check_once()

    assert result is None
    assert calls == [None]


def test_check_once_only_calls_callback_when_the_profile_changes():
    calls = []
    watcher = make_watcher(["steam"], {"steam": "STEAM"}, calls.append)

    watcher.check_once()
    watcher.check_once()
    watcher.check_once()

    assert calls == ["STEAM"]  # solo la primera vez


def test_check_once_calls_callback_again_when_profile_changes_to_a_different_one():
    calls = []
    fake_psutil = FakePsutil(process_names=["steam"])
    watcher = ProcessWatcher({"steam": "STEAM", "retroarch": "RETRO"}, calls.append, psutil_module=fake_psutil)

    watcher.check_once()
    fake_psutil._process_names = ["retroarch"]
    watcher.check_once()

    assert calls == ["STEAM", "RETRO"]


def test_check_once_without_psutil_returns_none_without_crashing():
    calls = []
    watcher = ProcessWatcher({"steam": "STEAM"}, calls.append, psutil_module=None)

    result = watcher.check_once()

    assert result is None
    assert calls == [None]


def test_check_once_with_empty_match_table_returns_none_without_listing_processes():
    fake_psutil = FakePsutil(process_names=["steam"])
    calls = []
    watcher = ProcessWatcher({}, calls.append, psutil_module=fake_psutil)

    result = watcher.check_once()

    assert result is None
    assert calls == [None]


def test_check_once_survives_process_iter_raising():
    calls = []
    fake_psutil = FakePsutil(raise_on_iter=True)
    watcher = ProcessWatcher({"steam": "STEAM"}, calls.append, psutil_module=fake_psutil)

    result = watcher.check_once()

    assert result is None
    assert calls == [None]


# -- start()/stop() (hilo real, poll muy corto) ------------------------------


def test_start_polls_in_the_background_and_stop_ends_it_cleanly():
    calls = []
    fake_psutil = FakePsutil(process_names=["steam"])
    watcher = ProcessWatcher(
        {"steam": "STEAM"}, calls.append, poll_interval=0.02, psutil_module=fake_psutil
    )

    watcher.start()
    time.sleep(0.08)
    watcher.stop()

    assert calls[0] == "STEAM"
    assert watcher._thread is None


def test_start_is_idempotent_if_already_running():
    fake_psutil = FakePsutil(process_names=[])
    watcher = ProcessWatcher({}, lambda p: None, poll_interval=0.05, psutil_module=fake_psutil)

    watcher.start()
    first_thread = watcher._thread
    watcher.start()  # no debe crear un segundo hilo

    assert watcher._thread is first_thread
    watcher.stop()
