\# SteamMachine UM790

\# 06 - Development Roadmap



Version: 1.0



Status: Active



\---



\# Objetivo



Este documento define la planificación completa del proyecto SteamMachine UM790.



El objetivo es disponer de un sistema completamente funcional basado en un MiniPC UM790 Pro alojado en una carcasa con las dimensiones originales de Steam Machine, controlado mediante paneles NFC intercambiables.



Cada fase deberá quedar completamente terminada antes de comenzar la siguiente.



\---



\# Estado actual



\## Hardware



\- ✔ Medidas reales recopiladas

\- ✔ Componentes seleccionados

\- ✔ Arquitectura mecánica definida

\- ✔ Frontal definitivo aprobado

\- ✔ Montaje físico completado



\## Software



\- ✔ Arquitectura definida

\- ✔ Protocolo de comunicación definido

\- ✔ Arquitectura firmware definida

\- ✔ Firmware ESP32 implementado y validado en hardware real (compila, flashea y arranca; protocolo boot/error confirmado por monitor serie)

\- ✔ SteamMachine Core implementado, con tests unitarios

\- ✔ Arranque automático documentado (systemd)



\---



\# Fase 1

\## Ingeniería Mecánica



Objetivo



Completar el ensamblaje virtual.



Tareas



\- Implantación definitiva del UM790

\- Implantación del Noctua

\- Implantación del RC522

\- Implantación del ESP32

\- Implantación del HUB USB

\- Implantación del OLED

\- Implantación del pulsador

\- Implantación de los USB frontales



Resultado esperado



virtual\_assembly\_v1.scad completamente validado.



Estado



🟡 En desarrollo



\---



\# Fase 2

\## Bastidor inferior



Objetivo



Diseñar la estructura principal del equipo.



Incluye



\- Soportes UM790

\- Soporte HUB

\- Soporte ESP32

\- Soporte RC522

\- Insertos roscados

\- Conductos de cableado

\- Entradas de aire



Resultado



chassis\_lower.scad



Estado



Pendiente



\---



\# Fase 3

\## Bastidor superior



Objetivo



Diseñar la estructura superior.



Incluye



\- Soporte Noctua

\- Rejillas

\- Salida de aire

\- Rigidez estructural



Resultado



chassis\_upper.scad



Estado



Pendiente



\---



\# Fase 4

\## Panel trasero



Objetivo



Diseñar el panel posterior.



Incluye



\- HDMI

\- USB

\- RJ45

\- Audio

\- Alimentación

\- Tornillería



Resultado



rear\_panel.scad



Estado



Pendiente



\---



\# Fase 5

\## Frontal



Objetivo



Diseñar el frontal definitivo.



Incluye



\- OLED

\- Pulsador

\- USB

\- Barra LED

\- Panel inferior



Resultado



front\_panel.scad



Estado



Pendiente



\---



\# Fase 6

\## Paneles NFC



Objetivo



Diseñar los paneles intercambiables.



Características



\- Imán de fijación

\- Alojamiento del tag NFC

\- Logotipo en relieve

\- Sistema de extracción



Resultado



front\_panel\_steam.scad



front\_panel\_retrobat.scad



front\_panel\_rpcs3.scad



...



Estado



Pendiente



\---



\# Fase 7

\## Firmware ESP32



Objetivo



Programar el controlador.



Funciones



\- RC522

\- OLED

\- LEDs

\- Pulsador

\- Serie USB



Estado



Completado (ver firmware/, ESP32-WROOM-32D DevKit sobre PlatformIO/Arduino). Validado en hardware real: compila, flashea y arranca correctamente, y el RC522, la barra LED (8 LEDs, directo sin nivelador) y el pulsador (GPIO13) ya funcionan probados en el hardware real. Pendiente de validar la OLED.



\---



\# Fase 8

\## SteamMachine Core



Objetivo



Aplicación principal para Bazzite (Linux).



Funciones



\- Comunicación serie

\- Base de datos NFC

\- Lanzador

\- Gestión OLED

\- Gestión LEDs

\- Configuración



Estado



Completado (ver software/), con tests unitarios para todos los modulos (LEDManager, OLEDManager, Application, PanelDatabase, Launcher).



\---



\# Fase 9

\## Integración



Objetivo



Montaje completo.



Incluye



\- Cableado

\- Firmware

\- Software

\- Pruebas



Estado



Cableado, firmware y software completados. Pendiente la primera prueba con hardware real (ver checklist en firmware/README.md, sección "Prueba de integracion").



\---



\# Fase 10

\## Optimización



Objetivo



Mejorar la experiencia de usuario.



Incluye



\- Animaciones

\- Arranque automático

\- Actualizaciones

\- Diagnóstico

\- Plugins



Estado



Animaciones y diagnóstico completados. Arranque automático (systemd) documentado en software/README.md. Actualizaciones y plugins adicionales, pendientes.



\---



\# Criterios de aceptación



Cada fase deberá cumplir:



\- Sin errores de compilación.

\- Documentación actualizada.

\- Archivos STL generados cuando corresponda.

\- Validación funcional.

\- Commit en GitHub.



\---



\# Gestión de versiones



Major



Cambios estructurales.



Minor



Nuevas funciones.



Patch



Correcciones.



Ejemplo



1.0.0



1.1.0



1.1.3



2.0.0



\---



\# Riesgos



Hardware



\- Temperatura

\- Interferencias NFC

\- Longitud de cableado

\- Rigidez del chasis



Software



\- Comunicación serie

\- Gestión de errores

\- Compatibilidad Bazzite / actualizaciones de RetroDECK y Lutris

\- Actualizaciones



\---



\# Próximo objetivo



Completar al 100 % el ensamblaje virtual antes de comenzar el diseño del bastidor.



Ninguna pieza imprimible deberá diseñarse hasta validar completamente la implantación de todos los componentes.



\---



\# Estado del proyecto



Arquitectura: ██████████ 100%



Documentación: █████████░ 90%



Ensamblaje virtual: ███████░░░ 70%



Diseño mecánico: ██░░░░░░░░ 20%



Firmware: ░░░░░░░░░░ 0%



Software PC: ░░░░░░░░░░ 0%



Integración: ░░░░░░░░░░ 0%



Proyecto global: ████░░░░░░ 40%

