# SteamMachine UM790

# 12 - Profile System (panel = perfil, no panel = programa)

Version: 0.1 (propuesta, sin implementar)
Status: Draft — pendiente de validación antes de tocar código

---

# Objetivo

Sustituir el modelo actual, en el que cada panel NFC apunta directamente
a un `launcher` (un programa: `steam`, `retrodeck`, `hotd_remake`...),
por un modelo de **perfiles**: cada panel apunta a un perfil, y un
perfil agrupa todo el comportamiento asociado — qué aplicación lanza,
qué se muestra en la OLED (en reposo y en ejecución), qué hacen los
LEDs, y en el futuro qué política de ventilación o de botones aplica.

Esto no es una reescritura: es una capa por encima del `Launcher` y los
`OLEDManager`/`LEDManager` actuales (`08_Software_API.md`), pensada para
no romper los paneles que ya funcionan.

---

# Por qué ahora

Con Steam, RetroDECK, RetroArch y los dos paneles de Zombies ya
conviviendo, `panel_database.json` empieza a mezclar dos cosas
distintas bajo el mismo campo `launcher`: "qué programa abrir" y, cada
vez más, "cómo se comporta la máquina mientras ese programa está
activo". El perfil `MAINTENANCE` (panel pensado para desarrollo, sin
lanzar ningún programa, solo mostrar telemetría) es el caso que deja
más claro que un panel NFC no siempre corresponde a "abrir X" — a
veces corresponde a "ponte en este modo".

---

# Modelo de datos

## Perfil (nuevo)

Cada perfil vive en su propio fichero JSON, en
`software/config/profiles/<id>.json`. Añadir un perfil nuevo = añadir
un fichero; no requiere tocar `launcher.py` **si** el perfil reutiliza
un `launcher` ya existente (Steam, RetroArch...). Si el perfil necesita
lanzar un programa nuevo, sigue haciendo falta un plugin nuevo de
`BasePlugin`, igual que hoy — el sistema de perfiles no elimina esa
capa, la organiza mejor.

```json
{
  "id": "RETRO",
  "name": "Retro (SNES / PS2)",
  "launcher": "retrodeck",
  "led": {
    "idle": "#8800FF",
    "running": "#8800FF",
    "launch_animation": "launch"
  },
  "oled": {
    "idle": ["STEAM MACHINE", "RETRO · SNES/PS2"],
    "running_template": ["{game_name}", "{elapsed_time}"]
  },
  "status_provider": "retroarch_network_commands"
}
```

- `launcher`: igual que el campo actual de `panel_database.json` —
  la clave que ya usa `Launcher.launch()`.
- `led.idle` / `led.running`: color en reposo y color mientras el
  programa está activo (hoy solo existe un color por panel; separarlo
  permite, por ejemplo, que LEDs cambien de color al empezar a jugar).
  `led.launch_animation` debe ser uno de los nombres ya soportados por
  el firmware (`ANIMATIONS` en `devices/led_manager.py`: idle, loading,
  launch, rainbow, error, success, shutdown) — **no se inventan
  animaciones nuevas en el perfil**, el perfil solo elige entre las que
  ya existen.
- `oled.idle`: líneas a mostrar mientras el panel está puesto pero el
  programa no se ha lanzado (o no se está monitorizando).
- `oled.running_template`: líneas a mostrar mientras el programa está
  en marcha, con marcadores `{variable}` — ver "Motor de plantillas"
  más abajo.
- `status_provider`: opcional. Nombre de un componente que alimenta las
  variables de `running_template` en vivo (ver más abajo). Si se omite,
  `running_template` no se usa y la OLED se queda en `oled.idle` todo
  el rato.

## `panel_database.json` (cambio mínimo, retrocompatible)

```json
{
  "04B2D9C3": {
    "name": "RetroDECK",
    "profile": "RETRO",
    "led": "#8800FF",
    "icon": "retrodeck.png"
  }
}
```

Se añade el campo `profile` (opcional). Si un panel no lo tiene,
**sigue funcionando exactamente igual que hoy**, usando `launcher`
directamente como hasta ahora — no hace falta migrar todos los paneles
de golpe. `name`, `led` e `icon` se mantienen como override manual por
panel (por si dos paneles distintos comparten perfil pero quieres un
color de LED o un nombre distinto en cada uno — p. ej. dos paneles
`DISPAROS` para HOTD Remake y HOTD 2 Remake, ambos con `profile:
"DISPAROS"` pero `launcher` distinto).

---

# Motor de plantillas de OLED — limitación real a tener en cuenta

**El protocolo actual solo admite 2 líneas de texto** (`04_Communication_Protocol.md`,
comandos `oled` / `oled2`) — así lo implementa `OLEDManager.show_status(line1, line2)`
hoy mismo. Los mockups de 5 líneas de la propuesta original (título,
línea en blanco, subtítulo, línea en blanco, valor) no caben en el
firmware tal como está ahora mismo.

Para la v0.2, el motor de plantillas trabaja con **listas de como
mucho 2 elementos** (una por línea física), por ejemplo:

```
"idle":             ["STEAM MACHINE", "RETRO · SNES/PS2"]
"running_template": ["{game_name}", "{elapsed_time}"]
```

Ampliar el firmware/protocolo a más líneas (o a un modo de texto libre
con saltos de línea) es una tarea de firmware aparte, no de este
sistema de perfiles — lo dejo anotado en "Pendiente" al final, pero no
lo doy por hecho aquí.

---

# LEDs por perfil

