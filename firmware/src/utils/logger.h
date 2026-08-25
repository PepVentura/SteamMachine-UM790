// SteamMachine UM790 - Firmware ESP32
//
// utils/logger.h
//
// Logger de depuracion. IMPORTANTE: escribe por Serial2, nunca por Serial
// (USB), porque Serial es el canal exclusivo del protocolo JSON con el PC
// (04_Communication_Protocol.md). Mezclar logs ahi rompería el parseo en
// el Core. Compilar con -DDEBUG_SERIAL2=1 para activarlo (ver
// platformio.ini); por defecto esta silenciado.

#pragma once

#include <Arduino.h>

namespace logger {

void begin();
void info(const char *msg);
void error(const char *msg);

// Variantes con un unico valor extra (evita tirar de snprintf/String en
// caliente para algo tan simple).
void info(const char *msg, const char *value);
void info(const char *msg, int value);
void error(const char *msg, int value);

} // namespace logger
