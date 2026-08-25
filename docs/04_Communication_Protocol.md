\# SteamMachine UM790

\# 04 - Communication Protocol



Version: 1.0



Status: Draft



\---



\# Objetivo



Este documento define el protocolo de comunicación entre el PC (SteamMachine Core) y el controlador ESP32.



El protocolo pretende ser:



\- sencillo

\- legible

\- extensible

\- independiente del hardware



Toda la comunicación se realiza mediante USB Serie.



\---



\# Configuración del puerto serie



Puerto



Automático (detección por VID/PID)



Velocidad



115200 baudios



Bits



8



Paridad



None



Stop



1



Control de flujo



No



\---



\# Filosofía



El ESP32 únicamente actúa como un dispositivo inteligente de entrada/salida.



Nunca decide qué programa ejecutar.



Toda la lógica reside en el PC.



\---



\# Formato de mensajes



Todos los mensajes utilizan JSON.



Cada línea finaliza con:



LF



Ejemplo:



```text

{"event":"button"}

```



\---



\# ESP32 → PC



\## Tag detectado



```json

{

&#x20;   "event":"tag",

&#x20;   "uid":"04A1C8B2"

}

```



Descripción



Se envía inmediatamente al detectar un nuevo panel NFC.



\---



\## Tag retirado



```json

{

&#x20;   "event":"tag\_removed"

}

```



\---



\## Pulsador



```json

{

&#x20;   "event":"button"

}

```



\---



\## Inicio



```json

{

&#x20;   "event":"boot",

&#x20;   "firmware":"1.0.0"

}

```



\---



\## Error



```json

{

&#x20;   "event":"error",

&#x20;   "code":5

}

```



\---



\# PC → ESP32



\## Mostrar texto OLED



```json

{

&#x20;   "cmd":"oled",

&#x20;   "text":"Steam"

}

```



\---



\## Mostrar dos líneas



```json

{

&#x20;   "cmd":"oled2",

&#x20;   "line1":"Steam",

&#x20;   "line2":"Ready"

}

```



\---



\## Limpiar OLED



```json

{

&#x20;   "cmd":"oled\_clear"

}

```



\---



\## Color LED



```json

{

&#x20;   "cmd":"led",

&#x20;   "color":"#0055FF"

}

```



\---



\## Brillo LED



```json

{

&#x20;   "cmd":"brightness",

&#x20;   "value":128

}

```



Valor



0-255



\---



\## Animación



```json

{

&#x20;   "cmd":"animation",

&#x20;   "name":"launch"

}

```



Animaciones previstas



\- idle

\- loading

\- launch

\- rainbow

\- error

\- success

\- shutdown



\---



\## Zumbador (futuro)



```json

{

&#x20;   "cmd":"beep",

&#x20;   "duration":150

}

```



\---



\## Reinicio ESP32



```json

{

&#x20;   "cmd":"restart"

}

```



\---



\## Estado / diagnóstico



```json

{

&#x20;   "cmd":"status"

}

```



Descripción



Solicita al ESP32 que responda con el evento `status` descrito en la sección "Diagnóstico".



\---



\# Tabla de eventos



| Evento | Origen | Descripción |

|---------|---------|-------------|

| boot | ESP32 | Arranque |

| tag | ESP32 | Panel detectado |

| tag\_removed | ESP32 | Panel retirado |

| button | ESP32 | Pulsador |

| error | ESP32 | Error |

| oled | PC | Mostrar texto |

| oled2 | PC | Mostrar dos líneas |

| oled\_clear | PC | Limpiar pantalla |

| led | PC | Cambiar color |

| brightness | PC | Cambiar brillo |

| animation | PC | Ejecutar animación |

| restart | PC | Reiniciar ESP32 |

| status | PC | Solicitar diagnóstico (uptime, memoria libre) |

| status | ESP32 | Respuesta al diagnóstico solicitado |



\---



\# Códigos de error



| Código | Significado |

|----------|-------------|

| 1 | RC522 no encontrado |

| 2 | OLED no encontrada |

| 3 | Error LED |

| 4 | Error memoria |

| 5 | Error desconocido |



\---



\# Secuencia típica



```

ESP32 arranca



↓



boot



↓



PC responde



↓



oled "SteamMachine"



↓



led azul



↓



Usuario coloca panel



↓



tag



↓



PC busca perfil



↓



oled "Steam"



↓



led azul Steam



↓



Usuario pulsa botón



↓



button



↓



PC lanza Steam



↓



animation launch



↓



oled "Launching..."

```



\---



\# Compatibilidad



El firmware siempre enviará:



```

boot

```



incluyendo:



\- versión firmware



El PC podrá decidir si el firmware es compatible.



\---



\# Futuras ampliaciones



\- Control del ventilador

\- Lectura de temperatura

\- Medidor RPM

\- OTA

\- WiFi

\- Bluetooth

\- MQTT

\- Home Assistant

\- Diagnóstico remoto



\---



\# Estado



Versión 1.0



Se considera suficientemente estable para comenzar el desarrollo del firmware ESP32 y del SteamMachine Core.

