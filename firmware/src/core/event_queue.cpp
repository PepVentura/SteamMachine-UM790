// SteamMachine UM790 - Firmware ESP32
//
// core/event_queue.cpp

#include "core/event_queue.h"
#include "utils/logger.h"

bool EventQueue::push(const FirmwareEvent &event) {
    if (isFull()) {
        logger::error("EventQueue llena, se descarta evento", static_cast<int>(event.type));
        return false;
    }
    _buffer[_head] = event;
    _head = (_head + 1) % CAPACITY;
    _count++;
    return true;
}

bool EventQueue::pop(FirmwareEvent &out) {
    if (isEmpty()) {
        return false;
    }
    out = _buffer[_tail];
    _tail = (_tail + 1) % CAPACITY;
    _count--;
    return true;
}

bool EventQueue::pushBoot() {
    FirmwareEvent e;
    e.type = EventType::BOOT;
    return push(e);
}

bool EventQueue::pushTag(const char *uid) {
    FirmwareEvent e;
    e.type = EventType::TAG_DETECTED;
    strncpy(e.uid, uid, sizeof(e.uid) - 1);
    e.uid[sizeof(e.uid) - 1] = '\0';
    return push(e);
}

bool EventQueue::pushTagRemoved() {
    FirmwareEvent e;
    e.type = EventType::TAG_REMOVED;
    return push(e);
}

bool EventQueue::pushButton() {
    FirmwareEvent e;
    e.type = EventType::BUTTON;
    return push(e);
}

bool EventQueue::pushError(uint8_t code) {
    FirmwareEvent e;
    e.type = EventType::ERROR;
    e.error_code = code;
    return push(e);
}
