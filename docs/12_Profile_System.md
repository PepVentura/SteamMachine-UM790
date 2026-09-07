# SteamMachine UM790

# 12 - Profile System (panel = perfil, no panel = programa)

Version: 0.3 (STEAM, RETRO, DISPAROS, MAINTENANCE y AUTO implementados;
KODI/MUSIC/DESKTOP/NIGHT/DEMO siguen siendo huecos reservados)
Status: Implementado — alcance completo de la v0.2 original en código
y con tests; ver "Pendiente" para los refinamientos que quedan

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
    "running": "#8800FF"
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
  La animación de lanzamiento (`_on_button()`) se queda fija en
  `"launch"` para todos los perfiles — decidido explícitamente
  (2026-09-03) en vez de hacerla configurable por perfil, ver
  "Decisiones cerradas" al final.
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
`led.running`), igual que hoy panel_database.json ya elige un color
por panel — el único cambio es que ahora puede haber un color distinto
para "reposo" y para "en marcha". La animación de lanzamiento
(`_on_button()`) NO es configurable por perfil — ver "Decisiones
cerradas" al final.

---

# Precedencia NFC físico vs. perfil AUTO

**Decisión (2026-09-03, confirmada por el usuario): AUTO se activa
cuando no hay ningún panel físico puesto — no es un panel propio con
su propio tag NFC.**

Con AUTO, hay dos fuentes que pueden decidir el estado de la máquina:
el panel físico insertado y lo que Bazzite está ejecutando en cada
momento. Regla:

1. **Si hay un panel físico insertado, ese panel manda siempre.** AUTO
   no puede "override-ar" un panel físico puesto a mano — si tienes el
   panel RETRO puesto y abres Kodi desde el escritorio, la OLED/LEDs
   se quedan en modo RETRO. AUTO no vigila en ese caso.
2. **En cuanto se retira el panel (sin ninguno puesto), entra AUTO.**
   No hace falta un tag NFC ni una entrada en `panel_database.json`
   para AUTO — es el estado por defecto de "sin panel", no un perfil
   seleccionable por NFC.
3. Cuando AUTO está activo, un componente nuevo (`ProcessWatcher`,
   pendiente de diseñar) hace polling periódico de qué proceso relevante
   está corriendo en Bazzite (Steam, RetroArch, Kodi...) y dispara el
   perfil correspondiente — mismo mecanismo de "cargar perfil" que
   usa un panel físico, solo que el disparador es un proceso detectado
   en vez de un tag NFC.

## Implicación en `core/application.py`

Con esta decisión, el cambio de comportamiento cae directamente en
`_on_tag_removed()` (hoy: `oled.sleep()` + `leds.fade(IDLE_COLOR)`, sin
más) y en `_on_tag_detected()`:

- `_on_tag_removed()` deja de ser un simple "apagar y esperar" — pasa a
  **arrancar el `ProcessWatcher`** (entra en AUTO) en vez de solo poner
  la OLED en reposo.
- `_on_tag_detected()` sigue igual que ahora (carga el perfil del
  panel), pero además debe **detener el `ProcessWatcher`** si estaba
  corriendo, para que AUTO no siga compitiendo por la OLED/LEDs
  mientras hay un panel físico puesto.
- No se crea ninguna clave nueva en `panel_database.json` para AUTO —
  AUTO no tiene UID, es lo que pasa cuando `_pending_panel` está vacío.

---

# Perfiles con contenido en vivo — provider aparte, no gratis

Dos de los perfiles propuestos necesitan datos que cambian mientras el
programa corre, no solo al lanzarlo:

- **RETRO** (nombre del juego + tiempo transcurrido): RetroArch expone
  un canal de **Network Commands** por UDP (puerto 55355 por defecto)
  que permite consultar el contenido cargado. Viable, pero es una
  integración propia (poll periódico + parseo de la respuesta), no
  algo que salga gratis de tener el perfil definido en JSON.
  **Sin implementar todavía.**
