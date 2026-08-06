\# SteamMachine UM790

\# 11 - Assembly Manual



Version: 1.0



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

\- Barra LED RGB



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



\---



\# Paso 5



\## Instalación del RC522



Fijar al soporte estructural.



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



\---



\# Paso 8



\## Panel frontal



Instalar:



OLED



↓



Pulsador



↓



USB



↓



Barra LED



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



\---



\## RC522



□ Detecta panel.



\---



\## Pulsador



□ Envía evento.



\---



\## USB



□ Reconocido por Windows.



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

\- comprobar alimentación



\---



\## USB no funciona



\- comprobar HUB

\- comprobar cable interno



\---



\# Fin del montaje



El equipo queda listo para comenzar las pruebas descritas en



10\_Test\_Plan.md

