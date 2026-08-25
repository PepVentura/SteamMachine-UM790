// SteamMachine UM790 - Firmware ESP32
//
// core/application.h
//
// Orquesta el firmware (05_Firmware_Architecture.md, "MAIN LOOP" repartido
// en Hardware / Communication / Services). Flujo de arranque y estados:
// ver docs/05, secciones "Flujo de arranque" y "Estados del firmware".

#pragma once

#include "core/event_queue.h"
#include "communication/serial_protocol.h"
#include "hardware/rc522.h"
#include "hardware/oled.h"
#include "hardware/leds.h"
#include "hardware/button.h"
#include "services/animations.h"

class Application {
public:
    void setup();
    void loop();

private:
    EventQueue _events;
    SerialProtocol _protocol;
    Rc522Reader _rc522;
    OledDisplay _oled;
    LedBar _leds;
    Button _button;
    AnimationEngine _animations{_leds};

    void drainEventQueue();
    void handleIncomingCommand(const Command &cmd);
    void feedWatchdog();
};
