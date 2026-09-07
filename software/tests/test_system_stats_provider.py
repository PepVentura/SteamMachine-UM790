#
# SteamMachine UM790
#
# tests.test_system_stats_provider
#

from status.system_stats_provider import NOT_AVAILABLE, SystemStatsProvider


class FakeVirtualMemory:
    def __init__(self, used, total, percent):
        self.used = used
        self.total = total
        self.percent = percent


class FakeTempReading:
    def __init__(self, current):
        self.current = current


class FakePsutil:
    def __init__(self, temps=None, mem=None, raise_on_temps=False, raise_on_mem=False):
        self._temps = temps if temps is not None else {}
        self._mem = mem
        self._raise_on_temps = raise_on_temps
        self._raise_on_mem = raise_on_mem

    def sensors_temperatures(self):
        if self._raise_on_temps:
            raise OSError("sin sensores en esta maquina")
        return self._temps

    def virtual_memory(self):
        if self._raise_on_mem:
            raise OSError("no se pudo leer memoria")
        return self._mem


# -- sin psutil disponible ----------------------------------------------


def test_snapshot_without_psutil_returns_not_available_for_everything():
    provider = SystemStatsProvider(psutil_module=None)

    snapshot = provider.snapshot()

    assert snapshot == {
        "cpu_temp": NOT_AVAILABLE,
        "ram_used_gb": NOT_AVAILABLE,
        "ram_total_gb": NOT_AVAILABLE,
        "ram_percent": NOT_AVAILABLE,
    }


# -- lecturas correctas ---------------------------------------------------


def test_snapshot_reads_cpu_temp_from_first_available_sensor():
    fake = FakePsutil(temps={"k10temp": [FakeTempReading(52.34)]})
    provider = SystemStatsProvider(psutil_module=fake)

    assert provider.snapshot()["cpu_temp"] == 52.3


def test_snapshot_reads_ram_used_total_and_percent_in_gb():
    fake = FakePsutil(mem=FakeVirtualMemory(used=8 * 1024**3, total=16 * 1024**3, percent=50.4))
    provider = SystemStatsProvider(psutil_module=fake)

    snapshot = provider.snapshot()

    assert snapshot["ram_used_gb"] == 8.0
    assert snapshot["ram_total_gb"] == 16.0
    assert snapshot["ram_percent"] == 50.0


# -- fallos de sensor no revientan el snapshot -----------------------------


def test_snapshot_returns_not_available_when_no_temperature_sensors_present():
    fake = FakePsutil(temps={})
    provider = SystemStatsProvider(psutil_module=fake)

    assert provider.snapshot()["cpu_temp"] == NOT_AVAILABLE


def test_snapshot_returns_not_available_when_sensors_temperatures_raises():
    fake = FakePsutil(raise_on_temps=True)
    provider = SystemStatsProvider(psutil_module=fake)

    assert provider.snapshot()["cpu_temp"] == NOT_AVAILABLE


def test_snapshot_returns_not_available_for_ram_when_virtual_memory_raises():
    fake = FakePsutil(raise_on_mem=True)
    provider = SystemStatsProvider(psutil_module=fake)

    snapshot = provider.snapshot()

    assert snapshot["ram_used_gb"] == NOT_AVAILABLE
    assert snapshot["ram_total_gb"] == NOT_AVAILABLE
    assert snapshot["ram_percent"] == NOT_AVAILABLE
