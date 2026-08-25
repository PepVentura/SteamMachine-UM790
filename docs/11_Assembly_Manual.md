\# SteamMachine UM790

\# 11 - Assembly Manual



Version: 1.1



Status: Draft



\---



\# Objetivo



Este documento describe el procedimiento completo de montaje de SteamMachine UM790.



Debe permitir ensamblar el equipo desde cero siguiendo una secuencia lógica, minimizando errores y evitando desmontajes innecesarios.



\---



\# Herramientas necesarias



\## Herramientas



\- Destornillador Phillips PH0

\- Destornillador Phillips PH1

\- Llaves Allen (si procede)

\- Alicates de punta fina

\- Pinzas de electrónica

\- Cúter

\- Regla metálica

\- Calibre digital

\- Multímetro



\---



\## Herramientas para impresión



\- Espátula

\- Lima fina

\- Lija P400

\- Lija P800



\---



\## Herramientas para insertos



\- Soldador regulable



Temperatura recomendada



220 °C



Punta cilíndrica



\---



\# Materiales



\## Tornillería



M2



M3



M4 (si procede)



\---



\## Insertos térmicos



M2



M2.5



M3



M4



\---



\## Imanes



3 × 2 mm



6 × 2 mm



\---



\# Componentes



\- Minisforum UM790 Pro

\- ESP32 Terminal Adapter

\- RC522

\- Noctua NF-A12x15 PWM

\- HUB USB

\- OLED

\- Pulsador metálico

\- Prolongadores USB empotrables

\- Tira LED direccionable WS2812B, 5 V (aprox. 15 cm / 9 LED)



\---



\# Comprobación previa



Antes de comenzar:



□ Todas las piezas impresas sin deformaciones.



□ Todos los insertos disponibles.



□ Tornillería completa.



□ Componentes probados individualmente.



\---



\# Orden de montaje



La secuencia debe respetarse.



\---



\# Paso 1



\## Preparación del chasis inferior



Instalar:



\- insertos térmicos

\- patas

\- soportes



Verificar:



□ Todos los insertos completamente asentados.



\---



\# Paso 2



\## Montaje del UM790



Instalar:



\- separadores

\- UM790



No apretar completamente hasta verificar la alineación.



Comprobaciones



□ Conectores traseros alineados.



□ Separación respecto a la base.



\---



\# Paso 3



\## Instalación del HUB USB



Fijar soporte.



Conectar:



UM790



↓



HUB



Todavía no conectar los prolongadores.



\---



\# Paso 4



\## Instalación del ESP32



Montar:



\- separadores M3



Conectar:



alimentación



USB



No conectar todavía RC522.

El ESP32 se alimentará mediante USB-C durante las pruebas. La línea de 5 V disponible en la placa se reservará para la pequeña sección de tira WS2812B.



\---



\# Paso 5



\## Instalación del RC522



Fijar al soporte estructural.



Conexiones al ESP32:

| RC522 | ESP32 |
|---|---|
| 3.3V | 3V3 |
| GND | GND |
| SDA / SS | GPIO5 |
| SCK | GPIO18 |
| MISO | GPIO19 |
| MOSI | GPIO23 |
| RST | GPIO27 |
| IRQ | NC |

El RC522 trabaja a 3,3 V. No alimentar el módulo a 5 V.

Verificar:



La antena queda centrada respecto al panel frontal.



No respecto a la PCB.



\---



\# Paso 6



\## Instalación del ventilador



Fijar Noctua.



Orientación



Entrada:



base



Salida:



tapa



Comprobar:



\- sentido del flujo

\- cable accesible



\---



\# Paso 7



\## Panel trasero



Montar



Panel



↓



Tornillos



↓



Insertos



No forzar.



**Pulsador de encendido del UM790** (añadido 2026-08-22, ver
CHANGELOG — independiente del ESP32):



↓



Insertar el pulsador en el hueco redondo del panel trasero (a ~2,5cm
del lateral derecho, altura media entre el disipador del UM790 y el
ventilador)



↓



Cablear sus dos contactos directamente al header de encendido de la
placa del UM790 — NO al ESP32, es un circuito totalmente aparte



\---



\# Paso 8



\## Panel frontal



Instalar:



OLED



↓



Brida de sujeción de la OLED (2 tornillos M2 en los insertos térmicos
a los lados de la pantalla — ver CHANGELOG 2026-08-22 y
`openscad/parts/03_panels/oled_bracket.scad`; sustituye al pegamento)



↓



Pulsador



↓



USB



↓



Barra LED (canal rediseñado 2026-08-22: costillas repartidas en vez
de repisa — ver CHANGELOG)



↓



Cableado



No colocar todavía el panel intercambiable.



\---



\# Paso 9



\## Cableado



Orden recomendado



1



Ventilador



2



ESP32



3



OLED



4



RC522



5



LED



6



USB



Agrupar mediante bridas.



Nunca cruzar el ventilador.



### Pinout definitivo del ESP32



#### RC522 — SPI



