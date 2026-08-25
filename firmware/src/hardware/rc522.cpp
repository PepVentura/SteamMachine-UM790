// SteamMachine UM790 - Firmware ESP32
//
// hardware/rc522.cpp

#include "hardware/rc522.h"
#include <SPI.h>
#include "utils/logger.h"

bool Rc522Reader::begin() {
    SPI.begin(RC522_SCK_PIN, RC522_MISO_PIN, RC522_MOSI_PIN, RC522_SS_PIN);
    _mfrc522.PCD_Init();

    // Comprobacion basica de presencia: version de firmware valida.
    byte version = _mfrc522.PCD_ReadRegister(MFRC522::VersionReg);
    if (version == 0x00 || version == 0xFF) {
        logger::error("RC522 no responde (version invalida)", version);
        return false;
    }

    logger::info("RC522 inicializado, version", version);
    return true;
}

void Rc522Reader::uidToHex(const MFRC522::Uid &uid, char *out, size_t outSize) {
    size_t pos = 0;
    for (byte i = 0; i < uid.size && pos + 2 < outSize; i++) {
        pos += snprintf(out + pos, outSize - pos, "%02X", uid.uidByte[i]);
    }
    out[pos] = '\0';
}

void Rc522Reader::update(EventQueue &queue) {
    if (!_pollTimer.ready()) {
        return;
    }

    bool present = _mfrc522.PICC_IsNewCardPresent() && _mfrc522.PICC_ReadCardSerial();

    if (present) {
        _missCount = 0;

        char uidHex[9];
        uidToHex(_mfrc522.uid, uidHex, sizeof(uidHex));

        if (!_hasTag || strcmp(uidHex, _currentUid) != 0) {
            strncpy(_currentUid, uidHex, sizeof(_currentUid) - 1);
            _currentUid[sizeof(_currentUid) - 1] = '\0';
            _hasTag = true;
            logger::info("Tag detectado", _currentUid);
            queue.pushTag(_currentUid);
        }

        // NO se llama a PICC_HaltA()/PCD_StopCrypto1() aqui: solo leemos
        // el UID (sin autenticacion ni lectura de bloques MIFARE), y
        // haltear la tarjeta le impide responder al siguiente sondeo —
        // una tarjeta en HALT no responde a REQA (PICC_IsNewCardPresent()),
        // solo a WUPA, segun ISO14443A. Eso provocaba que el firmware
        // reportara "tag_removed" a los ~450ms aunque el tag siguiera
        // fisicamente puesto (2026-08-25, fallo real reportado por el
        // usuario en hardware real: "me dice que el panel se ha
        // retirado, pero el tag sigue presentado").
        return;
    }

    // Sin lectura en este sondeo.
    if (_hasTag) {
        _missCount++;
        if (_missCount >= RC522_REMOVAL_THRESHOLD) {
            logger::info("Tag retirado", _currentUid);
            _hasTag = false;
            _missCount = 0;
            _currentUid[0] = '\0';
            queue.pushTagRemoved();
        }
    }
}
