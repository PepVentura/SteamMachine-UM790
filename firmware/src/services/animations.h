// SteamMachine UM790 - Firmware ESP32
//
// services/animations.h
//
// Motor de animaciones de la barra LED (05_Firmware_Architecture.md,
// "LED Manager" / animaciones disponibles: idle, loading, launch,
// rainbow, error, success, shutdown - ver tambien docs/04, cmd "animation").
//
// Dibuja frame a frame sobre hardware/leds.h, sin bloquear (millis()).
// Un comando "led" (color solido) o "brightness" desde el PC debe llamar
// a stop() antes, para que la animacion en curso no le pise el color.

#pragma once

#include <Arduino.h>
#include "hardware/leds.h"
#include "utils/timers.h"

enum class AnimationName {
    NONE,
    IDLE,
    LOADING,
    LAUNCH,
    RAINBOW,
    ANIM_ERROR,
    SUCCESS,
    SHUTDOWN
};

class AnimationEngine {
public:
    explicit AnimationEngine(LedBar &leds) : _leds(leds) {}

    // Color de referencia para las animaciones que lo usan (idle, loading).
    // Se actualiza automaticamente con cada "led" solido recibido.
    void setBaseColor(CRGB color) { _baseColor = color; }

    void start(AnimationName name);
    void stop();

    // No bloqueante: pintar el siguiente frame si toca.
    void update();

    static AnimationName fromString(const char *name);

private:
    LedBar &_leds;
    AnimationName _current = AnimationName::NONE;
    Every _frameTimer{LED_UPDATE_INTERVAL_MS};
    uint32_t _startedAtMs = 0;
    CRGB _baseColor = CRGB(0, 85, 255); // azul de reposo por defecto

    void frameIdle(uint32_t elapsed);
    void frameLoading(uint32_t elapsed);
    void frameLaunch(uint32_t elapsed);
    void frameRainbow(uint32_t elapsed);
    void frameError(uint32_t elapsed);
    void frameSuccess(uint32_t elapsed);
    void frameShutdown(uint32_t elapsed);
};
