// SteamMachine UM790 - Firmware ESP32
//
// communication/json_parser.h
//
// Interpreta una linea JSON recibida del PC y la convierte en un Command
// (04_Communication_Protocol.md, seccion "PC -> ESP32"). El firmware
// nunca interpreta el contenido funcional: solo reconoce estos comandos
// y los pasa a Application, que decide que hacer con ellos.

#pragma once

#include <Arduino.h>

enum class CommandType {
    UNKNOWN,
    OLED,
    OLED2,
    OLED_CLEAR,
    LED,
    BRIGHTNESS,
    ANIMATION,
    BEEP,
    RESTART,
    STATUS
};

struct Command {
    CommandType type = CommandType::UNKNOWN;
    char text[64] = {0};    // oled.text
    char line1[32] = {0};   // oled2.line1
    char line2[32] = {0};   // oled2.line2
    char color[8] = {0};    // led.color ("#RRGGBB")
    char name[16] = {0};    // animation.name
    uint16_t value = 0;     // brightness.value / beep.duration
};

namespace json_parser {
// Devuelve false si la linea no es JSON valido; en ese caso `out` no se toca.
bool parseCommand(const char *line, Command &out);
} // namespace json_parser
