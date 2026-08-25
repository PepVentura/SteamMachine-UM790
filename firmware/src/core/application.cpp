// SteamMachine UM790 - Firmware ESP32
//
// core/application.cpp

#include "core/application.h"
#include "config.h"
#include "services/watchdog.h"
#include "services/diagnostics.h"
#include "utils/logger.h"

void Application::setup() {
    logger::begin();
    logger::info("SteamMachine firmware arrancando...");

    // Flujo de arranque (docs/05): GPIO -> OLED -> LEDs -> RC522 -> Serie -> boot
    pinMode(BUZZER_PIN, OUTPUT);
    digitalWrite(BUZZER_PIN, LOW);

    _button.begin();

    if (!_oled.begin()) {
        // Sin OLED no abortamos: el resto del sistema (LEDs, lanzado por
        // tag+boton) puede seguir funcionando sin pantalla.
        logger::error("Continuando sin OLED operativa");
    }

    _leds.begin();
    _animations.setBaseColor(CRGB(0, 85, 255));

    if (!_rc522.begin()) {
        _events.pushError(1); // 1 = RC522 no encontrado (docs/04, Codigos de error)
    }

    _protocol.begin();
    watchdog::begin();

    _events.pushBoot();
}

void Application::loop() {
    feedWatchdog();

    _rc522.update(_events);
    _button.update(_events);
    _animations.update();

    drainEventQueue();

    Command cmd;
    if (_protocol.poll(cmd)) {
        handleIncomingCommand(cmd);
    }
}

void Application::feedWatchdog() {
    watchdog::feed();
}

void Application::drainEventQueue() {
    FirmwareEvent event;
    while (_events.pop(event)) {
        switch (event.type) {
            case EventType::BOOT:
                _protocol.sendBoot(FIRMWARE_VERSION);
                break;
            case EventType::TAG_DETECTED:
                _protocol.sendTag(event.uid);
                break;
            case EventType::TAG_REMOVED:
                _protocol.sendTagRemoved();
                break;
            case EventType::BUTTON:
                _protocol.sendButton();
                break;
            case EventType::ERROR:
                _protocol.sendError(event.error_code);
                break;
            default:
                break;
        }
    }
}

void Application::handleIncomingCommand(const Command &cmd) {
    switch (cmd.type) {
        case CommandType::OLED:
            _oled.showText(cmd.text);
            break;

        case CommandType::OLED2:
            _oled.showTwoLines(cmd.line1, cmd.line2);
            break;

        case CommandType::OLED_CLEAR:
            _oled.clear();
            break;

        case CommandType::LED:
            // Un color solido explicito cancela cualquier animacion en curso,
            // igual que en el Core (LEDManager.set_color -> _cancel_animation()).
            _animations.stop();
            _leds.setColor(cmd.color);
            // El color solido pasa a ser la referencia para animaciones que
            // lo usan (idle, loading), hasta el proximo "led" recibido.
            _animations.setBaseColor(LedBar::hexToColor(cmd.color));
            break;

        case CommandType::BRIGHTNESS:
            _leds.setBrightness(static_cast<uint8_t>(cmd.value));
            break;

        case CommandType::ANIMATION: {
            AnimationName anim = AnimationEngine::fromString(cmd.name);
            if (anim == AnimationName::NONE) {
                _events.pushError(5); // 5 = error desconocido (nombre no reconocido)
            } else {
                _animations.start(anim);
            }
            break;
        }

        case CommandType::RESTART:
            logger::info("Reinicio solicitado por el PC");
            delay(50); // margen minimo para que salga el log por Serial2 antes de reiniciar
            ESP.restart();
            break;

        case CommandType::STATUS: {
            DiagnosticsSnapshot s = diagnostics::snapshot();
            _protocol.sendStatus(s.uptime_ms, s.free_heap);
            break;
        }

        case CommandType::BEEP:
            // Zumbador: pendiente de hardware (docs/04, "Zumbador (futuro)").
            break;

        case CommandType::UNKNOWN:
        default:
            _events.pushError(5);
            break;
    }
}
