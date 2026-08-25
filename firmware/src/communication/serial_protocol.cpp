// SteamMachine UM790 - Firmware ESP32
//
// communication/serial_protocol.cpp

#include "communication/serial_protocol.h"
#include <ArduinoJson.h>

void SerialProtocol::begin() {
    Serial.begin(SERIAL_BAUDRATE);
    _bufferPos = 0;
}

bool SerialProtocol::poll(Command &out) {
    while (Serial.available() > 0) {
        char c = static_cast<char>(Serial.read());

        if (c == '\n') {
            _buffer[_bufferPos] = '\0';
            _bufferPos = 0;

            if (strlen(_buffer) == 0) {
                continue; // linea en blanco, se ignora
            }
            return json_parser::parseCommand(_buffer, out);
        }

        if (c == '\r') {
            continue; // CRLF: ignoramos el CR, LF marca fin de linea
        }

        if (_bufferPos < SERIAL_LINE_BUFFER_SIZE - 1) {
            _buffer[_bufferPos++] = c;
        } else {
            // Linea demasiado larga: se descarta para no desbordar el buffer.
            _bufferPos = 0;
        }
    }
    return false;
}

void SerialProtocol::sendBoot(const char *firmwareVersion) {
    JsonDocument doc;
    doc["event"] = "boot";
    doc["firmware"] = firmwareVersion;
    serializeJson(doc, Serial);
    Serial.print('\n');
}

void SerialProtocol::sendTag(const char *uid) {
    JsonDocument doc;
    doc["event"] = "tag";
    doc["uid"] = uid;
    serializeJson(doc, Serial);
    Serial.print('\n');
}

void SerialProtocol::sendTagRemoved() {
    JsonDocument doc;
    doc["event"] = "tag_removed";
    serializeJson(doc, Serial);
    Serial.print('\n');
}

void SerialProtocol::sendButton() {
    JsonDocument doc;
    doc["event"] = "button";
    serializeJson(doc, Serial);
    Serial.print('\n');
}

void SerialProtocol::sendError(uint8_t code) {
    JsonDocument doc;
    doc["event"] = "error";
    doc["code"] = code;
    serializeJson(doc, Serial);
    Serial.print('\n');
}

void SerialProtocol::sendStatus(uint32_t uptimeMs, uint32_t freeHeap) {
    JsonDocument doc;
    doc["event"] = "status";
    doc["uptime"] = uptimeMs;
    doc["heap"] = freeHeap;
    serializeJson(doc, Serial);
    Serial.print('\n');
}