No hace falta ampliar `LEDManager`: ya expone `set_color()` y
`animation(name)` con el conjunto fijo de animaciones del firmware. El
perfil simplemente **elige** entre lo que ya existe (`led.idle`,
`led.running`, `led.launch_animation`), igual que hoy panel_database.json
ya elige un color por panel — el único cambio es que ahora puede haber
un color distinto para "reposo" y para "en marcha".

---

# Precedencia NFC físico vs. perfil AUTO

Con AUTO, hay dos fuentes que pueden decidir el estado de la máquina:
el panel físico insertado y lo que Bazzite está ejecutando en cada
momento. Regla propuesta, para no tener dos sistemas peleando por el
control:

1. **Si hay un panel físico insertado y NO es el panel AUTO, ese panel
   manda siempre.** AUTO no puede "override-ar" un panel físico puesto
   a mano — si tienes el panel RETRO puesto y abres Kodi desde el
   escritorio, la OLED/LEDs se quedan en modo RETRO. AUTO no vigila en
   ese caso.
2. **AUTO solo actúa cuando el panel insertado es el panel AUTO, o
   cuando no hay ningún panel insertado** (a decidir cuál de las dos
   — para v0.2 propongo la primera: AUTO es también un panel físico
   propio, más simple y más predecible que "vigilar siempre que no
   haya nada puesto").
3. Cuando AUTO está activo, un componente nuevo (`ProcessWatcher`,
   pendiente de diseñar) hace polling periódico de qué proceso relevante
   está corriendo en Bazzite (Steam, RetroArch, Kodi...) y dispara el
   perfil correspondiente — mismo mecanismo de "cargar perfil" que
   usa un panel físico, solo que el disparador es un proceso detectado
   en vez de un tag NFC.

---

# Perfiles con contenido en vivo — provider aparte, no gratis

Dos de los perfiles propuestos necesitan datos que cambian mientras el
programa corre, no solo al lanzarlo:

- **RETRO** (nombre del juego + tiempo transcurrido): RetroArch expone
  un canal de **Network Commands** por UDP (puerto 55355 por defecto)
  que permite consultar el contenido cargado. Viable, pero es una
  integración propia (poll periódico + parseo de la respuesta), no
  algo que salga gratis de tener el perfil definido en JSON.
- **MAINTENANCE** (CPU/GPU/FAN/RAM/estado ESP32-NFC-OLED): datos del
  propio sistema (vía `psutil` o lectura directa de `/sys`) más el
  estado ya conocido por el propio Core (conexión ESP32, último NFC
  leído, etc. — esto sí es inmediato, ya lo tiene `Application`).

Ambos quedan como componentes `StatusProvider` aparte (interfaz común:
"dame un dict de variables para rellenar la plantilla"), fuera del
alcance de la primera versión del sistema de perfiles — el sistema de
perfiles debe quedar preparado para que un `status_provider` exista,
pero implementar `retroarch_network_commands` y `system_stats` es
trabajo posterior.

---

# Alcance propuesto para v0.2

**Con contenido de OLED definido y una razón de ser clara:**
`STEAM` · `RETRO` · `DISPAROS` · `MAINTENANCE` · `AUTO`

`DISPAROS` es el mismo concepto que el panel **Zombies** ya existente
en `panel_database.json` (`hotd_remake` / `hotd2_remake`) — incorpora
esos dos paneles como `profile: "DISPAROS"` en vez de crear un nombre
nuevo para lo mismo.

**Reservados, sin contenido de OLED diseñado todavía (huecos en el
esquema, para que añadirlos después sea trivial, pero sin decidir su
pantalla ahora):** `KODI` · `MUSIC` · `DESKTOP` · `NIGHT` · `DEMO`

---

# Cambios de código necesarios (resumen, no implementado)

- `software/config/profiles/*.json` — un fichero por perfil (nuevo).
- `software/core/profile_manager.py` — `ProfileManager` (nuevo): carga
  los JSON de perfiles, resuelve `panel["profile"]` a un perfil
  completo, y sabe rellenar `running_template` a partir de lo que le
  dé el `status_provider` correspondiente.
- `software/core/application.py`, `_on_tag_detected()` /
  `_on_button()`: si el panel tiene `profile`, resolverlo vía
  `ProfileManager` y usar `oled.idle` / `led.idle` en vez de
  `panel["name"]` / `panel["led"]` directamente; si no tiene
  `profile`, comportamiento actual sin cambios (retrocompatible).
- `software/launcher/*` — sin cambios; los perfiles siguen apuntando a
  las claves de `Launcher` que ya existen.
- Nuevo (fuera de esta primera entrega): `ProcessWatcher` (para AUTO) y
  los `StatusProvider` de RetroArch y de sistema.

---

# Pendiente

- Decidir la regla exacta de activación de AUTO (punto 2 de
  "Precedencia" — panel físico propio vs. "sin panel insertado").
- Ampliar el protocolo/firmware de la OLED a más de 2 líneas si se
  quiere el formato de 5 líneas de los mockups originales — tarea de
  firmware, no de este documento.
- Diseñar `ProcessWatcher` (qué procesos vigilar en Bazzite y cada
  cuánto).
- Implementar los `StatusProvider` de RetroArch (Network Commands,
  UDP 55355) y de sistema (`psutil`).
- Contenido de OLED para los perfiles reservados (`KODI`, `MUSIC`,
  `DESKTOP`, `NIGHT`, `DEMO`) cuando se decida incorporarlos.
