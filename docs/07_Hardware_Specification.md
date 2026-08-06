\# SteamMachine UM790

\# 07 - Hardware Specification



Version: 1.0



Status: Active



\---



\# Objetivo



Este documento recoge las especificaciones técnicas completas del hardware utilizado en el proyecto SteamMachine UM790.



Su finalidad es servir como referencia única durante el diseño mecánico, el desarrollo del firmware y el montaje final.



\---



\# 1. Equipo principal



\## Mini PC



Modelo



Minisforum UM790 Pro



Función



Equipo principal de ejecución.



\### Dimensiones mecánicas



PCB



122.0 × 119.5 mm



Altura aproximada



38 mm



Separación recomendada respecto a la base



12 mm



Sistema de fijación



4 soportes M3



\---



\# 2. Ventilación



\## Ventilador principal



Modelo



Noctua NF-A12x15 PWM chromax.black.swap



Características



120 × 120 × 15 mm



PWM 4 pines



Muy bajo nivel sonoro



Posición



Parte superior del equipo



Centrado respecto al disipador del UM790



Flujo



Entrada por la base



Salida por la tapa



\---



\# 3. Controlador



\## ESP32 Terminal Adapter



Dimensiones



78 × 63 mm



Taladros



73 × 58 mm



Tornillería



M3



Función



Control completo del frontal



\- RC522

\- OLED

\- LEDs

\- Pulsador

\- Comunicación USB Serie



\---



\# 4. Lector NFC



Modelo



MFRC522



Interfaz



SPI



Función



Lectura de paneles NFC intercambiables



Posición



Centrado horizontalmente



A media altura del panel frontal superior



El soporte pertenece al chasis, no al panel intercambiable.



\---



\# 5. Pantalla



Modelo



OLED I²C



Zona visible



27 × 27 mm



Función



Estado del sistema



Plataforma seleccionada



Mensajes



Animaciones



\---



\# 6. Pulsador



Tipo



Metálico antivandálico



Rosca



16 mm



Longitud roscada



55 mm



Montaje



Panel frontal



\---



\# 7. USB frontales



Tipo



Prolongadores USB empotrables



Diámetro del orificio



29 mm



Cantidad



2



Conexión



USB HUB interno



\---



\# 8. HUB USB



Modelo



USB 3.x de 4 puertos



Posición



Lateral interior



Conexión



UM790



↓



HUB



↓



USB frontales



\---



\# 9. Barra LED



Tipo



RGB direccionable



Control



ESP32



Funciones



Color por plataforma



Animaciones



Estado



Errores



\---



\# 10. Paneles intercambiables



Material



PLA



Sistema de fijación



Imanes de neodimio



Alojamiento NFC



Empotrado



Contenido



Logotipo en relieve



Tag NFC



\---



\# 11. Imanes



Disponibles



3 × 2 mm



6 × 2 mm



Aplicación



Panel frontal



Paneles intercambiables



\---



\# 12. Insertos roscados



Disponibles



M2



M2.5



M3



M4



M5



M6



M8



Aplicaciones



Panel trasero



Bastidor



Soportes



\---



\# 13. Tornillería prevista



M2



Electrónica



M3



ESP32



UM790



Ventilador



Bastidor



M4



Panel trasero (si fuese necesario)



\---



\# 14. Fuente de alimentación



Tipo



Externa



Ventajas



Menor temperatura interior



Más espacio disponible



Mayor facilidad de mantenimiento



\---



\# 15. Carcasa



Dimensiones exteriores



Anchura



156 mm



Profundidad



162.4 mm



Altura



148 mm



Altura total con patas



152 mm



\---



\# 16. Refrigeración



Entrada



Base



Salida



Parte superior



Ventilador



Noctua NF-A12x15



Objetivo



Mantener una circulación vertical continua.



\---



\# 17. Materiales de impresión



Material recomendado



PLA+



PETG (opcional)



Altura de capa



0.20 mm



Boquilla



0.4 mm



\---



\# 18. Impresora



Modelo



Anycubic Kobra X



Área útil



Suficiente para imprimir todas las piezas sin dividirlas.



\---



\# 19. Objetivos mecánicos



\- Fácil mantenimiento.

\- Cableado ordenado.

\- Buena ventilación.

\- Acceso directo al panel trasero.

\- Paneles NFC intercambiables.

\- Bastidor rígido.

\- Sin interferencias entre componentes.



\---



\# 20. Estado



Especificaciones mecánicas prácticamente completas.



Este documento deberá actualizarse únicamente cuando se incorporen nuevos componentes físicos.

