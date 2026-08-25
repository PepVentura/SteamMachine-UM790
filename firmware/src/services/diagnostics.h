// SteamMachine UM790 - Firmware ESP32
//
// services/diagnostics.h
//
// Datos de diagnostico (05_Firmware_Architecture.md, seccion
// "Diagnostico"): uptime y memoria libre. Se envian en respuesta al
// comando "status" (extension acordada junto al Core - ver README de
// software/ y docs/04, seccion "Diagnostico").

#pragma once

#include <Arduino.h>

struct DiagnosticsSnapshot {
    uint32_t uptime_ms;
    uint32_t free_heap;
};

namespace diagnostics {
DiagnosticsSnapshot snapshot();
}
