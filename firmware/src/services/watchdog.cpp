// SteamMachine UM790 - Firmware ESP32
//
// services/watchdog.cpp

#include "services/watchdog.h"
#include "config.h"
#include "utils/logger.h"

#if defined(ESP32)
#include <esp_task_wdt.h>
#endif

namespace watchdog {

void begin() {
#if defined(ESP32)
#if ESP_ARDUINO_VERSION_MAJOR >= 3
    esp_task_wdt_config_t wdt_config = {
        .timeout_ms = WATCHDOG_TIMEOUT_MS,
        .idle_core_mask = 0,
        .trigger_panic = true,
    };
    esp_task_wdt_init(&wdt_config);
#else
    esp_task_wdt_init(WATCHDOG_TIMEOUT_MS / 1000, true);
#endif
    esp_task_wdt_add(NULL);
    logger::info("Watchdog activo (ms)", WATCHDOG_TIMEOUT_MS);
#endif
}

void feed() {
#if defined(ESP32)
    esp_task_wdt_reset();
#endif
}

} // namespace watchdog
