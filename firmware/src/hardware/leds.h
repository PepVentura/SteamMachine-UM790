// SteamMachine UM790 - Firmware ESP32
//
// hardware/leds.h
//
// Barra LED RGB direccionable (05_Firmware_Architecture.md, modulo
// "LED Manager" en cuanto a color/intensidad raw). Las animaciones con
// estado propio viven en services/animations.h, que usa este modulo
// como salida.

#pragma once

#include <Arduino.h>
#include <FastLED.h>
#include "config.h"

class LedBar {
public:
    void begin();

    // Color solido para toda la tira, en formato "#RRGGBB".
    void setColor(const char *hexColor);
    void setBrightness(uint8_t value);

    // Usado por services/animations.h para dibujar frame a frame.
    void setPixel(uint16_t index, CRGB color);
    void show();
    void fillSolid(CRGB color);
    uint16_t count() const { return LED_COUNT; }

    static CRGB hexToColor(const char *hex);

private:
    CRGB _leds[LED_COUNT];

};
