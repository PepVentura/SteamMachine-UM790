// SteamMachine UM790 - Firmware ESP32
//
// hardware/button.cpp

#include "hardware/button.h"
#include "config.h"
#include "utils/logger.h"

void Button::begin() {
    pinMode(BUTTON_PIN, BUTTON_ACTIVE_LOW ? INPUT_PULLUP : INPUT);
    _lastStableState = readRaw();
    _lastReadState = _lastStableState;
    _lastChangeMs = millis();
}

bool Button::readRaw() const {
    int level = digitalRead(BUTTON_PIN);
    bool pressed = BUTTON_ACTIVE_LOW ? (level == LOW) : (level == HIGH);
    return pressed;
}

void Button::update(EventQueue &queue) {
    bool reading = readRaw();

    if (reading != _lastReadState) {
        _lastChangeMs = millis();
        _lastReadState = reading;
    }

    if ((millis() - _lastChangeMs) >= BUTTON_DEBOUNCE_MS) {
        if (reading != _lastStableState) {
            _lastStableState = reading;
            if (_lastStableState) {
                // Flanco de subida ya estabilizado -> pulsacion valida.
                logger::info("Boton pulsado");
                queue.pushButton();
            }
        }
    }
}
