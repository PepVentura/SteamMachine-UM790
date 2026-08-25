// SteamMachine UM790 - Firmware ESP32
//
// utils/logger.cpp

#include "utils/logger.h"
#include "config.h"

namespace logger {

void begin() {
#if DEBUG_SERIAL2
    Serial2.begin(DEBUG_SERIAL2_BAUDRATE, SERIAL_8N1, DEBUG_SERIAL2_RX_PIN, DEBUG_SERIAL2_TX_PIN);
    Serial2.println(F("[logger] SteamMachine firmware debug activo"));
#endif
}

void info(const char *msg) {
#if DEBUG_SERIAL2
    Serial2.print(F("[INFO] "));
    Serial2.println(msg);
#else
    (void)msg;
#endif
}

void error(const char *msg) {
#if DEBUG_SERIAL2
    Serial2.print(F("[ERROR] "));
    Serial2.println(msg);
#else
    (void)msg;
#endif
}

void info(const char *msg, const char *value) {
#if DEBUG_SERIAL2
    Serial2.print(F("[INFO] "));
    Serial2.print(msg);
    Serial2.print(F(": "));
    Serial2.println(value);
#else
    (void)msg;
    (void)value;
#endif
}

void info(const char *msg, int value) {
#if DEBUG_SERIAL2
    Serial2.print(F("[INFO] "));
    Serial2.print(msg);
    Serial2.print(F(": "));
    Serial2.println(value);
#else
    (void)msg;
    (void)value;
#endif
}

void error(const char *msg, int value) {
#if DEBUG_SERIAL2
    Serial2.print(F("[ERROR] "));
    Serial2.print(msg);
    Serial2.print(F(": "));
    Serial2.println(value);
#else
    (void)msg;
    (void)value;
#endif
}

} // namespace logger
