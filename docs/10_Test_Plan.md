\# SteamMachine UM790

\# 10 - Test Plan



Version: 1.0



Status: Active



\---



\# Objetivo



Este documento define el procedimiento de validación completo del proyecto SteamMachine UM790.



Cada fase del proyecto deberá superar las pruebas correspondientes antes de considerarse finalizada.



No se avanzará a la siguiente fase hasta completar satisfactoriamente la anterior.



\---



\# Tipos de pruebas



Las pruebas se dividen en seis categorías:



\- Mecánicas

\- Térmicas

\- Eléctricas

\- Firmware

\- Software

\- Integración



\---



\# 1. Validación del ensamblaje virtual



\## Objetivo



Verificar que todos los componentes pueden coexistir sin interferencias.



\## Pruebas



\### T001 — Colisión de componentes



Comprobar:



\- UM790

\- Ventilador

\- RC522

\- ESP32

\- HUB USB

\- OLED

\- Pulsador

\- USB frontales



Resultado esperado



Ninguna colisión.



Estado



Pendiente



\---



\### T002 — Holguras de montaje



Verificar:



\- Cableado

\- Tornillos

\- Insertos

\- Conectores



Holgura mínima



3 mm



Resultado esperado



Sin interferencias.



\---



\### T003 — Accesibilidad



Verificar acceso a:



\- Tornillos

\- Panel trasero

\- USB

\- OLED

\- Ventilador



Resultado esperado



Acceso posible sin desmontar el equipo completo.



\---



\# 2. Validación mecánica



\## T010 — Chasis inferior



Comprobar:



\- Rigidez

\- Planitud

\- Ajuste de insertos

\- Soportes



Resultado



Sin deformaciones.



\---



\## T011 — Chasis superior



Verificar:



\- Ajuste

\- Tornillería

\- Ventilación



\---



\## T012 — Panel frontal



Verificar



\- Imán

\- OLED

\- USB

\- Pulsador

\- Barra LED



\---



\## T013 — Panel trasero



Verificar



\- Todos los conectores accesibles



\---



\## T014 — Paneles NFC



Verificar



\- Inserción

\- Extracción

\- Lectura NFC



Resultado esperado



100 % de lectura.



\---



\# 3. Validación térmica



\## Objetivo



Garantizar el funcionamiento continuo.



\---



\## T020 — Reposo



Equipo



Bazzite



30 minutos



Registrar



CPU



SSD



Temperatura ambiente



\---



\## T021 — Carga máxima



Ejecutar



Prime95



\+



FurMark



Durante



30 minutos



Registrar



Temperaturas



RPM



Ruido



\---



\## Límites



CPU



< 85°C



SSD



< 70°C



Ventilador



Sin vibraciones.



\---



\# 4. Validación eléctrica



\## T030



ESP32



Arranque correcto.



\---



\## T031



OLED



Mostrar texto.



\---



\## T032



Barra LED



Todos los colores.



\---



\## T033



RC522



Detectar paneles.



\---



\## T034



USB frontales



Transferencia de archivos.



\---



\# 5. Validación firmware



Pruebas realizadas a mano por el monitor serie de PlatformIO
(`pio device monitor`), sobre el ESP32-WROOM-32D DevKit real ya
cableado — ver `firmware/README.md`, sección "Prueba de integración",
para el procedimiento paso a paso.



\## T040



Arranque



Enviar BOOT.



Resultado: ✔ Superado (2026-08-25). Al arrancar (o tras pulsar RESET
con el monitor abierto) aparece `{"event":"boot","firmware":"1.0.0"}`,
precedido del ruido normal del bootloader del ESP32.



\---



\## T041



Lectura NFC



Enviar UID correcto.



Resultado: ⚠️ Parcial (2026-08-25). Acercar un tag genera
`{"event":"tag","uid":"..."}` con un UID de 8 caracteres hex —
correcto. Pero se detectó un fallo real probando desde el Core:
`{"event":"tag_removed"}` se disparaba a los ~450ms aunque el tag
siguiera físicamente puesto (causa: `PICC_HaltA()` dejaba la tarjeta
en un estado que no responde al sondeo siguiente — ver CHANGELOG.md
v1.1.4). Corregido en el firmware; pendiente de reflashear y
confirmar en hardware real.



