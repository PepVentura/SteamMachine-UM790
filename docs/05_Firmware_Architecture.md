\# SteamMachine UM790

\# 05 - Firmware Architecture



Version: 1.0



Status: Draft



\---



\# Objetivo



Este documento define la arquitectura del firmware del controlador ESP32 utilizado en SteamMachine UM790.



El firmware debe ser:



\- modular

\- estable

\- fácilmente ampliable

\- independiente del software del PC



El ESP32 actúa únicamente como controlador hardware.



Toda la lógica del sistema reside en el PC.



\---



\# Responsabilidades del ESP32



El firmware será responsable únicamente de:



\- Inicializar el hardware

\- Leer el RC522

\- Leer el pulsador

\- Controlar la pantalla OLED

\- Controlar la barra LED

\- Comunicarse con el PC

\- Informar del estado del hardware



No ejecutará ninguna lógica relacionada con plataformas o emuladores.



\---



\# Arquitectura



```

&#x20;                MAIN LOOP



&#x20;                     │



&#x20;    ┌────────────────┼────────────────┐

&#x20;    │                │                │

&#x20;Hardware        Communication      Services

```



\---



\# Organización del código



```

firmware/



src/



&#x20;   main.cpp



&#x20;   config.h



&#x20;   core/



&#x20;       application.cpp

&#x20;       application.h



&#x20;       event\_queue.cpp

&#x20;       event\_queue.h



&#x20;       scheduler.cpp

&#x20;       scheduler.h



&#x20;   hardware/



&#x20;       rc522.cpp

&#x20;       rc522.h



&#x20;       oled.cpp

&#x20;       oled.h



&#x20;       leds.cpp

&#x20;       leds.h



&#x20;       button.cpp

&#x20;       button.h



&#x20;   communication/



&#x20;       serial\_protocol.cpp

&#x20;       serial\_protocol.h



&#x20;       json\_parser.cpp

&#x20;       json\_parser.h



&#x20;   services/



&#x20;       animations.cpp

&#x20;       animations.h



&#x20;       diagnostics.cpp

&#x20;       diagnostics.h



&#x20;       watchdog.cpp

&#x20;       watchdog.h



&#x20;   utils/



&#x20;       logger.cpp

&#x20;       logger.h



&#x20;       timers.cpp

&#x20;       timers.h

```



\---



\# Flujo de arranque



```

Power On



↓



Inicializar GPIO



↓



Inicializar OLED



↓



Inicializar LEDs



↓



Inicializar RC522



↓



Inicializar Puerto Serie



↓



Enviar evento BOOT



↓



Esperar comandos del PC

```



\---



\# Estados del firmware



```

BOOT



↓



IDLE



↓



TAG DETECTED



↓



WAIT BUTTON



↓



RUNNING



↓



IDLE

```



\---



\# Módulos Hardware



\## RC522



Responsabilidades



\- Inicializar SPI



\- Detectar tarjeta



\- Leer UID



\- Detectar retirada



Eventos generados



tag



tag\_removed



\---



\## OLED



Responsabilidades



\- Inicialización



\- Mostrar texto



\- Mostrar iconos



\- Mostrar estado



No almacena información.



Siempre representa el estado enviado por el PC.



\---



\## LED Manager



Responsabilidades



\- Color fijo



\- Intensidad



\- Animaciones



\- Efectos



Animaciones disponibles



\- idle



\- loading



\- launch



\- success



\- error



\- shutdown



\---



\## Button



Responsabilidades



\- Detectar pulsación



\- Antirrebote



Eventos



button



\---



\# Comunicación Serie



Todos los mensajes utilizan JSON.



El firmware nunca interpreta el contenido funcional.



Simplemente recibe comandos y responde.



\---



\# Event Queue



Toda la comunicación entre módulos se realiza mediante una cola de eventos.



Ejemplo



```

RC522



↓



Event Queue



↓



Serial Manager

```



Esto evita dependencias entre módulos.



\---



\# Watchdog



El firmware incorporará un Watchdog.



Si alguna tarea deja de responder:



\- registrar error



\- reiniciar controlador



\---



\# Diagnóstico



El firmware podrá responder:



Versión



Estado



Temperatura



Memoria libre



Tiempo desde arranque



Ejemplo



```json

{

&#x20;   "event":"status",

&#x20;   "uptime":1254,

&#x20;   "heap":201344

}

```



\---



\# Configuración



Toda la configuración estará centralizada en



config.h



Ejemplos



Velocidad Serie



Brillo LED



Tiempo antirrebote



Timeout RC522



Pin OLED



Pin LEDs



Pin Pulsador



\---



\# Librerías previstas



Arduino Framework



ESP32 Arduino Core



ArduinoJson



MFRC522



Adafruit SSD1306



Adafruit GFX



FastLED



SPI



Wire



\---



\# Principios de diseño



Cada módulo tendrá una única responsabilidad.



No existirán variables globales innecesarias.



Toda la comunicación utilizará eventos.



No se utilizarán retardos bloqueantes (`delay()`).



Se priorizará el uso de temporizadores basados en `millis()`.



\---



\# Futuras ampliaciones



El diseño permite añadir sin modificar la arquitectura:



\- Control PWM del ventilador

\- Sensor de temperatura

\- Sensor de humedad

\- Wi-Fi

\- OTA

\- MQTT

\- Bluetooth

\- Home Assistant

\- Pantalla a color

\- Segundo lector NFC



\---



\# Estado



Versión 1.0



Documento preparado para comenzar el desarrollo del firmware ESP32.

