// SteamMachine UM790 - Firmware ESP32
//
// hardware/oled.h
//
// Pantalla OLED (05_Firmware_Architecture.md, modulo OLED):
// "No almacena informacion. Siempre representa el estado enviado por el PC."
// Es decir: sin cache ni logica propia, solo dibuja lo que le mandan.

#pragma once

#include <Arduino.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>
#include "config.h"

class OledDisplay {
public:
    bool begin();

    void showText(const char *text);
    void showTwoLines(const char *line1, const char *line2);
    void clear();

private:
    Adafruit_SSD1306 _display{OLED_WIDTH, OLED_HEIGHT, &Wire, -1};
    bool _ready = false;
};
