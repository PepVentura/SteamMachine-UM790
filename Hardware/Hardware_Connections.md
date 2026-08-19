content = """# SteamMachine UM790 — Conexiones de hardware

> **Estado:** Referencia definitiva de conexiones de hardware  
> **Proyecto:** SteamMachine-UM790  
> **Controlador:** ESP32

Este documento es la referencia actual para el cableado de los componentes ESP32, RC522, OLED, 74AHCT125 y WS2812B.

## 1. Asignación de pines del ESP32

| ESP32 | Función |
|---:|---|
| GPIO5 | RC522 SDA/SS |
| GPIO18 | RC522 SCK |
| GPIO19 | RC522 MISO |
| GPIO23 | RC522 MOSI |
| GPIO27 | RC522 RST |
| GPIO21 | OLED SDA |
| GPIO22 | OLED SCL |
| GPIO25 | Fuente de datos WS2812B |
| 3V3 | Alimentación RC522 + OLED |
| VIN (~4.68 V medidos) | Alimentación 74AHCT125 + WS2812B |
| GND | Tierra común |

## 2. ESP32 → RC522

| RC522 | ESP32 |
|---|---|
| 3.3V | 3V3 |
| GND | GND |
| SDA / SS | GPIO5 |
| SCK | GPIO18 |
| MOSI | GPIO23 |
| MISO | GPIO19 |
| RST | GPIO27 |

**No conectes el RC522 a 5 V.**

![RC522](images/rc522_esp32.svg)

## 3. ESP32 → OLED

| OLED | ESP32 |
|---|---|
| VCC | 3V3 |
| GND | GND |
| SDA | GPIO21 |
| SCL | GPIO22 |

![OLED](images/oled_esp32.svg)

## 4. ESP32 → 74AHCT125 → WS2812B

Solo se utiliza el canal 1 del 74AHCT125.

| 74AHCT125 | Conexión |
|---:|---|
| Pin 14 — VCC | ESP32 VIN (~4.68 V medidos) |
| Pin 7 — GND | GND común |
| Pin 2 — 1A | ESP32 GPIO25 |
| Pin 1 — /1OE | GND |
| Pin 3 — 1Y | 330 Ω → WS2812B DIN |

Ruta de datos:

`GPIO25 → 74AHCT125 1A → 74AHCT125 1Y → 330 Ω → WS2812B DIN`

![74AHCT125](images/74ahct125_ws2812b.svg)

## 5. Desacoplamiento del 74AHCT125

Coloca **un condensador cerámico de 100 nF** directamente entre:

- Pin 14 (VCC)
- Pin 7 (GND)

El condensador no tiene polaridad y debe colocarse físicamente cerca del circuito integrado.

![100 nF](images/74ahct125_100nf.svg)

## 6. WS2812B

El proyecto utiliza aproximadamente **15 cm de tira (~9 LEDs)**.

Se ha verificado el cableado actual de la tira y **el cable verde es DIN/datos**.

| WS2812B | Conexión |
|---|---|
| +5V | ESP32 VIN (~4.68 V medidos) |
| DIN | 330 Ω desde 74AHCT125 1Y |
| GND | GND común |

Sigue la flecha impresa en la tira y conéctalo en su **lado de entrada/DIN**.

![WS2812B](images/ws2812b_connection.svg)

## 7. Condensador de desacoplamiento para WS2812B

Coloca un **condensador electrolítico de 470–1000 µF, de ≥10 V**, cerca del inicio de la tira.

- Condensador `+` → WS2812B +5V
- Condensador `−` → WS2812B GND

![Condensador de desacoplamiento](images/ws2812b_bulk_capacitor.svg)

## 8. Cableado completo

![Cableado completo](images/complete_hardware_wiring.svg)

### Tierra común

Toda la electrónica controlada por el ESP32 comparte la misma línea GND:

- RC522 GND
- OLED GND
- 74AHCT125 GND
- WS2812B GND

## 9. Interfaz del botón de encendido del UM790

El ESP32 **no alimenta al UM790**.

El botón del proyecto se conecta directamente con los **contactos del botón de encendido original del UM790**. No conectes las líneas VIN o 3V3 del ESP32 a la circuitería de alimentación del botón del UM790.

## 10. Componentes

| Cant. | Componente | Propósito |
|---:|---|---|
| 1 | 74AHCT125 | Adaptador de nivel lógico de 3.3 V a 5 V |
| 1 | Resistencia de 330 Ω | Resistencia en serie para WS2812B DIN |
| 1 | Condensador cerámico de 100 nF | Desacoplamiento para 74AHCT125 |
| 1 | Condensador electrolítico de 470–1000 µF ≥10 V | Estabilización de alimentación para WS2812B |
| ~15 cm | Tira WS2812B | Iluminación frontal |

## 11. Lista de verificación

- [ ] RC522 a 3.3 V.
- [ ] OLED a 3.3 V.
- [ ] VIN medido en aproximadamente 4.68 V.
- [ ] Pin 14 del 74AHCT125 → VIN.
- [ ] Pin 7 del 74AHCT125 → GND.
- [ ] 100 nF entre los pines 14 y 7.
- [ ] Pin 1 (/1OE) → GND.
- [ ] GPIO25 → pin 2 (1A).
- [ ] Pin 3 (1Y) → 330 Ω → WS2812B DIN.
- [ ] Cable verde del WS2812B confirmado como DIN.
- [ ] Polaridad del WS2812B verificada.
- [ ] Polaridad del condensador de 470–1000 µF verificada.
- [ ] GND común verificado.
- [ ] Los canales no utilizados del 74AHCT125 no deben quedar flotantes; define sus conexiones antes del ensamblaje permanente.

## 12. Referencia de pines en el firmware

```python
RC522_SS   = 5
RC522_SCK  = 18
RC522_MOSI = 23
RC522_MISO = 19
RC522_RST  = 27

OLED_SDA = 21
OLED_SCL = 22

WS2812B_DATA = 25
