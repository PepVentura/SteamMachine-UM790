\# SteamMachine UM790

\# 09 - Coding Standards



Version: 1.0



Status: Active



\---



\# Objetivo



Este documento define las normas de programación utilizadas en el proyecto SteamMachine UM790.



Su finalidad es garantizar:



\- Legibilidad.

\- Uniformidad.

\- Escalabilidad.

\- Facilidad de mantenimiento.

\- Facilidad de colaboración.



Todas las contribuciones deberán respetar estas normas.



\---



\# Lenguajes utilizados



\## OpenSCAD



Diseño mecánico.



\---



\## Python



Software principal.



Versión mínima



Python 3.12



\---



\## C++



Firmware ESP32



Framework



Arduino ESP32



\---



\# Organización del proyecto



```

SteamMachine-UM790/



docs/



openscad/



software/



firmware/



resources/



stl/

```



Nunca deberán mezclarse archivos de distintas disciplinas.



\---



\# Convenciones de nombres



\## Archivos



Siempre



snake\_case



Correcto



```

panel\_database.py



serial\_manager.py



front\_panel.scad

```



Incorrecto



```

PanelDatabase.py



FrontPanel.scad



serialManager.py

```



\---



\# Clases Python



Siempre



PascalCase



```

SteamMachine



SerialManager



PanelDatabase



Launcher

```



\---



\# Métodos



Siempre



snake\_case



```

load\_configuration()



launch\_platform()



read\_tag()

```



\---



\# Variables



Siempre



snake\_case



```

panel\_uid



serial\_port



current\_theme

```



\---



\# Constantes



Siempre



UPPER\_CASE



```

SERIAL\_SPEED



MAX\_RETRIES



DEFAULT\_THEME

```



\---



\# OpenSCAD



\## Archivos



Un módulo importante por archivo.



Ejemplo



```

um790.scad



rc522.scad



esp32.scad



noctua.scad

```



\---



\# Módulos



Siempre



snake\_case



```

module rc522()



module esp32()



module oled()

```



\---



\# Variables OpenSCAD



Siempre



snake\_case



```

wall\_thickness



panel\_height



fan\_offset

```



\---



\# Comentarios



Cada archivo comenzará con



```

//

// SteamMachine UM790

//

// Nombre del módulo

//

// Descripción

//

```



\---



\# Comentarios de sección



```

//////////////////////////////////////////////////////

// RC522 SUPPORT

//////////////////////////////////////////////////////

```



\---



\# Longitud de líneas



Python



Máximo



100 caracteres



OpenSCAD



Preferiblemente



100 caracteres



\---



\# Indentación



Python



4 espacios



Nunca TAB.



OpenSCAD



4 espacios.



\---



\# Documentación



Todas las clases públicas deberán incluir docstrings.



Ejemplo



```python

class SerialManager:

&#x20;   """

&#x20;   Gestiona la comunicación entre el PC y el ESP32.

&#x20;   """

```



\---



\# Manejo de errores



Nunca ignorar excepciones.



Incorrecto



```python

except:

&#x20;   pass

```



Correcto



```python

except Exception as e:

&#x20;   logger.error(e)

```



\---



\# Logging



No utilizar print() para depuración permanente.



Siempre



```

logger.debug()



logger.info()



logger.warning()



logger.error()



logger.critical()

```



\---



\# Configuración



Nunca escribir parámetros directamente en el código.



Siempre utilizar



```

config.json



themes.json



launcher.json

```



\---



\# Arquitectura



Cada clase tendrá una única responsabilidad.



Ejemplos



Correcto



```

SerialManager



OLEDManager



LEDManager

```



Incorrecto



```

ESP32EverythingManager

```



\---



\# Dependencias



Las dependencias deberán mantenerse al mínimo.



Solo se añadirán cuando exista una ventaja clara.



\---



\# Commits Git



Formato



```

tipo: descripción

```



Ejemplos



```

feat: add RC522 support



fix: correct OLED alignment



docs: update firmware architecture



refactor: simplify launcher



test: add collision validation

```



\---



\# Tipos permitidos



```

feat



fix



docs



refactor



style



test



build



chore

```



\---



\# Ramas



Principal



```

main

```



Desarrollo



```

develop

```



Características



```

feature/chassis



feature/firmware



feature/launcher

```



Correcciones



```

hotfix/serial



hotfix/oled

```



\---



\# Versionado



Semantic Versioning



```

Major.Minor.Patch

```



Ejemplo



```

1.0.0



1.1.0



1.1.2



2.0.0

```



\---



\# Recursos gráficos



Todos los iconos



PNG



Fondo transparente



Resolución recomendada



256×256



\---



\# STL



Nombre



```

front\_panel\_v1.stl



rear\_panel\_v2.stl



foot\_left\_v1.stl

```



Nunca



```

pieza\_final2\_ok.stl

```



\---



\# OpenSCAD



No utilizar números mágicos.



Incorrecto



```

translate(\[18,32,6])

```



Correcto



```

translate(\[

&#x20;   panel\_offset\_x,

&#x20;   panel\_offset\_y,

&#x20;   support\_height

])

```



\---



\# TODO



Las tareas pendientes utilizarán



```python

\# TODO:

```



Nunca



```

\# arreglar después

```



\---



\# Filosofía



Antes de escribir código:



\- Diseñar.

\- Documentar.

\- Revisar.



Después:



\- Programar.

\- Probar.

\- Integrar.



Nunca al revés.



\---



\# Regla de oro



No diseñar una pieza mecánica sin haber validado previamente el ensamblaje virtual.



No escribir firmware sin protocolo definido.



No escribir software sin API definida.



Toda decisión importante deberá quedar documentada.



\---



\# Estado



Documento activo.



Será actualizado conforme evolucione el proyecto.

