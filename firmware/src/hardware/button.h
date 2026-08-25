// SteamMachine UM790 - Firmware ESP32
//
// hardware/button.h
//
// Pulsador antivandalico iluminado (05_Firmware_Architecture.md,
// modulo Button). Responsabilidad unica: detectar pulsacion con
// antirrebote, sin logica de aplicacion.

#pragma once

#include <Arduino.h>
#include "core/event_queue.h"

class Button {
public:
    void begin();

    // Debe llamarse en cada vuelta de loop(). No bloqueante.
    // Empuja un evento BUTTON a la cola cuando detecta una pulsacion valida.
    void update(EventQueue &queue);

private:
    bool _lastStableState = false;
    bool _lastReadState = false;
    uint32_t _lastChangeMs = 0;

    bool readRaw() const;
};