| Señal | GPIO ESP32 | Alimentación |
|---|---:|---|
| SDA / SS | GPIO5 | — |
| SCK | GPIO18 | — |
| MISO | GPIO19 | — |
| MOSI | GPIO23 | — |
| RST | GPIO27 | — |
| IRQ | NC | — |
| VCC | — | 3V3 |
| GND | — | GND |



#### OLED — I²C



| Señal | GPIO ESP32 | Alimentación |
|---|---:|---|
| SDA | GPIO21 | — |
| SCL | GPIO22 | — |
| VCC | — | 3V3 |
| GND | — | GND |



La dirección I²C del módulo OLED debe comprobarse durante la puesta en marcha. El módulo instalado dispone de selección de dirección indicada en la propia PCB.



#### Tira LED — WS2812B



Se instalarán **8 LED** (dato real confirmado, 2026-08-25).



| Señal | Conexión |
|---|---|
| DIN | GPIO25 |
| +5V | 5V / VIN del ESP32 |
| GND | GND común |
| DOUT | NC |



La tira se alimenta desde la línea de 5 V disponible cuando el ESP32 está alimentado por USB-C. **GPIO25 se utiliza exclusivamente como señal de datos y nunca como alimentación.**



Para la entrada DIN se recomienda una resistencia serie de **330–470 Ω**. Se recomienda además un condensador de **470–1000 µF**, tensión nominal mínima 10 V, entre +5 V y GND cerca de la entrada de la tira.



El firmware deberá limitar el brillo máximo para mantener bajo el consumo. Con 8 LED, el consumo teórico máximo a blanco y brillo total es aproximadamente 480 mA, por lo que el brillo limitado será la configuración normal de funcionamiento.



**Todas las masas (GND) del ESP32, RC522, OLED y WS2812B deben estar eléctricamente comunes.**



No alimentar la tira WS2812B desde un GPIO.



### Resumen de conexiones



```text
ESP32
├── RC522 (SPI)
│   ├── SDA/SS → GPIO5
│   ├── SCK    → GPIO18
│   ├── MISO   → GPIO19
│   ├── MOSI   → GPIO23
│   ├── RST    → GPIO27
│   ├── VCC    → 3V3
│   └── GND    → GND
│
├── OLED (I²C)
│   ├── SDA    → GPIO21
│   ├── SCL    → GPIO22
│   ├── VCC    → 3V3
│   └── GND    → GND
│
└── WS2812B (8 LED)
    ├── DIN    → GPIO25
    ├── +5V    → 5V/VIN
    └── GND    → GND
```



\---



\# Paso 10



\## Panel superior



Montar.



Verificar:



No presiona ningún cable.



\---



\# Paso 11



\## Panel NFC



Instalar:



Imanes



↓



Tag NFC



↓



Panel



Comprobar:



Inserción



Extracción



Lectura



\---



\# Primera puesta en marcha



Conectar



Fuente



↓



USB ESP32



↓



Pantalla



Debe aparecer:



SteamMachine



↓



Ready



\---



\# Pruebas iniciales



\## OLED



□ Texto correcto.



\---



\## LED



□ Color correcto.

□ Brillo limitado según configuración de firmware.

□ Los 8 LED encienden correctamente sin reiniciar el ESP32.



\---



\## RC522



□ Detecta panel.



\---



\## Pulsador



□ Envía evento.



\---



\## USB



□ Reconocido por el sistema (`lsusb`).



\---



\## Ventilador



□ Gira correctamente.



\---



\# Checklist



\## Mecánica



□ Todos los tornillos instalados.



□ Sin piezas sueltas.



□ Sin rozamientos.



\---



\## Cableado



□ Ordenado.



□ Sin cables en el ventilador.



\---



\## Firmware



□ Arranca.



□ Detecta panel.



\---



\## Software



□ Reconoce panel.



□ Cambia OLED.



□ Cambia LEDs.



□ Lanza plataforma.



\---



\# Mantenimiento



Cada seis meses



\- limpiar ventilador

\- revisar tornillos

\- limpiar rejillas



Cada doce meses



\- revisar pasta térmica (si procede)

\- comprobar ventilador



\---



\# Sustitución de paneles



1



Retirar panel.



2



Insertar nuevo panel.



3



Esperar actualización OLED.



4



Pulsar botón.



\---



\# Resolución de problemas



\## No detecta panel



\- comprobar RC522

\- comprobar UID

\- comprobar distancia



\---



\## OLED apagada



\- comprobar I²C

\- comprobar alimentación



\---



\## LED apagados



\- comprobar ESP32

\- comprobar GPIO25 / señal DIN

\- comprobar 5 V / VIN

\- comprobar GND común

\- comprobar resistencia serie de 330–470 Ω

\- comprobar alimentación



\---



\## USB no funciona



\- comprobar HUB

\- comprobar cable interno



\---



\# Fin del montaje



El equipo queda listo para comenzar las pruebas descritas en



10\_Test\_Plan.md

