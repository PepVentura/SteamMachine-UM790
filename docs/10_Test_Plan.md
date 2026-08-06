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



Windows



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



\## T040



Arranque



Enviar BOOT.



\---



\## T041



Lectura NFC



Enviar UID correcto.



\---



\## T042



Pulsador



Enviar evento.



\---



\## T043



OLED



Actualizar información.



\---



\## T044



LED



Actualizar color.



\---



\## T045



Recuperación



Desconectar USB.



Reconectar.



Debe recuperar la comunicación.



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



Lanzamiento RetroBat.



\---



\## T057



Lanzamiento RPCS3.



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

