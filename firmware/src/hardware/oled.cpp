// SteamMachine UM790 - Firmware ESP32
//
// hardware/oled.cpp

#include "hardware/oled.h"
#include <Wire.h>
#include "utils/logger.h"

bool OledDisplay::begin() {
    Wire.begin(OLED_I2C_SDA_PIN, OLED_I2C_SCL_PIN);

    // periphBegin=false: ya hemos llamado a Wire.begin() con los pines
    // I2C personalizados (OLED_I2C_SDA_PIN/SCL_PIN) justo arriba; si se
    // deja en true (su valor por defecto), Adafruit_SSD1306 vuelve a
    // llamar a Wire.begin() sin argumentos y pisa esos pines con los de
    // defecto del ESP32 (que hoy coinciden, pero no tienen por que seguir
    // haciendolo si algun dia cambian en config.h).
    if (!_display.begin(SSD1306_SWITCHCAPVCC, OLED_I2C_ADDRESS, true, false)) {
        logger::error("OLED no responde en la direccion I2C configurada");
        _ready = false;
        return false;
    }

    _ready = true;
    _display.setTextColor(SSD1306_WHITE);
    clear();
    return true;
}

void OledDisplay::showText(const char *text) {
    if (!_ready) return;

    _display.clearDisplay();
    _display.setTextSize(2);
    _display.setCursor(0, (OLED_HEIGHT - 16) / 2);
    _display.print(text);
    _display.display();
}

void OledDisplay::showTwoLines(const char *line1, const char *line2) {
    if (!_ready) return;

    _display.clearDisplay();
    _display.setTextSize(1);
    _display.setCursor(0, (OLED_HEIGHT / 2) - 12);
    _display.print(line1);
    _display.setCursor(0, (OLED_HEIGHT / 2) + 2);
    _display.print(line2);
    _display.display();
}

void OledDisplay::clear() {
    if (!_ready) return;

    _display.clearDisplay();
    _display.display();
}
