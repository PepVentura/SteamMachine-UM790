// SteamMachine UM790 - Firmware ESP32
//
// communication/serial_protocol.h
//
// Capa de transporte del protocolo (04_Communication_Protocol.md):
// acumula bytes de Serial (USB) sin bloquear hasta completar una linea
// (LF), la parsea con json_parser, y expone funciones para mandar los
// eventos ESP32 -> PC (boot, tag, tag_removed, button, error, status).

#pragma once

#include <Arduino.h>
#include "config.h"
#include "communication/json_parser.h"

class SerialProtocol {
public:
    void begin();

    // No bloqueante. Si hay una linea completa y valida, la deja en
    // `out` y devuelve true. Se debe llamar en cada vuelta de loop().
    bool poll(Command &out);

    // -- Eventos ESP32 -> PC (docs/04, seccion "ESP32 -> PC") -----------
    void sendBoot(const char *firmwareVersion);
    void sendTag(const char *uid);
    void sendTagRemoved();
    void sendButton();
    void sendError(uint8_t code);
    void sendStatus(uint32_t uptimeMs, uint32_t freeHeap);

private:
    char _buffer[SERIAL_LINE_BUFFER_SIZE];
    uint16_t _bufferPos = 0;
};
