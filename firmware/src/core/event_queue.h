// SteamMachine UM790 - Firmware ESP32
//
// core/event_queue.h
//
// Cola de eventos interna (05_Firmware_Architecture.md, seccion "Event
// Queue"): RC522 / Button -> EventQueue -> SerialProtocol. Evita que los
// modulos de hardware conozcan el protocolo serie.
//
// Buffer circular de tamano fijo, sin asignacion dinamica (evita
// fragmentar el heap en un microcontrolador). Si se llena, se descarta el
// evento mas antiguo y se registra por el logger de depuracion.

#pragma once

#include <Arduino.h>

enum class EventType {
    NONE,
    BOOT,
    TAG_DETECTED,
    TAG_REMOVED,
    BUTTON,
    ERROR
};

struct FirmwareEvent {
    EventType type = EventType::NONE;
    char uid[9] = {0};       // UID en hex, hasta 8 caracteres + '\0'
    uint8_t error_code = 0;
};

class EventQueue {
public:
    static constexpr uint8_t CAPACITY = 16;

    bool push(const FirmwareEvent &event);
    bool pop(FirmwareEvent &out);
    bool isEmpty() const { return _count == 0; }
    bool isFull() const { return _count == CAPACITY; }

    // Atajos para construir el evento inline.
    bool pushBoot();
    bool pushTag(const char *uid);
    bool pushTagRemoved();
    bool pushButton();
    bool pushError(uint8_t code);

private:
    FirmwareEvent _buffer[CAPACITY];
    uint8_t _head = 0;
    uint8_t _tail = 0;
    uint8_t _count = 0;
};
