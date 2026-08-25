// SteamMachine UM790 - Firmware ESP32
//
// hardware/leds.cpp

#include "hardware/leds.h"
#include "utils/logger.h"

void LedBar::begin() {
    FastLED.addLeds<WS2812B, LED_DATA_PIN, GRB>(_leds, LED_COUNT);
    FastLED.setBrightness(LED_DEFAULT_BRIGHTNESS);
    fillSolid(CRGB::Black);
    show();
}

CRGB LedBar::hexToColor(const char *hex) {
    // Espera "#RRGGBB"; formato invalido -> negro (apagado), nunca crashea.
    if (hex == nullptr || hex[0] != '#' || strlen(hex) < 7) {
        return CRGB::Black;
    }
    long value = strtol(hex + 1, nullptr, 16);
    uint8_t r = (value >> 16) & 0xFF;
    uint8_t g = (value >> 8) & 0xFF;
    uint8_t b = value & 0xFF;
    return CRGB(r, g, b);
}

void LedBar::setColor(const char *hexColor) {
    fillSolid(hexToColor(hexColor));
    show();
}

void LedBar::setBrightness(uint8_t value) {
    FastLED.setBrightness(value);
    show();
}

void LedBar::setPixel(uint16_t index, CRGB color) {
    if (index < LED_COUNT) {
        _leds[index] = color;
    }
}

void LedBar::fillSolid(CRGB color) {
    for (uint16_t i = 0; i < LED_COUNT; i++) {
        _leds[i] = color;
    }
}

void LedBar::show() {
    FastLED.show();
}
