// SteamMachine UM790 - Firmware ESP32
//
// services/animations.cpp

#include "services/animations.h"
#include <string.h>
#include <math.h>
#include "utils/logger.h"

AnimationName AnimationEngine::fromString(const char *name) {
    if (strcmp(name, "idle") == 0) return AnimationName::IDLE;
    if (strcmp(name, "loading") == 0) return AnimationName::LOADING;
    if (strcmp(name, "launch") == 0) return AnimationName::LAUNCH;
    if (strcmp(name, "rainbow") == 0) return AnimationName::RAINBOW;
    if (strcmp(name, "error") == 0) return AnimationName::ANIM_ERROR;
    if (strcmp(name, "success") == 0) return AnimationName::SUCCESS;
    if (strcmp(name, "shutdown") == 0) return AnimationName::SHUTDOWN;
    return AnimationName::NONE;
}

void AnimationEngine::start(AnimationName name) {
    _current = name;
    _startedAtMs = millis();
    _frameTimer.reset();
}

void AnimationEngine::stop() {
    _current = AnimationName::NONE;
}

void AnimationEngine::update() {
    if (_current == AnimationName::NONE) {
        return;
    }
    if (!_frameTimer.ready()) {
        return;
    }

    uint32_t elapsed = millis() - _startedAtMs;

    switch (_current) {
        case AnimationName::IDLE:      frameIdle(elapsed); break;
        case AnimationName::LOADING:   frameLoading(elapsed); break;
        case AnimationName::LAUNCH:    frameLaunch(elapsed); break;
        case AnimationName::RAINBOW:   frameRainbow(elapsed); break;
        case AnimationName::ANIM_ERROR: frameError(elapsed); break;
        case AnimationName::SUCCESS:   frameSuccess(elapsed); break;
        case AnimationName::SHUTDOWN:  frameShutdown(elapsed); break;
        default: break;
    }
}

// -- Animaciones -----------------------------------------------------------

void AnimationEngine::frameIdle(uint32_t elapsed) {
    // Respiracion suave: brillo oscilando en forma de onda seno, periodo ~3s.
    float phase = (elapsed % 3000) / 3000.0f;
    float level = (sinf(phase * 2 * PI) + 1.0f) / 2.0f; // 0..1
    uint8_t brightness = 40 + static_cast<uint8_t>(level * 180);

    CRGB color = _baseColor;
    color.nscale8_video(brightness);
    _leds.fillSolid(color);
    _leds.show();
}

void AnimationEngine::frameLoading(uint32_t elapsed) {
    // Punto girando alrededor de la tira en el color base.
    uint16_t count = _leds.count();
    if (count == 0) return;

    uint16_t head = (elapsed / 60) % count; // velocidad de giro
    _leds.fillSolid(CRGB::Black);
    for (uint16_t i = 0; i < 3 && i < count; i++) {
        uint16_t idx = (head + count - i) % count;
        CRGB c = _baseColor;
        c.nscale8_video(255 - i * 70);
        _leds.setPixel(idx, c);
    }
    _leds.show();
}

void AnimationEngine::frameLaunch(uint32_t elapsed) {
    // Pulso rapido y energico mientras se lanza la plataforma.
    float phase = (elapsed % 400) / 400.0f;
    float level = (sinf(phase * 2 * PI) + 1.0f) / 2.0f;
    uint8_t brightness = 100 + static_cast<uint8_t>(level * 155);

    CRGB color = _baseColor;
    color.nscale8_video(brightness);
    _leds.fillSolid(color);
    _leds.show();
}

void AnimationEngine::frameRainbow(uint32_t elapsed) {
    uint16_t count = _leds.count();
    uint16_t denom = count > 0 ? count : 1;
    uint8_t baseHue = (elapsed / 8) % 256;
    for (uint16_t i = 0; i < count; i++) {
        uint8_t hue = baseHue + (i * 256 / denom);
        _leds.setPixel(i, CHSV(hue, 255, 255));
    }
    _leds.show();
}

void AnimationEngine::frameError(uint32_t elapsed) {
    // Parpadeo rojo rapido.
    bool on = (elapsed / 150) % 2 == 0;
    _leds.fillSolid(on ? CRGB::Red : CRGB::Black);
    _leds.show();
}

void AnimationEngine::frameSuccess(uint32_t elapsed) {
    // Destello verde que se atenua durante ~1s y se queda tenue.
    uint32_t duration = 1000;
    uint32_t t = elapsed > duration ? duration : elapsed;
    uint8_t brightness = 255 - static_cast<uint8_t>((t * 200UL) / duration);
    CRGB color = CRGB::Green;
    color.nscale8_video(brightness);
    _leds.fillSolid(color);
    _leds.show();
}

void AnimationEngine::frameShutdown(uint32_t elapsed) {
    // Fundido a negro en ~1.5s; despues se queda apagado (no reinicia solo).
    uint32_t duration = 1500;
    if (elapsed >= duration) {
        _leds.fillSolid(CRGB::Black);
        _leds.show();
        stop();
        return;
    }
    uint8_t brightness = 255 - static_cast<uint8_t>((elapsed * 255UL) / duration);
    CRGB color = _baseColor;
    color.nscale8_video(brightness);
    _leds.fillSolid(color);
    _leds.show();
}
