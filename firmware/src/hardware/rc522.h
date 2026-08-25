// SteamMachine UM790 - Firmware ESP32
//
// hardware/rc522.h
//
// Lector NFC RC522 (05_Firmware_Architecture.md, modulo RC522).
// Genera eventos "tag" / "tag_removed". El RC522 no tiene interrupcion
// de retirada: se infiere tras N sondeos consecutivos sin lectura
// (RC522_REMOVAL_THRESHOLD en config.h).

#pragma once

#include <Arduino.h>
#include <MFRC522.h>
#include "config.h"
#include "core/event_queue.h"
#include "utils/timers.h"

class Rc522Reader {
public:
    bool begin();

    // No bloqueante: solo actua cuando toca segun RC522_POLL_INTERVAL_MS.
    void update(EventQueue &queue);

private:
    MFRC522 _mfrc522{RC522_SS_PIN, RC522_RST_PIN};
    Every _pollTimer{RC522_POLL_INTERVAL_MS};

    char _currentUid[9] = {0};
    bool _hasTag = false;
    uint8_t _missCount = 0;

    static void uidToHex(const MFRC522::Uid &uid, char *out, size_t outSize);
};
