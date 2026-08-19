\# SteamMachine UM790

\# 08 - Software API



Version: 1.0



Status: Draft



\---



\# Objetivo



Este documento define la API interna del software SteamMachine UM790.



No describe la implementación, sino la estructura lógica del sistema, las clases principales y las interfaces entre módulos.



Toda la aplicación estará desarrollada en \*\*Python 3.12 o superior\*\*.



\---



\# Arquitectura General



```

&#x20;                 SteamMachine Core

&#x20;                        │

&#x20;┌──────────────┬─────────┼───────────┬──────────────┐

&#x20;│              │         │           │              │

Config      Serial     Launcher    OLED        LED Manager

&#x20;│              │         │           │              │

&#x20;│              │         │           │              │

Database    ESP32 API   Plugins     UI         Animations

```



\---



\# Estructura del proyecto



```

software/



core/

config/

database/

devices/

launcher/

plugins/

resources/

ui/

utils/

```



\---



\# Core



\## class SteamMachine



Clase principal.



Responsabilidades



\- Inicialización

\- Gestión de eventos

\- Coordinación de módulos

\- Ciclo principal



\### Métodos



```python

initialize()



run()



shutdown()



restart()



load\_configuration()



save\_configuration()

```



\---



\# Config



\## class ConfigurationManager



Responsabilidades



\- Leer configuración

\- Guardar configuración

\- Validar configuración



Métodos



```python

load()



save()



reset()



get()



set()

```



\---



\# Database



\## class PanelDatabase



Responsabilidades



\- Gestionar paneles NFC

\- Buscar UID

\- Añadir paneles

\- Eliminar paneles



Métodos



```python

load()



save()



find(uid)



add()



remove()



update()

```



\---



\# Serial



\## class SerialManager



Responsabilidades



\- Abrir puerto serie

\- Leer mensajes

\- Enviar mensajes

\- Reconexión automática



Métodos



```python

connect()



disconnect()



send()



receive()



is\_connected()

```



\---



\# ESP32 API



\## class ESP32Controller



Responsabilidades



Ocultar completamente el protocolo serie.



El resto del software nunca accederá directamente al puerto serie.



Métodos



```python

oled(text)



oled\_lines(line1,line2)



clear\_oled()



set\_led(color)



set\_brightness(value)



animation(name)



restart()



request\_status()

```



\---



\# Launcher



\## class Launcher



Responsabilidades



Ejecutar plataformas.



Métodos



```python

launch(platform)



stop(platform)



running()



status()

```



\---



\# Plugin Interface



Todos los lanzadores heredarán de



```python

BasePlugin

```



Ejemplo



```python

class SteamPlugin(BasePlugin)

```



Métodos obligatorios



```python

launch()



stop()



status()



configuration()

```



\---



\# Plugins previstos



Steam



RetroBat



TeknoParrot



RPCS3



PCSX2



Dolphin



Citra



Yuzu (si procede)



BigBox



Hyperspin



\---



\# OLED Manager



\## class OLEDManager



Métodos



```python

show\_text()



show\_logo()



show\_status()



clear()



sleep()



wake()

```



\---



\# LED Manager



\## class LEDManager



Métodos



```python

set\_color()



set\_brightness()



animation()



off()



flash()



fade()

```



\---



\# Event Manager



\## class EventManager



Responsabilidades



Toda la comunicación interna utilizará eventos.



Eventos



```

BOOT



TAG\_DETECTED



TAG\_REMOVED



BUTTON



LAUNCH



STOP



ERROR



SHUTDOWN

```



Métodos



```python

subscribe()



publish()



unsubscribe()

```



\---



\# Logger



\## class Logger



Responsabilidades



Registro completo del sistema.



Métodos



```python

info()



warning()



error()



critical()



debug()

```



\---



\# Hardware Monitor



\## class HardwareMonitor



Responsabilidades



Monitorizar



\- Estado ESP32

\- Memoria

\- Temperatura

\- Tiempo de actividad



Métodos



```python

update()



status()



temperature()



memory()

```



\---



\# Theme Manager



\## class ThemeManager



Responsabilidades



Asociar cada plataforma con



\- Color LED

\- Icono

\- Nombre



Métodos



```python

load()



theme(platform)



icon(platform)



color(platform)

```



\---



\# Flujo principal



```

SteamMachine.start()



↓



Configuration.load()



↓



Database.load()



↓



Serial.connect()



↓



ESP32.boot()



↓



Esperar eventos



↓



TAG



↓



Buscar plataforma



↓



Actualizar OLED



↓



Actualizar LED



↓



Esperar botón



↓



Launcher.launch()



↓



Volver a esperar

```



\---



\# Recursos



```

resources/



icons/



fonts/



sounds/



animations/

```



\---



\# Configuración



```

config/



config.json



panel\_database.json



themes.json



launcher.json

```



\---



\# Principios de diseño



\- Cada clase tendrá una única responsabilidad.



\- Ningún módulo accederá directamente al puerto serie excepto SerialManager.



\- Toda la comunicación será mediante eventos.



\- Los plugins nunca accederán directamente al hardware.



\- Todo será fácilmente ampliable.



\---



\# Compatibilidad futura



La arquitectura permitirá añadir:



\- MQTT



\- Home Assistant



\- API REST



\- Aplicación móvil



\- Control por voz



\- Estadísticas



\- Actualizaciones automáticas



\- Diagnóstico remoto



sin modificar el núcleo de la aplicación.



\---



\# Estado



Documento preparado para comenzar el desarrollo del software del PC.

