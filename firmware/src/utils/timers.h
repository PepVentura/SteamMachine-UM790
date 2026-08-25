// SteamMachine UM790 - Firmware ESP32
//
// utils/timers.h
//
// Temporizador no bloqueante basado en millis() (05_Firmware_Architecture.md,
// principio "No se utilizaran retardos bloqueantes"). Uso tipico:
//
//   Every rc522Poll(RC522_POLL_INTERVAL_MS);
//   void loop() {
//       if (rc522Poll.ready()) { ... }
//   }

#pragma once

#include <Arduino.h>

class Every {
public:
    explicit Every(uint32_t interval_ms) : _interval(interval_ms), _last(0) {}

    // Devuelve true como maximo una vez por intervalo transcurrido.
    bool ready() {
        uint32_t now = millis();
        if (now - _last >= _interval) {
            _last = now;
            return true;
        }
        return false;
    }

    void reset() { _last = millis(); }

private:
    uint32_t _interval;
    uint32_t _last;
};
