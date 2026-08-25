// SteamMachine UM790 - Firmware ESP32
//
// communication/json_parser.cpp

#include "communication/json_parser.h"
#include <ArduinoJson.h>
#include "utils/logger.h"

namespace json_parser {

bool parseCommand(const char *line, Command &out) {
    JsonDocument doc;
    DeserializationError err = deserializeJson(doc, line);
    if (err) {
        logger::error("JSON invalido en linea recibida");
        return false;
    }

    const char *cmd = doc["cmd"] | "";
    if (strlen(cmd) == 0) {
        logger::error("Linea recibida sin campo 'cmd'");
        return false;
    }

    Command result;

    if (strcmp(cmd, "oled") == 0) {
        result.type = CommandType::OLED;
        strlcpy(result.text, doc["text"] | "", sizeof(result.text));
    } else if (strcmp(cmd, "oled2") == 0) {
        result.type = CommandType::OLED2;
        strlcpy(result.line1, doc["line1"] | "", sizeof(result.line1));
        strlcpy(result.line2, doc["line2"] | "", sizeof(result.line2));
    } else if (strcmp(cmd, "oled_clear") == 0) {
        result.type = CommandType::OLED_CLEAR;
    } else if (strcmp(cmd, "led") == 0) {
        result.type = CommandType::LED;
        strlcpy(result.color, doc["color"] | "#000000", sizeof(result.color));
    } else if (strcmp(cmd, "brightness") == 0) {
        result.type = CommandType::BRIGHTNESS;
        result.value = doc["value"] | 0;
    } else if (strcmp(cmd, "animation") == 0) {
        result.type = CommandType::ANIMATION;
        strlcpy(result.name, doc["name"] | "", sizeof(result.name));
    } else if (strcmp(cmd, "beep") == 0) {
        result.type = CommandType::BEEP;
        result.value = doc["duration"] | 100;
    } else if (strcmp(cmd, "restart") == 0) {
        result.type = CommandType::RESTART;
    } else if (strcmp(cmd, "status") == 0) {
        result.type = CommandType::STATUS;
    } else {
        logger::error("Comando desconocido recibido");
        return false;
    }

    out = result;
    return true;
}

} // namespace json_parser
