// SteamMachine UM790 - Firmware ESP32
//
// services/diagnostics.cpp

#include "services/diagnostics.h"

namespace diagnostics {

DiagnosticsSnapshot snapshot() {
    DiagnosticsSnapshot s;
    s.uptime_ms = millis();
    s.free_heap = ESP.getFreeHeap();
    return s;
}

} // namespace diagnostics
