\# SteamMachine UM790

\# 03 - Software Architecture



Version: 1.0

Status: Draft



\---



\# 1. Objetivo



El software de SteamMachine UM790 tiene como objetivo convertir un MiniPC convencional en un sistema modular de entretenimiento controlado mediante paneles NFC intercambiables.



El usuario únicamente debe:



\- colocar un panel frontal

\- pulsar el botón



Todo el resto será completamente automático.



\---



\# 2. Arquitectura General



```

&#x20;                   +-----------------------+

&#x20;                   |     NFC PANEL         |

&#x20;                   +-----------+-----------+

&#x20;                               |

&#x20;                               |

&#x20;                         RC522 Reader

&#x20;                               |

&#x20;                               |

&#x20;                       ESP32 Controller

&#x20;                               |

&#x20;                     USB Serial Communication

&#x20;                               |

&#x20;                               |

&#x20;                SteamMachine Core Application

&#x20;                               |

&#x20;        +----------+-----------+-----------+

&#x20;        |          |           |           |

&#x20;    OLED      LED Controller   Launcher   Logger

&#x20;                               |

&#x20;               +---------------+---------------+

&#x20;               |               |               |

&#x20;            Steam         RetroBat       TeknoParrot

```



\---



\# 3. Componentes



\## ESP32



Responsabilidades



\- Leer el RC522

\- Leer el pulsador

\- Controlar OLED

\- Controlar LEDs

\- Enviar eventos al PC

\- Recibir órdenes del PC



El ESP32 nunca decide qué aplicación ejecutar.



Toda la lógica reside en el PC.



\---



\## SteamMachine Core



Es el proceso principal.



Responsabilidades



\- Inicialización

\- Configuración

\- Gestión de eventos

\- Comunicación con ESP32

\- Carga de perfiles

\- Lanzamiento de aplicaciones



\---



\## Launcher



Responsable de iniciar programas.



Ejemplos



\- Steam

\- RetroBat

\- RPCS3

\- TeknoParrot

\- Dolphin

\- PCSX2



Cada plataforma tendrá su propio módulo.



\---



\## OLED Manager



Muestra



\- Plataforma seleccionada

\- Estado

\- Errores

\- Animaciones

\- Información de carga



\---



\## LED Manager



Controla



\- Color

\- Intensidad

\- Animaciones

\- Efectos



Ejemplos



Steam → Azul



RetroBat → Morado



RPCS3 → Rojo



\---



\## NFC Database



Relaciona UID con plataforma.



Ejemplo



UID



↓



Steam



↓



Icono



↓



Color LED



↓



Aplicación



\---



\# 4. Flujo de funcionamiento



```

Insertar panel NFC



↓



RC522 detecta UID



↓



ESP32 envía UID



↓



Core recibe UID



↓



Busca perfil



↓



Actualiza OLED



↓



Actualiza LEDs



↓



Espera pulsador



↓



Lanza aplicación

```



\---



\# 5. Comunicación ESP32 ↔ PC



Comunicación



USB Serial



115200 bps



Formato



JSON



Ejemplos



ESP32 → PC



```json

{

&#x20;   "event":"tag",

&#x20;   "uid":"04A1C8B2"

}

```



```json

{

&#x20;   "event":"button"

}

```



PC → ESP32



```json

{

&#x20;   "oled":"Steam"

}

```



```json

{

&#x20;   "led":"#0055FF"

}

```



```json

{

&#x20;   "animation":"launch"

}

```



\---



\# 6. Base de datos de paneles



Formato



panel\_database.json



Ejemplo



```json

{

&#x20;   "04A1C8B2":

&#x20;   {

&#x20;       "name":"Steam",

&#x20;       "launcher":"steam.py",

&#x20;       "led":"#0055FF",

&#x20;       "icon":"steam.png"

&#x20;   }

}

```



\---



\# 7. Organización del software



```

software/



core/

&#x20;   app.py

&#x20;   config.py

&#x20;   events.py

&#x20;   logger.py



launcher/

&#x20;   launcher.py

&#x20;   steam.py

&#x20;   retrobat.py

&#x20;   teknoparrot.py

&#x20;   rpcs3.py



esp32/

&#x20;   serial\_manager.py

&#x20;   oled.py

&#x20;   leds.py

&#x20;   nfc.py

&#x20;   button.py



database/

&#x20;   panel\_database.json



resources/

&#x20;   icons/

&#x20;   fonts/

&#x20;   sounds/

```



\---



\# 8. Filosofía del proyecto



El ESP32 es únicamente un periférico inteligente.



Toda la lógica reside en el PC.



Esto permite:



\- actualizar el software sin modificar el firmware

\- añadir plataformas sin reprogramar el ESP32

\- mantener el firmware extremadamente simple



\---



\# 9. Objetivos futuros



\- Actualizaciones OTA del ESP32

\- Plugins para nuevos emuladores

\- Gestión automática de perfiles

\- Integración con Home Assistant

\- API REST

\- Aplicación móvil

\- Sincronización con GitHub



\---



\# Estado



Documento en desarrollo.



Será actualizado conforme avance el proyecto.

