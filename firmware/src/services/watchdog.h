// SteamMachine UM790 - Firmware ESP32
//
// services/watchdog.h
//
// Watchdog hardware (05_Firmware_Architecture.md, seccion "Watchdog"):
// si el loop principal deja de alimentarlo (p.ej. quedaria colgado en
// algun modulo), el ESP32 se reinicia solo.

#pragma once

#include <Arduino.h>

namespace watchdog {
void begin();
void feed();
} // namespace watchdog
