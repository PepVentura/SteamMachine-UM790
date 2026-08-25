// SteamMachine UM790 - Firmware ESP32
//
// config.h
//
// Configuracion centralizada (05_Firmware_Architecture.md, seccion
// "Configuracion"). Ningun otro fichero debe tener numeros de pin o
// timings sueltos: todo pasa por aqui.
//
// PINOUT: fijado por el diseno electronico real del proyecto (no ya una
// propuesta de partida). El resto de GPIO del ESP32-WROOM-32D DevKit
// (HW-394) quedan reservados sin asignar todavia.
//
// Alimentacion (referencia, no afecta al codigo pero conviene tenerlo
// documentado junto al pinout):
//   3V3          -> RC522 + OLED
//   VIN (~4.68V)  -> WS2812B
//   GND           -> masa comun
//
// El pin de datos de la barra LED (GPIO25) va DIRECTO a la WS2812B, en
// logica de 3.3V (sin nivelador). El diseno original preveia un
// 74AHCT125 (3.3V->5V) de por medio, pero se retiro (2026-08-25) tras
// comprobar en un tramo real de 8 LEDs que la tira funciona bien sin
// el: con 8 LEDs conectados directamente al ESP32 encendio
// correctamente, mientras que con el 74AHCT125 en el circuito no
// encendia nada (causa mas probable: el pin /1OE del chip quedo
// flotante). Si en el futuro la tira completa (mas larga) diera
// problemas de senal, revisar si conviene reintroducir un nivelador
// bien cableado.

#pragma once

// ---------------------------------------------------------------------
// Puerto serie (protocolo con el PC) - docs/04_Communication_Protocol.md
// ---------------------------------------------------------------------
#define SERIAL_BAUDRATE 115200

// Canal de depuracion opcional, NUNCA el mismo puerto USB que el protocolo.
// Activar con build_flags -DDEBUG_SERIAL2=1 (ver platformio.ini).
// Pin todavia no asignado en el diseno electronico real: valor provisional.
#define DEBUG_SERIAL2_RX_PIN 16
#define DEBUG_SERIAL2_TX_PIN 17
#define DEBUG_SERIAL2_BAUDRATE 115200

// ---------------------------------------------------------------------
// RC522 (lector NFC) - SPI. Alimentacion: 3V3.
// ---------------------------------------------------------------------
#define RC522_SCK_PIN 18
#define RC522_MISO_PIN 19
#define RC522_MOSI_PIN 23
#define RC522_SS_PIN 5    // SDA/SS
#define RC522_RST_PIN 27

// Ciclo de sondeo del RC522 (no bloqueante, ver core/scheduler.h)
#define RC522_POLL_INTERVAL_MS 150
// Nº de sondeos consecutivos sin tarjeta antes de considerar "tag_removed".
// El RC522 no tiene interrupcion de retirada; se infiere por ausencia.
#define RC522_REMOVAL_THRESHOLD 3

// ---------------------------------------------------------------------
// OLED - I2C (0.96" SSD1306, 128x64 tipico para esta zona visible).
// Alimentacion: 3V3.
// ---------------------------------------------------------------------
#define OLED_I2C_SDA_PIN 21
#define OLED_I2C_SCL_PIN 22
#define OLED_I2C_ADDRESS 0x3C
#define OLED_WIDTH 128
#define OLED_HEIGHT 64

// ---------------------------------------------------------------------
// Barra LED (WS2812B via FastLED). Dato del ESP32 (3.3V) directo a la
// WS2812B, sin nivelador (ver nota arriba) — alimentada por VIN.
// ---------------------------------------------------------------------
#define LED_DATA_PIN 25
#define LED_COUNT 8            // Dato real confirmado por el usuario (2026-08-25) — antes 12 (placeholder)
#define LED_DEFAULT_BRIGHTNESS 128
#define LED_UPDATE_INTERVAL_MS 16   // ~60 fps para las animaciones

// ---------------------------------------------------------------------
// Pulsador iluminado antivandalico (16mm)
//
// GPIO13: confirmado en hardware real (2026-08-25) — funciona
// correctamente. No estaba en la tabla de pines fijados por el diseno
// electronico original (esos GPIO quedaban "reservados"); se eligio
// evitando los ya ocupados y los de arranque/strapping (0, 2, 12, 15)
// y los de solo-entrada (34-39). Ya no es provisional.
// ---------------------------------------------------------------------
#define BUTTON_PIN 13
#define BUTTON_ACTIVE_LOW true
#define BUTTON_DEBOUNCE_MS 40

// ---------------------------------------------------------------------
// Zumbador (futuro, ver docs/04, "Zumbador (futuro)").
// Igual que el boton: GPIO todavia sin fijar en el diseno electronico,
// valor provisional evitando los pines ya ocupados.
// ---------------------------------------------------------------------
#define BUZZER_PIN 26

// ---------------------------------------------------------------------
// Watchdog
// ---------------------------------------------------------------------
#define WATCHDOG_TIMEOUT_MS 5000

// ---------------------------------------------------------------------
// Firmware
// ---------------------------------------------------------------------
#define FIRMWARE_VERSION "1.0.0"

// Tamano maximo de una linea de comando entrante (JSON) por Serial.
#define SERIAL_LINE_BUFFER_SIZE 256

