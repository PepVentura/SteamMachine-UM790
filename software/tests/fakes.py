#
# SteamMachine UM790
#
# tests.fakes
#
# Doble de pruebas para ESP32Controller: registra cada comando enviado
# en vez de hablar por un puerto serie real. Los managers (LEDManager,
# OLEDManager) solo conocen esta interfaz, nunca el puerto serie en si
# (misma frontera que respeta el codigo de produccion).
#


class FakeESP32Controller:
    def __init__(self):
        self.calls: list[tuple[str, tuple]] = []

    def _record(self, name, *args):
        self.calls.append((name, args))

    def oled(self, text):
        self._record("oled", text)

    def oled_lines(self, line1, line2):
        self._record("oled_lines", line1, line2)

    def clear_oled(self):
        self._record("clear_oled")

    def set_led(self, color):
        self._record("set_led", color)

    def set_brightness(self, value):
        self._record("set_brightness", value)

    def animation(self, name):
        self._record("animation", name)

    def restart(self):
        self._record("restart")

    def request_status(self):
        self._record("request_status")

    # -- Ayudas para las aserciones de los tests ------------------------

    def calls_of(self, name):
        return [args for call_name, args in self.calls if call_name == name]


class FakeOLEDManager:
    """Doble de OLEDManager para tests de Application: solo registra llamadas."""

    def __init__(self):
        self.calls: list[tuple[str, tuple]] = []

    def show_text(self, text):
        self.calls.append(("show_text", (text,)))

    def show_status(self, line1, line2):
        self.calls.append(("show_status", (line1, line2)))

    def show_logo(self, platform):
        self.calls.append(("show_logo", (platform,)))

    def clear(self):
        self.calls.append(("clear", ()))

    def sleep(self):
        self.calls.append(("sleep", ()))

    def wake(self):
        self.calls.append(("wake", ()))

    def calls_of(self, name):
        return [args for call_name, args in self.calls if call_name == name]


class FakeLEDManager:
    """Doble de LEDManager para tests de Application: solo registra llamadas."""

    def __init__(self):
        self.calls: list[tuple[str, tuple]] = []

    def set_color(self, color):
        self.calls.append(("set_color", (color,)))

    def set_brightness(self, value):
        self.calls.append(("set_brightness", (value,)))

    def animation(self, name):
        self.calls.append(("animation", (name,)))

    def off(self):
        self.calls.append(("off", ()))

    def flash(self, color, times=3, interval=0.15, restore_to=None):
        self.calls.append(("flash", (color, times, interval, restore_to)))

    def fade(self, to_color, duration=0.6, steps=20):
        self.calls.append(("fade", (to_color, duration, steps)))

    def calls_of(self, name):
        return [args for call_name, args in self.calls if call_name == name]


class FakeDatabase:
    """Doble de PanelDatabase para tests de Application: paneles fijados a mano."""

    def __init__(self, panels: dict):
        self._panels = panels

    def find(self, uid):
        return self._panels.get(uid.upper())

    def all(self):
        return dict(self._panels)


class FakeLauncher:
    """Doble de Launcher para tests de Application: no lanza procesos reales."""

    def __init__(self, launch_result: bool = True):
        self.launch_result = launch_result
        self.launch_calls: list[str] = []

    def launch(self, platform):
        self.launch_calls.append(platform)
        return self.launch_result
