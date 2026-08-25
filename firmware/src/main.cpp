// SteamMachine UM790 - Firmware ESP32
//
// main.cpp
//
// Punto de entrada. Toda la logica vive en core/application.*
// (05_Firmware_Architecture.md).

#include <Arduino.h>
#include "core/application.h"

Application app;

void setup() {
    app.setup();
}

void loop() {
    app.loop();
}