- **MAINTENANCE** (CPU/RAM — GPU/FAN quedaron fuera, ver más abajo):
  **implementado en [1.4.5]** — `status/system_stats_provider.py`, vía
  `psutil`. El estado ya conocido por el propio Core (conexión ESP32,
  último NFC leído...) que se mencionaba aquí como "inmediato" NO se
  ha incorporado todavía a la plantilla — de momento solo se usan las
  métricas de `psutil`, fusionar el estado interno de `Application` es
  trabajo pendiente.

Ambos son componentes `StatusProvider` con la misma interfaz
(`snapshot() -> dict`, registrados en `status/status_manager.py`).
`system_stats` (MAINTENANCE) ya existe; `retroarch_network_commands`
(RETRO) sigue pendiente — el mecanismo genérico de `Application`
(`_on_tag_detected()`, plantilla `oled.idle_template` +
`status_provider`) ya está preparado para él, añadirlo no debería
requerir tocar `Application` otra vez, solo el provider nuevo y el
campo en `retro.json`.

---

# Alcance propuesto para v0.2

**Con contenido de OLED definido y una razón de ser clara:**
`STEAM` · `RETRO` · `DISPAROS` · `MAINTENANCE` · `AUTO`

Estado de implementación (`software/config/profiles/`):
- ✅ `STEAM` — migrado ([1.4.0]), `oled.idle` estático.
- ✅ `RETRO` — migrado ([1.4.2]), `oled.idle` estático; el
  `running_template` y el `status_provider` ya están en el JSON pero
  siguen inertes — `Application` todavía no lee ninguno de los dos
  (pendiente de implementar `StatusProvider`, ver "Pendiente").
- ✅ `DISPAROS` — migrado ([1.4.3], selector decidido en [1.4.4]).
  Es un perfil que agrupa varios juegos (`games[]`, catálogo de
  referencia que crecerá) bajo un único panel físico (`112FC103`,
  llamado ahora simplemente "Zombies"). **Decidido (2026-09-03): el
  botón siempre abre Steam Big Picture** (`launcher: "steam"`, tanto
  en el perfil como en el panel) — la lista real de juegos de
  disparos es una Colección de Steam que el usuario organiza a mano
  dentro del propio Steam, no un menú de este proyecto. El panel
  `56A1C003` (HOTD 2 Remake, un panel por juego) se retiró: ya no
  hace falta un panel físico por juego.
- ✅ `AUTO` — implementado ([1.4.6]). `core/process_watcher.py`
  (`ProcessWatcher`, vía `psutil.process_iter()`, poll cada 5s por
  defecto) + campo opcional `auto_match` en cada perfil (hoy: `STEAM`
  → `["steam"]`, `RETRO` → `["retroarch", "retrodeck"]`). Arranca en
  `_on_tag_removed()` y al iniciar la `Application`; se para en
  `_on_tag_detected()` (el panel físico manda siempre). Limitaciones
  conocidas:
  - `DISPAROS` no tiene `auto_match` — el proceso `steam` ya lo
    reclama `STEAM`, y la tabla de coincidencias es plana (un proceso
    solo puede apuntar a un perfil); mientras se juega a HOTD Remake/2,
    AUTO cae en `STEAM`, no en `DISPAROS`.
  - Los nombres de proceso (`retroarch`, `retrodeck`...) son un
    supuesto razonable, no verificado todavía contra el Bazzite real
    del usuario — puede hacer falta ajustarlos tras la primera prueba.
  - No hay debounce por lanzamiento lento: si un programa tarda varios
    segundos en arrancar su proceso real, AUTO no lo detecta hasta que
    aparece, no antes.
