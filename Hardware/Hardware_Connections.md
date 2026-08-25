# SteamMachine UM790 — Conexiones de hardware

> **Estado:** Referencia definitiva de conexiones de hardware  
> **Proyecto:** SteamMachine-UM790  
> **Controlador:** ESP32

Este documento es la referencia actual para el cableado de los componentes ESP32, RC522, OLED y WS2812B.

> **2026-08-25**: eliminado el 74AHCT125 del diseño. Se probó con 8
> LEDs conectados directamente al GPIO25 (sin nivelador) y funcionó
> correctamente — la propia tira WS2812B admite el nivel lógico de
> 3.3V del ESP32 sin problema en un tramo corto. El nivelador se
> añadió originalmente por precaución, pero resultó ser el origen de
> un fallo real (con toda probabilidad, el pin /1OE del chip quedó
> flotante — ver el punto correspondiente que ya estaba en la lista de
> verificación de este mismo documento antes de este cambio).

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
| GPIO25 | Fuente de datos WS2812B (directo, sin nivelador) |
| 3V3 | Alimentación RC522 + OLED |
| VIN (~4.68 V medidos) | Alimentación WS2812B |
| GND | Tierra común |

## 2. Cable y código de colores

Cable 22 AWG / 0,32 mm², cobre estañado, aislamiento de silicona.

Código de colores (5 colores, para mantener el cableado organizado en todo el montaje — especialmente entre RC522, OLED, WS2812B y ESP32):

| Color | Se reserva para |
|---|---|
| 🔴 Rojo | +5V |
| ⚫ Negro | GND |
| 🟡 Amarillo | Datos / señales |
| 🔵 Azul | SPI |
| 🟢 Verde | I²C |

Misma especificación que `docs/07_Hardware_Specification.md`, sección
"Cableado" — si se cambia el esquema de colores, actualizar ambos
documentos.

## 3. ESP32 → RC522

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

## 4. ESP32 → OLED

| OLED | ESP32 |
|---|---|
| VCC | 3V3 |
| GND | GND |
| SDA | GPIO21 |
| SCL | GPIO22 |

![OLED](images/oled_esp32.svg)

## 5. ESP32 → WS2812B (directo, sin nivelador)

Ruta de datos:

`GPIO25 → 330 Ω → WS2812B DIN`

El resistor en serie sigue recomendándose como buena práctica general
(protege el primer LED de picos y mejora la integridad de la señal),
aunque ya no hay nivelador de por medio.

## 6. WS2812B

El proyecto utiliza **8 LEDs** (dato real confirmado, 2026-08-25 — antes se estimaba ~15cm/~9 LEDs).

Se ha verificado el cableado actual de la tira y **el cable verde es DIN/datos**.

| WS2812B | Conexión |
|---|---|
| +5V | ESP32 VIN (~4.68 V medidos) |
| DIN | 330 Ω desde GPIO25 |
| GND | GND común |

Sigue la flecha impresa en la tira y conéctalo en su **lado de entrada/DIN**.

![WS2812B](images/ws2812b_connection.svg)

## 7. Condensador de desacoplamiento para WS2812B

Colocar un **condensador electrolítico de 470–1000 µF, de ≥10 V**, cerca del inicio de la tira sigue siendo recomendable — es independiente del nivelador que se ha retirado.

- Condensador `+` → WS2812B +5V
- Condensador `−` → WS2812B GND

![Condensador de desacoplamiento](images/ws2812b_bulk_capacitor.svg)

## 8. Cableado completo

> ⚠️ El diagrama de abajo (`complete_hardware_wiring.svg`) todavía
> muestra el 74AHCT125 — quedó desactualizado con este cambio y no se
> ha podido regenerar aquí. Usa la ruta de datos de la sección 5 como
> referencia real hasta que se actualice la imagen.

![Cableado completo](images/complete_hardware_wiring.svg)

### Tierra común

Toda la electrónica controlada por el ESP32 comparte la misma línea GND:

- RC522 GND
- OLED GND
- WS2812B GND

## 9. Interfaz del botón de encendido del UM790

El ESP32 **no alimenta al UM790**.

El botón del proyecto se conecta directamente con los **contactos del botón de encendido original del UM790**. No conectes las líneas VIN o 3V3 del ESP32 a la circuitería de alimentación del botón del UM790.

## 10. Componentes

| Cant. | Componente | Propósito |
|---:|---|---|
| 1 | Resistencia de 330 Ω | Resistencia en serie para WS2812B DIN |
| 1 | Condensador electrolítico de 470–1000 µF ≥10 V | Estabilización de alimentación para WS2812B |
| 8 LEDs | Tira WS2812B | Iluminación frontal |

## 11. Lista de verificación

- [ ] RC522 a 3.3 V.
- [ ] OLED a 3.3 V.
- [ ] VIN medido en aproximadamente 4.68 V.
- [ ] GPIO25 → 330 Ω → WS2812B DIN.
- [ ] Cable verde del WS2812B confirmado como DIN.
- [ ] Polaridad del WS2812B verificada.
- [ ] Polaridad del condensador de 470–1000 µF verificada.
- [ ] GND común verificado.

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
```