\---



\## T042



Pulsador



Enviar evento.



Resultado: ✔ Superado (2026-08-25). Cada pulsación genera
`{"event":"button"}`. Confirmado en GPIO13 (ver
`firmware/src/config.h`) — deja de estar marcado como pin provisional.



\---



\## T043



OLED



Actualizar información.



Resultado: ✔ Superado (2026-08-25). `{"cmd":"oled",...}`,
`{"cmd":"oled2",...}` y `{"cmd":"oled_clear"}` funcionan correctamente
en hardware real.



\---



\## T044



LED



Actualizar color.



Resultado: ✔ Superado (2026-08-25), tras una incidencia real que se
documenta aquí porque fue instructiva: la primera vez que se probó
(`{"cmd":"led","color":"#FF0000"}`), la tira no encendía, aunque el
comando se enviaba correctamente (confirmado con `--echo` en el
monitor). Se aisló el problema desconectando el nivelador lógico
74AHCT125 y conectando el ESP32 directo a un tramo de prueba de 8
LEDs: encendió bien. Con el 74AHCT125 en el circuito, nada — causa más
probable, el pin /1OE del chip flotante en vez de a GND (fallo típico
de este componente). Se decidió retirar el 74AHCT125 del diseño por
completo en vez de depurar el cableado del chip; la tira (8 LEDs,
confirmado como dato real y definitivo) funciona bien recibiendo la
señal directa del GPIO25 a 3.3V. Ver CHANGELOG.md v1.1.3 para el
historial completo de esta decisión, y
`Hardware/Hardware_Connections.md` para el cableado actualizado.



\---



\## T045



Recuperación



Desconectar USB.



Reconectar.



Debe recuperar la comunicación.



Resultado: ✔ Superado (2026-08-25). Tras un reinicio (equivalente
eléctricamente a desconectar/reconectar el USB), el ESP32 arranca
limpio y vuelve a mandar `{"event":"boot","firmware":"1.0.0"}`. Nota:
Windows puede reasignar el número de puerto COM al reconectar (visto
pasar de COM10 a COM7) — el Core lo detecta automáticamente por
VID:PID, así que no debería ser un problema; a tener en cuenta si se
fija el puerto a mano en `config.json`.



\---



\# 6. Validación software



\## T050



Carga configuración.



\---



\## T051



Carga base de datos.



\---



\## T052



Reconocimiento de panel.



\---



\## T053



Cambio OLED.



\---



\## T054



Cambio LED.



\---



\## T055



Lanzamiento de Steam.



\---



\## T056



Lanzamiento RetroDECK.



\---



\## T057



Lanzamiento de un emulador dentro de RetroDECK (p.ej. PS3 via RPCS3 integrado).



\---



\## T058



Lanzamiento TeknoParrot.



\---



\## T059



Salida correcta.



\---



\# 7. Validación integración



\## T060



Sistema apagado.



Encender.



Debe iniciar correctamente.



\---



\## T061



Cambiar panel.



Actualizar OLED.



Actualizar LEDs.



Esperar botón.



\---



\## T062



Lanzar aplicación.



\---



\## T063



Cerrar aplicación.



Volver al estado Idle.



\---



\## T064



Repetir



100 veces.



Sin errores.



\---



\# 8. Ensayos prolongados



\## T070



Funcionamiento continuo



24 horas.



\---



\## T071



500 cambios de panel NFC.



\---



\## T072



500 pulsaciones.



\---



\## T073



100 lanzamientos de aplicaciones.



\---



\# 9. Criterios de aceptación



Cada prueba tendrá uno de estos estados.



PASS



FAIL



BLOCKED



NOT TESTED



\---



\# 10. Registro



Cada prueba deberá registrar



Fecha



Versión



Responsable



Resultado



Observaciones



\---



\# 11. Checklist de entrega



☐ Ensamblaje virtual validado



☐ Chasis impreso



☐ Paneles ajustados



☐ Temperaturas correctas



☐ Firmware estable



☐ Software estable



☐ Comunicación estable



☐ Integración completada



☐ Documentación actualizada



☐ STL publicados



☐ Release GitHub creada



\---



\# Estado



Documento activo.



Será actualizado conforme avance el proyecto.