- ✅ `MAINTENANCE` — migrado ([1.4.5]). Primer perfil con contenido en
  vivo real: `oled.idle_template` se rellena con
  `StatusProvider("system_stats")` (CPU/RAM vía `psutil`). Limitaciones
  deliberadas de esta primera versión:
  - **Foto fija, no en vivo** — los valores se calculan una sola vez,
    al detectar el panel, no se refrescan mientras el panel sigue
    puesto (el refresco periódico sigue en "Pendiente").
  - **Sin GPU ni FAN** — `psutil` no tiene una forma genérica de leer
    ninguna de las dos (el nombre de los sensores de fan depende de la
    placa base, y la temperatura de GPU necesita el driver específico
    del fabricante) — mejor no mostrar un dato inventado.
  - **Sin panel físico asignado todavía** — no hay UID en
    `panel_database.json` para `MAINTENANCE`; el perfil existe y está
    probado, pero no es alcanzable por NFC hasta que se le asigne un
    panel real.
  - **El botón no lanza nada** (`launcher: null`) — comportamiento
    explícito, no un descuido; `_on_button()` lo reconoce y no
    muestra animación de error.

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

# Decisiones cerradas

- **AUTO se activa sin panel puesto**, no como panel físico propio
  (2026-09-03) — ver "Precedencia NFC físico vs. perfil AUTO" arriba.
- **La animación de lanzamiento (`_on_button()`) no es configurable
  por perfil** (2026-09-03) — se queda fija en `"launch"` para todos
  los perfiles, igual que hoy. Se valoró añadir `led.launch_animation`
  al esquema (permitiría, p. ej., `"loading"` para programas que
  tardan más en arrancar), pero se descartó por no aportar beneficio
  real mientras todos los perfiles usen la misma animación — más
  complejidad sin necesidad concreta detrás. Si en el futuro hace
  falta diferenciar, se puede añadir el campo entonces, sin que esto
  bloquee nada de lo ya implementado.
- **Selector de DISPAROS: el botón siempre abre Steam Big Picture**
  (2026-09-03) — en vez de un menú navegable dentro del dispositivo
  (que habría requerido ampliar el protocolo de `BUTTON` con
  pulsación corta/larga), la lista de juegos de disparos es una
  Colección de Steam que el usuario organiza a mano dentro del propio
  Steam. `games[]` en `disparos.json` queda como registro de
  referencia del catálogo, sin que ningún código lo lea. Como
  consecuencia, el panel `56A1C003` (HOTD 2 Remake, un panel físico
  por juego) se retiró de `panel_database.json` — ya no hace falta un
  panel por juego, con uno solo (`112FC103`, "Zombies") basta.

---

# Pendiente

- **Refresco en vivo de MAINTENANCE** — hoy es una foto fija tomada al
  detectar el panel; falta un mecanismo de actualización periódica
  mientras el panel siga puesto (afecta también a RETRO cuando se
  implemente su `StatusProvider`).
- **GPU y FAN en MAINTENANCE** — sin API genérica en `psutil`; para
  añadirlos hace falta identificar los sensores concretos del hardware
  real (nombres de `sensors_fans()`, driver de la GPU) y no es
  portable sin más entre máquinas distintas.
- **Fusionar el estado interno de `Application`** (conexión ESP32,
  último NFC leído...) en la plantilla de MAINTENANCE — hoy
  `system_stats` solo aporta métricas de `psutil`.
- **Panel físico para MAINTENANCE** — el perfil existe y está probado,
  pero no hay ningún UID en `panel_database.json` asignado todavía.
- **Verificar contra el Bazzite real** los nombres de proceso de
  `auto_match` (`steam`, `retroarch`, `retrodeck`) — supuestos
  razonables, sin confirmar todavía en la máquina física.
- **`DISPAROS` en AUTO** — hoy no participa (ver limitaciones de AUTO
  arriba); decidir si merece la pena resolver la ambigüedad con
  `STEAM` de otra forma (¿mirar también el nombre de la ventana
  activa, no solo el proceso?) o dejarlo así.
- Ampliar el protocolo/firmware de la OLED a más de 2 líneas si se
  quiere el formato de 5 líneas de los mockups originales — tarea de
  firmware, no de este documento.
- Implementar el `StatusProvider` de RetroArch (Network Commands,
  UDP 55355) para RETRO — el de sistema (`psutil`) ya está hecho.
- Contenido de OLED para los perfiles reservados (`KODI`, `MUSIC`,
  `DESKTOP`, `NIGHT`, `DEMO`) cuando se decida incorporarlos.
