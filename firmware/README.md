# SteamMachine UM790 - Firmware ESP32

Firmware para el ESP32-WROOM-32D DevKit (HW-394) que controla el RC522,
la OLED, la barra LED y el pulsador, y habla el protocolo JSON de
`docs/04_Communication_Protocol.md` con el Core (`software/`).
Arquitectura: `docs/05_Firmware_Architecture.md`.

> **Validado en hardware real**: compila (con `fastled/FastLED` fijado
> a `3.7.8` en `platformio.ini` — versiones más recientes tienen un
> fallo de compilación conocido, ver "Solución de problemas" en
> `GUIA_INICIO.md`), flashea y arranca correctamente en un
> ESP32-WROOM-32D DevKit real; el evento `boot` se confirmó por
> monitor serie. Pendiente de validar el RC522, la OLED, la barra LED
> y el pulsador con el cableado completo (ver checklist más abajo).

## Compilar y flashear

Requiere [PlatformIO](https://platformio.org/) (extension de VSCode o CLI):

```bash
cd firmware
pio run                # compila
pio run --target upload -e esp32doit-devkit-v1   # flashea (con el ESP32 en modo bootloader si hace falta)
pio device monitor -b 115200                       # monitor Serial (protocolo JSON; ver nota abajo)
```

> Ojo: `pio device monitor` te va a mostrar el trafico JSON crudo del
> protocolo, no logs de depuracion (esos van por Serial2, ver mas abajo).

## Depuracion

`Serial` (USB) esta reservado en exclusiva para el protocolo con el PC.
Los logs de depuracion van por `Serial2` (pines 16/17 por defecto,
`config.h`), y solo se compilan si activas el flag:

```ini
build_flags = -DDEBUG_SERIAL2=1
```

en `platformio.ini`. Con un adaptador USB-serie en los pines 16/17
puedes ver los logs sin tocar el canal del protocolo.

## Pinout (fijado por el diseño electrónico)

`docs/07_Hardware_Specification.md` no fijaba GPIOs, así que la
asignación real vive en `src/config.h`. El resto de GPIO del
ESP32-WROOM-32D DevKit quedan reservados sin usar todavía.

| Función                  | Pin(es)             |
|----------------------------|----------------------|
| RC522 SDA/SS                | GPIO5                |
| RC522 SCK                   | GPIO18               |
| RC522 MISO                  | GPIO19               |
| RC522 MOSI                  | GPIO23               |
| RC522 RST                   | GPIO27               |
| OLED SDA                    | GPIO21               |
| OLED SCL                    | GPIO22               |
| Barra LED (WS2812B, directa sin nivelador) | GPIO25 (`LED_COUNT` a ajustar) |
| Pulsador                    | GPIO13 (confirmado en hardware real, 2026-08-25) |
| Zumbador (futuro)           | GPIO26 (provisional — no fijado en el diseño electrónico) |
| Debug Serial2                | RX 16, TX 17 (provisional) |

**Alimentación:**

| Riel        | Alimenta            |
|--------------|----------------------|
| 3V3           | RC522 + OLED          |
| VIN (~4.68V)  | WS2812B   |
| GND            | masa común             |

El dato de la barra LED sale del ESP32 en 3.3V (GPIO25) y va **directo**
a la WS2812B, sin nivelador — el diseño original preveía un 74AHCT125
(3.3V→5V) de por medio, pero se retiró (2026-08-25) tras comprobar en
un tramo real de 8 LEDs que la tira funciona bien sin él: con el chip
en el circuito no encendía nada (causa más probable: el pin /1OE
flotante), y conectado directo sí. Ver
`Hardware/Hardware_Connections.md` para el historial completo de este
diagnóstico.

Los únicos pines que aún no vienen confirmados en hardware real son el
zumbador y el UART de depuración; están marcados como "provisional" en
`config.h` — confírmalos o cámbialos cuando lo tengas claro.

**Cable y código de colores** (ver `docs/07_Hardware_Specification.md`,
sección "Cableado"): 22 AWG / 0,32 mm², cobre estañado, aislamiento de
silicona. Rojo = +5V, Negro = GND, Amarillo = datos/señales, Azul =
SPI (RC522), Verde = I²C (OLED).


## Estructura

Sigue exactamente `docs/05_Firmware_Architecture.md`:

```
src/
  main.cpp
  config.h
  core/            Application (orquesta todo), EventQueue
  hardware/        rc522, oled, leds, button (un modulo = una responsabilidad)
  communication/    serial_protocol (transporte), json_parser (parseo de comandos)
  services/        animations (motor no bloqueante), diagnostics, watchdog
  utils/           logger (Serial2), timers (Every, basado en millis())
```

## Animaciones

`services/animations.h` implementa los 7 nombres de `docs/04`
(idle, loading, launch, rainbow, error, success, shutdown) como
funciones de un frame cada una, llamadas sin bloquear desde el loop
principal. Un comando `led` (color sólido) o `brightness` cancela
cualquier animación en curso, igual que en el Core (`LEDManager.set_color`
en `software/devices/led_manager.py`).

## Pendiente / no cubierto todavía

- Zumbador (`cmd: beep`): el comando se parsea y no da error, pero no
  hace nada hasta que exista el hardware.
- Sin tests automáticos (el firmware depende de librerías de hardware
  reales — RC522, OLED, FastLED — difíciles de mockear sin más
  infraestructura; se podría plantear un entorno `pio test` nativo con
  dobles de esas librerías si interesa más adelante).
- Compilación, flasheo y arranque ya validados en hardware real
  (ver aviso arriba); pendiente de validar RC522, OLED, LEDs y pulsador
  con el cableado completo.

## Prueba de integración (primera vez con hardware real)

Con el cableado ya montado, antes de dar por buena la Fase 9 del roadmap:

1. `pio run` — compila. ✔ Validado en un ESP32-WROOM-32D DevKit real.
2. `pio run --target upload -e esp32doit-devkit-v1` — flashea el ESP32. ✔ Validado.
3. `pio device monitor -b 115200` — tras el ruido propio del arranque
   del ESP32 (líneas tipo `ets Jul 29 2019...`), deberías ver
   `{"event":"boot","firmware":"1.0.0"}`. ✔ Validado. Si además ves
   `{"event":"error","code":1}`, el RC522 todavía no responde — normal
   si no está cableado aún, revisar pinout si ya lo está.
4. Acerca un tag NFC al RC522 → debería aparecer `{"event":"tag","uid":"..."}`
   con un UID de 8 caracteres hex. Retíralo → `{"event":"tag_removed"}`. ✔ Validado.
5. Pulsa el botón → `{"event":"button"}`. ✔ Validado (GPIO13).
6. Desde el mismo monitor, escribe a mano una línea y pulsa Enter para
   probar los comandos PC→ESP32, por ejemplo:
   `{"cmd":"oled","text":"Hola"}` (debe aparecer en la pantalla) ✔ Validado,
   `{"cmd":"led","color":"#00FF00"}` (la barra debe ponerse verde) ✔ Validado (8 LEDs, directo sin nivelador),
   `{"cmd":"animation","name":"rainbow"}`.
7. Solo cuando 3-6 funcionen, pasa a probar con el Core real: en
   `software/config/config.json` pon `"simulate": false` y sigue las
   instrucciones de `software/README.md` para localizar el puerto serie.
