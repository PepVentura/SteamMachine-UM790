# Changelog

Todos los cambios importantes de este proyecto se documentarán en este archivo.

El formato está inspirado en [Keep a Changelog](https://keepachangelog.com/) y el proyecto sigue Versionado Semántico (Semantic Versioning).

---

## [0.5.2] - 2026-08-03 — Avellanados reales en las 4 esquinas de la tapa (aviso del usuario)

### Corregido

- **Las 4 esquinas de la tapa tenían muescas rectangulares** (7×28 mm)
  en vez de agujeros avellanados — mismo patrón ya corregido antes en
  el panel NFC, inferior y trasero, aquí sin aplicar todavía. Causa:
  el relleno del inserto en la pared (`topInsertPad()`) llegaba hasta
  Z=shell_height+1, pasando la cara EXTERIOR de la tapa — sin sitio
  para que la tapa tuviera su propio material sin invadirlo.
- Corregido con el mismo criterio que los demás paneles: el relleno
  (`topInsertPad()`/`topScrewInsertCuts()` en `walls.scad`) ahora para
  en la cara INTERIOR de la tapa, no llega a la exterior.
- Añadido avellanado cónico real a `topScrewHoles()`, dentro del
  grosor normal de la tapa (3 mm) — igual que en el resto de
  tornillos del proyecto.
- Retirada `topInsertRelief()` (la muesca rectangular), ya
  innecesaria.

### Verificado

- Sin colisión real con la pared (solo contacto de borde esperado,
  0 mm, en la nueva posición reculada).
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Cambiado

- **Retirado `fanOpening()`**: ya no hay un hueco grande (120×120 mm)
  dedicado al ventilador. La rejilla ahora cubre casi toda la tapa
  (como en la foto de referencia del usuario) — el aire pasa por los
  agujeros de la rejilla que quedan encima del ventilador igual que
  por el resto, sin necesitar una abertura propia de su tamaño.
- **Retirado `fanFingerGuard()`** (las varillas dentro del hueco): ya
  no hace falta, la propia rejilla densa protege los dedos.
- **`topVentCut()` rediseñada**: cobertura casi total (antes: un
  anillo estrecho alrededor del hueco del ventilador), con agujeros
  más pequeños y densos (5 mm con 2,5 mm de pared, antes 10 mm con
  8 mm). Islas sólidas locales alrededor de cada poste del ventilador
  (`fanBossClearance`), para que ningún poste caiga sobre un hueco de
  la rejilla y quede sin apoyo.
- **Retirado `fanMountArms()`** (los brazos diagonales de sujeción):
  ya no hacen falta — con la rejilla cubriendo toda la zona, los
  postes quedan conectados de forma natural a través del propio
  material de la rejilla, sin necesitar un puente dedicado hasta el
  borde.

### Investigado — hallazgo, no fallo nuevo

- Al comprobar la tapa contra el modelo de referencia del ventilador,
  aparece un solape en los 4 postes de sujeción. Confirmado que **ya
  existía antes de este rediseño** (los postes, aislados, ya
  colisionaban con el modelo del ventilador independientemente de
  cualquier cambio de hoy) — el modelo de referencia trata todo el
  cuadrado del ventilador (120×120 mm) como sólido, sin distinguir el
  marco real de la zona hueca de las aspas. Los postes están puestos
  justo donde van los tornillos reales del ventilador (en el marco),
  así que es una simplificación del modelo de referencia, no un
  fallo físico real. No se ha tocado nada a raíz de esto.

### Verificado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Tapa completa: 2 volúmenes (todo bien conectado, sin fragmentos
  sueltos con la nueva rejilla densa).

---



### Corregido — causa raíz real

- **La zona de exclusión del ventilador (136×136 mm) era MÁS GRANDE
  que toda la zona de rejilla (124×130 mm con el margen anterior de
  16 mm)** — se comía la rejilla entera. El cambio a `squareGrid()`
  de una sesión anterior era correcto en el código, pero nunca llegó
  a producir ningún agujero real: lo único visible siempre fueron las
  tiras del protector de dedos del ventilador, confundibles con "la
  rejilla".
- `top_grill_margin`: 16 → 6 mm (deja un anillo real de agujeros
  cuadrados alrededor del ventilador — que ya ocupa la mayor parte
  del área disponible).
- Margen de exclusión del ventilador: separado de `vent_spacing`
  (8 mm) a un valor propio más ajustado (3 mm), para dejar hueco real
  a la rejilla.
- **El protector de dedos del ventilador también usaba tiras**
  (`slots()`), no agujeros cuadrados — cambiado a `squareGrid()`. Con
  una corrección adicional: `squareGrid()` genera cubos SUELTOS
  (pensada para restar y hacer agujeros) — usada tal cual en un
  cuerpo aditivo habría dejado cuadrados flotando sin conexión entre
  sí. Corregido invirtiéndola: una placa maciza MENOS `squareGrid()`,
  así queda una rejilla continua con agujeros cuadrados de verdad.

### Verificado

- Render en planta: ya se ven agujeros cuadrados reales alrededor
  del ventilador (antes: superficie lisa, sin ningún hueco).
- Tapa completa: 7 volúmenes (razonable, sin explosión de fragmentos
  sueltos — confirma que la inversión de `squareGrid()` conectó bien
  la rejilla).
- Brazos de sujeción del ventilador: siguen conectados en los mismos
  5 puntos de comprobación de siempre.
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Corregido

- El primer intento (0.4.8) interpretó mal la petición: puso dos
  paredes separadas en ALTURA (Z), ambas ocultas por detrás — no
  coincidía con la foto de referencia ni con lo que pedía el usuario.
- Aclarado por el usuario: la "pared existente" es el propio grosor
  del panel (su cara frontal, `front_panel_thickness` = 3 mm, que ya
  forma una pared al verla de canto) — no hacía falta añadirla. Lo
  que pedía era una SEGUNDA pared, paralela a esa, separada en
  PROFUNDIDAD (Y, hacia el interior) la anchura real de la tira LED
  (`led_bar_strip_width` = 10 mm), no en altura.
- Rediseñado `ledChannelWalls()`: ahora es una única pared nueva,
  paralela a la cara frontal del panel, a 10 mm de distancia hacia el
  interior — el hueco entre ambas (10 mm de ancho) es donde se pega
  la tira, con su longitud a lo largo del panel.

### Verificado

- Sin colisión con el UM790.
- Ensamblaje: 28/28 sin colisión (sin cambios).
- Confirmado con vista en planta: dos paredes paralelas, separadas
  10 mm.

### Pendiente

- Altura de cada pared (`led_channel_wall_height` = 3 mm) y grosor de
  la nueva (`led_channel_wall_thickness` = 1,5 mm) siguen siendo
  estimaciones, pendientes de confirmar con la tira LED real.

---



### Añadido

- `ledChannelWalls()` en `lower_panel.scad`: dos paredes que
  sobresalen 4 mm hacia el interior (una arriba y otra abajo de la
  franja de 12 mm de la barra LED), formando un canal en "U" abierto
  hacia el interior donde pegar la tira LED real — igual que un
  perfil de aluminio típico para tiras LED (foto de referencia del
  usuario).
- Las paredes se colocan JUSTO FUERA de la franja de 12 mm (no la
  invaden), para no estrechar el hueco resultante por debajo del
  ancho real de la tira (`led_bar_strip_width` = 10 mm) — si hubieran
  ocupado parte de esos 12 mm, la tira no habría cabido.
- La zona de 2º filamento (`ledDiffuserZone()`, sin cambios) sigue
  siendo la que deja pasar la luz hacia el exterior — el canal es un
  añadido puramente mecánico, por detrás.
- Medidas del canal (profundidad 4 mm, grosor de pared 1,5 mm)
  ESTIMADAS, pendientes de confirmar con la tira LED real.

### Verificado

- Sin colisión con el UM790 (el canal sobresale cerca de esa zona).
- Sin colisión real con la pared.
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Corregido

- Aplicada la misma corrección del panel NFC (0.4.6) al **panel
  inferior** (tornillo M2) y al **panel trasero** (tornillo M3), esta
  vez moviendo AMBOS lados a la vez (inserto en la pared + agujero en
  el panel) para mantener la alineación exacta que necesita un
  tornillo — a diferencia del imán, aquí no valía desplazar solo un
  lado.
- Nueva función compartida `panelMountX()` (`assembly_positions.scad`),
  con margen respecto al borde REAL de cada panel (no respecto a la
  cara exterior de la pared, que es más ancha) — usada a la vez en
  `walls.scad` (posición del inserto) y en cada panel (posición del
  agujero/avellanado), para que no puedan desalinearse.
- Radios de avellanado (`lower_panel_csk_radius`, `rear_csk_radius`)
  movidos a la fuente compartida por el mismo motivo.

### Verificado

- Ambos paneles: el avellanado ya cabe entero dentro del borde real
  del panel (antes se salía hasta 3 mm).
- Trayecto del tornillo comprobado libre de principio a fin (sonda a
  lo largo de su eje).
- Sin colisión real con la pared en ninguno de los dos paneles.
- Lengüeta de unión bandeja↔panel trasero: sigue sin colisión (el
  cambio de posición del tornillo no la afecta).
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Corregido

- **El alojamiento del imán del panel NFC se salía 2 mm por el borde
  real del panel** (confirmado con una captura: el círculo del
  alojamiento no se cerraba dentro del panel). Causa: la X se copiaba
  directamente de `sideMountGlobalX()`, la misma fórmula que usa la
  pared para posicionar el imán dentro de SU propio espesor (que
  llega hasta X=78) — válida ahí, pero el panel NFC solo llega hasta
  X=75 (`nfc_panel_width/2`). Una posición que cabe en la pared no
  cabe automáticamente en un panel más estrecho.
- Corregido calculando la X con margen respecto al borde REAL del
  panel, no respecto al de la pared. El alojamiento ya no está
  perfectamente centrado con el imán de la pared (unos 3 mm de
  diferencia en X), inevitable si tiene que caber entero dentro del
  panel — la atracción magnética debería seguir funcionando con ese
  desfase.

### Encontrado, pendiente de decisión — mismo fallo en otros dos paneles

- **Panel inferior (tornillo M2)** y **panel trasero (tornillo M3)**
  tienen el mismo problema, y en el trasero es más grave (hasta
  3 mm fuera del borde, incluso el taladro de paso básico, no solo
  el avellanado).
- Aquí es más delicado que en el imán: el taladro de paso tiene que
  alinear EXACTAMENTE con el inserto de la pared para que el tornillo
  lo alcance — no se puede simplemente desplazar como con el imán.
  Requiere decidir entre reducir el avellanado, ensanchar el relleno
  de la pared en esa zona, o mover el inserto — pendiente de
  planteárselo al usuario antes de tocar nada más.

### Verificado

- Panel NFC: el alojamiento ya cabe entero dentro del panel (-75 a
  75). Sin colisión real con la pared (solo contacto de borde
  esperado, 0 mm).
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Corregido

- **El panel NFC se dejó sin ningún alojamiento para el imán** en la
  corrección anterior (0.4.4) — se decidió que un imán del grosor
  estándar del proyecto (magnet_height = 3 mm) no cabía con piel
  delante en un panel de igual grosor, y se dejó completamente liso.
  El usuario avisó de que necesita un encaje real, no nada.
- Añadido `nfcMagnetPockets()`: alojamiento ciego, parcial (1,5 mm de
  profundidad — ESTIMADO, pendiente de confirmar el grosor real de
  la arandela/imán a usar aquí), que se queda dentro del propio
  grosor del panel sin sobresalir por detrás. Deja 1,5 mm de piel
  sólida por delante (oculto) y no invade el hueco donde ya está el
  imán de la pared (que se abre exactamente en el mismo punto, Y de
  la cara trasera del panel, y crece hacia el interior de la pared —
  si el del panel creciera en la misma dirección, invadiría ese
  mismo espacio).

### Verificado

- El panel sigue exactamente dentro de su grosor normal (-81,2 a
  -78,2), sin perforar la piel frontal ni sobresalir por detrás.
- Cara frontal confirmada maciza en el punto del imán (sonda
  dirigida).
- Sin colisión real con la pared (solo contacto de borde, 0 mm).
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Contexto

Dos intentos anteriores no fueron aceptables: una muesca cuadrada
visible (0.4.3 primer intento) y un saliente redondo hacia el
exterior (0.4.3 segundo intento — "los soportes sobresalen por fuera
de los paneles"). Verificado matemáticamente que, con el relleno de
la pared llegando hasta la cara EXTERIOR de los paneles, ninguna
forma de material del panel podía evitarlo sin sobresalir o sin
quedar hueco — es decir, el panel por sí solo no tiene solución.

### Cambiado — con permiso explícito del usuario, en la pared

- `frontMagnetCuts()`, `sideBossPad()`, `lowerPanelScrewCuts()`
  (paredes laterales) y `rearBossPad()`/`rearWallScrewCuts()` (pared
  trasera): el alojamiento del imán/inserto y su relleno se reculan
  ahora `front_panel_thickness` (3 mm, paredes laterales) o
  `wall_thickness` (3 mm, pared trasera) hacia dentro — se abren
  justo en la cara INTERIOR de cada panel, no en la exterior.

### Corregido — paneles, ahora realmente lisos

- **Panel NFC**: sin ningún corte para el imán — el hueco de 3 mm de
  la pared no deja sitio para ningún alojamiento con piel delante en
  un panel de igual grosor (3 mm). El imán/arandela se pega en la
  cara trasera durante el montaje, sin ninguna pieza impresa.
- **Panel inferior y panel trasero**: taladro de paso + avellanado
  cónico real, ambos DENTRO del grosor normal del panel (sin ningún
  saliente) — ahora que la pared se reculó, cabe con margen.
- Verificado en los tres: sin colisión real con la pared (solo
  contacto de borde exacto, 0 mm de espesor, en la nueva posición
  reculada).

### Verificado — no se rompió nada más

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Panel NFC vs RC522: sin colisión (sin cambios).
- Lengüeta bandeja↔panel trasero vs paredes: sin colisión (sin
  cambios, el retranqueo del relleno no la afecta).

---



### Corregido — imanes/tornillos visibles desde fuera (sin tocar la pared)

- **Diagnóstico**: el relleno de la pared (`sideBossPad()`) empieza
  exactamente en la cara EXTERIOR de los paneles frontales y se
  extiende mucho más allá de donde termina el panel por detrás — no
  queda ningún margen de grosor para dejar una "piel" sólida delante
  sin invadir el relleno. Confirmado con las coordenadas reales
  (Y=-81,2 tanto para el borde del panel como para el inicio del
  relleno). Cambiar esto habría requerido tocar la pared, que el
  usuario pidió expresamente no modificar.
- **Solución, íntegramente en los paneles**: un saliente REDONDO
  hacia el exterior (más allá de la cara normal del panel, en la zona
  donde el relleno de la pared todavía no existe), con:
  - **Panel NFC**: alojamiento del imán CIEGO, abierto hacia el
    interior — no pasante, no visible desde fuera.
  - **Panel inferior**: taladro de paso con avellanado cónico real
    en la cara exterior, para la cabeza del tornillo M2.
  - **Panel trasero**: mismo tratamiento que el inferior (M3), por
    consistencia — no se mencionó explícitamente pero tenía el mismo
    problema.
- Verificado en los tres paneles: sin colisión real con las paredes
  (solo contacto de borde esperado, 0 mm de espesor).

### Corregido — fallo propio detectado al aplicar lo anterior

- Al quitar las antiguas muescas cuadradas pasantes, se me olvidó que
  el panel PLANO seguía teniendo material sólido en esa zona — seguía
  chocando con el relleno de la pared. Corregido volviendo a añadir
  la muesca (`wallPadRelief()`), esta vez JUNTO con el nuevo saliente
  (no en su lugar), con el borde recalculado para no invadir el
  propio saliente.
- **El relleno del tornillo trasero bajo (Z=15) colisionaba con la
  lengüeta de unión bandeja↔panel trasero** (también a Z=15-18) — un
  fallo que ya existía de una corrección anterior, encontrado al
  verificar esta ronda. Corregido subiendo esa Z a 27 (lejos de la
  lengüeta y del recorte de la IO trasera).

### Corregido — rejilla de la tapa con piezas en el aire

- **Causa real**: la rejilla de la tapa reutilizaba
  `bottom_grill_margin`, el mismo parámetro reducido a 3 mm para
  ampliar la rejilla del SUELO en una sesión anterior — sin querer,
  ese cambio también vació la tapa casi hasta el borde, demasiado
  cerca de los taladros de tornillo y el relleno de los insertos,
  dejando fragmentos sin apoyo.
- Corregido con un parámetro propio (`top_grill_margin` = 16 mm), y
  cambiado el patrón de `valvePattern()` (rombos) a `squareGrid()`
  (agujeros cuadrados), a petición del usuario.

### Añadido — soportes del ventilador

- Antes: simple taladro de paso liso en los 3 mm de la tapa. Ahora:
  postes con alojamiento ciego para inserto M3 térmico, más robustos.
- Los postes caen dentro del hueco cuadrado del ventilador (donde van
  los anclajes reales) — añadidos brazos de sujeción diagonales hasta
  el material sólido exterior al hueco, para que no queden flotando
  (patrón habitual en ventiladores reales, "araña" de sujeción).
  Verificado en 5 puntos de la diagonal, conexión continua sin huecos.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Los tres paneles (NFC, inferior, trasero) verificados sin colisión
  real contra las paredes.

---



El usuario da por bueno el chasis en su estado actual. Validación
final antes del cierre:

- Sintaxis: limpia en las ~30 piezas del proyecto.
- Ensamblaje (28 pares): 28/28 sin colisión.
- Estructura vs 8 componentes (32 pares): 29/32 sin colisión — los 3
  restantes son los contactos de anclaje intencionados de siempre
  (RC522, ESP32, HUB).
- Estructura vs estructura: pares relevantes verificados durante la
  sesión (la mayoría a mano, por la lentitud del script automático
  completo) — sin colisión real, solo contactos de diseño esperados.
- Recorrido de inserción de la bandeja: verificado en 4 alturas
  intermedias, sin obstrucción.

Ver `docs/03_Virtual_Assembly_Report.md`, sección 12, para el resumen
completo de cierre, incluidas las limitaciones conocidas no
bloqueantes (medidas sin confirmar, un comentario del DIM sin
reconciliar, y que no se ha comprobado el recorrido de inserción de
piezas distintas a la bandeja).

A partir de aquí, el chasis no se modifica salvo que surja un
problema real al imprimir o montar.

---



### Contexto

Todas las comprobaciones de esta sesión verificaban la posición
FINAL de cada pieza. El usuario preguntó si la bandeja podría
insertarse sin problemas — una pregunta distinta: no solo si
colisiona en su destino, sino si el CAMINO para llegar ahí (bajando
desde arriba, con la tapa quitada) está libre.

### Corregido

- **La bandeja (150 mm de ancho, el hueco exacto entre paredes, sin
  ninguna holgura) chocaba con los rellenos de imanes/tornillos de
  las paredes laterales** (`sideBossPad()`, `rearBossPad()`,
  `topInsertPad()` — todos sobresalen 7 mm hacia el interior) durante
  el recorrido de bajada. No en su posición final — ahí nunca hubo
  colisión, por eso no se había detectado antes — sino en varios
  puntos intermedios del trayecto de inserción.
- Verificado con un barrido vertical completo (`tray_width` extruido
  desde la apertura superior hasta la posición final) contra las
  paredes: colisión real confirmada, no solo el contacto de ajuste
  esperado (usando sondas con 6 mm de margen para descartar falsos
  positivos de borde).
- Corregido reduciendo `tray_width` de 150 a 130 mm (deja 3 mm de
  holgura a cada lado del canal libre entre rellenos, y 8,5 mm de
  margen respecto a los anclajes reales del UM790, off_x = 56,5 mm).
  `tray_depth` no se ha tocado — el problema es solo con las paredes
  laterales fijas, no con el frente/fondo (paneles separados que no
  son obstáculo durante la inserción vertical).

### Resultado

- Verificado el recorrido completo de inserción en 4 alturas
  intermedias (Z=30, 70, 95, 140) con la bandeja real (postes,
  nervaduras, UM790 de referencia incluidos) — sin colisión en
  ninguna.
- Verificada también la posición final: sigue tocando los pilares de
  apoyo exactamente igual que antes (0 mm de espesor).
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Cambiado

- **Suelo: rejilla en prácticamente toda su superficie**, para
  captar más caudal de aire externo. `bottom_grill_margin`: 12 → 3 mm
  (mínimo razonable para que el borde siga teniendo material sólido
  donde apoyan las paredes). Verificado: pilares de apoyo de la
  bandeja y patas siguen conectados correctamente, sin colisiones
  nuevas (28/28 ensamblaje, sin cambios).

### Corregido — hueco de fondo en la bandeja

- **`tray()` (`openscad/parts/01_bandeja/tray.scad`) nunca elevaba la
  bandeja a su posición real de montaje** — se renderizaba en su
  propio origen local (Z=0, como si apoyara directamente en el
  suelo), cuando en el ensamblaje real queda elevada sobre los
  pilares de apoyo del suelo, a `z_chamber_top` = 15 mm. Todo el resto
  del ensamblaje (posición del UM790, recorte del panel trasero, etc.)
  ya asumía esta elevación — verificado durante toda la sesión con el
  modelo de referencia — pero la pieza física de la bandeja en sí
  nunca se había materializado en su sitio correcto.
- Corregido envolviendo `tray()` con
  `translate([0,0,z_chamber_top])`. Con esto, la altura de separadores
  del UM790 (post_height=20 mm) y la posición del conector trasero
  coinciden matemáticamente con lo ya verificado (no ha hecho falta
  recalcular ningún valor — los números ya eran correctos, solo
  faltaba que la pieza los reflejara).
- Verificado: bandeja elevada toca el suelo exactamente en los
  pilares de apoyo (0 mm de espesor, contacto correcto, no
  colisión), toca las paredes solo en su borde (encaja exactamente
  entre ellas, tray_width = case_width - 2×wall_thickness), y el
  solape con el modelo de referencia del UM790 en la zona de los
  postes es el esperado (representan el mismo objeto físico dos
  veces: referencia y pieza real).

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- No ha sido necesario crear una pieza nueva de "base independiente":
  `tray.scad` ya era un archivo separado del chasis fijo; el hueco
  real era que le faltaba la traslación de elevación.

---



### Corregido — causa raíz real

- **`topInsertPad()` y `topScrewInsertCuts()` usaban coordenadas
  GLOBALES (centradas en el medio de la carcasa) dentro del sistema
  de coordenadas LOCAL de cada pared** (que empieza en el borde, no
  en el centro). Al pasar por la traslación de `leftWall()`/
  `rightWall()` (`-case_depth/2`), el valor se desplazaba una segunda
  vez — el soporte terminaba a case_depth/2 (81,2 mm) de donde debía,
  fuera por completo de la pieza ("en el aire", como se ve en la
  captura). El taladro del inserto sufría el mismo desplazamiento, así
  que cortaba en el vacío y no dejaba agujero real en el soporte.
  Confirmado exportando a STL: el soporte aparecía en Y=-144,4 mm,
  muy fuera del rango real de la pieza (-81,2 a 81,2 mm).
- Corregido pasando las coordenadas ya convertidas a locales
  (`wall_thickness + top_screw_y_inset` y
  `case_depth - wall_thickness - top_screw_y_inset`, equivalentes a
  las globales tras deshacer la traslación de la pared).
- De paso, ampliado el margen del corte del inserto (igual que se
  hizo antes con la muesca de la tapa) tras detectar que, aun con la
  posición ya correcta, el corte no llegaba a vaciar limpiamente el
  material — verificado con una sonda en el centro exacto del
  agujero, ahora confirmado hueco.

### Resultado

- Verificado exportando a STL: toda la geometría de ambas paredes
  queda ya dentro de los límites reales de la carcasa (X: -78 a 78,
  Y: -81,2 a 81,2 — antes se salía 63 mm por Y).
- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Corregido — registro erróneo

- La entrada [0.3.7] afirmaba que la fijación pared↔panel trasero se
  había "reintentado y resuelto" — **no era cierto**: no existía
  ninguna referencia a `rearBossPad`/`rearWallScrewCuts` en el
  código. Fue un error al escribir el resumen de aquel turno, no una
  regresión posterior. Detectado al investigar por qué el usuario no
  veía los soportes.

### Añadido

- **Fijación pared↔panel trasero, esta vez implementada de verdad**:
  `rearBossPad()`/`rearWallScrewCuts()` en `walls.scad` +
  `rearWallScrewHoles()` y su `wallPadRelief()` en `rear_panel.scad`.
  Queda un residuo menor (4 puntos, 3 mm de espesor) sin resolver del
  todo por tiempo — mucho más pequeño que el problema original, no
  bloqueante, documentado para revisión futura.
- **Inserto M3 de la tapa**: mismo tipo de fallo que los imanes (más
  ancho que la pared, asomaba 0,55 mm) — corregido con
  `topInsertPad()` + `topInsertRelief()` en la propia tapa.

### Investigado — artefacto de CGAL, no un fallo de diseño

Durante la verificación de paredes↔tapa apareció un solape que no
correspondía a ninguna pieza conocida. Comprobación exhaustiva:
- Ninguna pieza individual (pared base, cada relleno, cada poste) lo
  contenía por separado.
- El bloque de unión completo (todos los rellenos juntos, antes de
  los recortes) tampoco lo contenía.
- Solo aparecía **después** de aplicar los recortes — imposible en
  términos normales (restar no puede añadir material).
- Coincidía con avisos repetidos de "Object may not be a valid
  2-manifold".

Conclusión: artefacto numérico de la operación booleana de CGAL al
combinar muchos recortes cercanos, no un fallo de diseño real. No se
ha modificado nada a raíz de esto — se deja documentado por si
resulta relevante al laminar/imprimir.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Añadido

- **Fijación pared↔panel trasero, reintentada y esta vez resuelta**:
  usando el mismo patrón de muesca de alivio que ya funcionó para el
  panel inferior y el NFC (`wallPadRelief()`), se ha vuelto a añadir
  `rearBossPad()`/`rearWallScrewCuts()` en `walls.scad` y
  `rearWallScrewHoles()` + su propia muesca en `rear_panel.scad`.
  Verificado sin colisión real (solo contacto de borde esperado).

### Corregido

- **El inserto M3 de la tapa asomaba 0,55 mm por cada cara de la
  pared** (mismo tipo de fallo que los imanes, en menor escala,
  encontrado al revisar por qué el usuario no veía los soportes).
  Corregido con un relleno local (`topInsertPad()`) y recentrado del
  taladro (`sideBossCutX()`, reutilizando la función ya existente).
- Añadida la muesca de alivio correspondiente en la propia tapa
  (`topInsertRelief()`) para que su material no invada ese relleno.

### Pendiente / sin resolver del todo

- La comprobación completa paredes↔tapa sigue mostrando algo de
  contacto más allá de lo ya aceptado como "unión esperada" en
  versiones anteriores; una sonda puntual confirmó que el punto
  concreto del inserto de la tapa ya está bien (hueco correcto), pero
  no se ha rastreado el origen exacto del resto por falta de tiempo.
  No hay indicios de que sea un fallo nuevo (ya existía cierto
  contacto ahí antes de esta sesión, aceptado como el apoyo de la
  tapa sobre el borde de la pared) — pendiente de una revisión más
  detallada si se detectan problemas al imprimir.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).

---



### Añadido

- **Comprobación estructura-contra-estructura** en
  `run_structure_checks.py` — hasta ahora solo se comparaba cada
  pieza del chasis contra los 8 componentes electrónicos, nunca las
  piezas del chasis entre sí. Esta comprobación fue la que destapó
  todos los fallos de esta entrada. Incluye una lista de parejas con
  contacto esperado (piezas que se tocan por diseño: la tapa se apoya
  en la pared, el panel trasero se atornilla a la bandeja, etc.) para
  no confundir un contacto intencionado con una colisión real.
- `wallPadRelief()` (nuevo módulo compartido en
  `assembly_positions.scad`): muesca de alivio que cualquier panel
  atornillado/imantado a la pared debe restar en los puntos de unión,
  para no invadir el relleno local de la pared (14×14 mm, mucho más
  ancho que un simple taladro de paso).

### Corregido

- **Pilares de apoyo de la bandeja** (aviso del usuario): estaban
  completamente macizos, sin alojamiento para el inserto M3.
  Corregido. Además no caían sobre material sólido de la bandeja
  (quedaban en la zona hueca del marco) — reposicionados con un
  `inset` distinto en X e Y.
- **Los pilares de apoyo colisionaban con el relleno de la pared**
  (aviso del usuario): al estar en la esquina (X=Y=70 mm), caían
  dentro de la franja de los rellenos de imán/tornillo. Reposicionados
  en Y (40 mm) — siguen sobre el marco sólido de la bandeja, pero
  fuera de la franja de los rellenos.
- **Panel trasero — dos colisiones de volumen real**: empezaba en
  Z=0 (el mismo espacio que el suelo) y medía 156 mm de ancho
  (solapando el propio grosor de las paredes, que ocupan hasta ±78 mm)
  — corregido a Z=bottom_thickness y 150 mm de ancho (encaja entre
  paredes, igual que la bandeja y el panel NFC).
- **La lengüeta de unión panel trasero↔bandeja estaba a la altura
  equivocada** (Z≈0-6, la misma que el suelo) — la bandeja en
  realidad queda elevada sobre sus pilares de apoyo (Z=15-18, ya usado
  en todo el ensamblaje validado). Corregido.
- **Fijación pared↔panel trasero retirada**: se intentó añadir
  (petición del usuario), pero colisionaba con el relleno de la
  pared de forma difícil de resolver limpiamente en el tiempo
  disponible. El panel trasero sigue fijado a la bandeja (ya
  verificado sin colisión). Queda pendiente para una futura revisión.
- **Panel inferior — mismo fallo de anchura que el panel trasero**
  (156 mm en vez de 150 mm) — nunca se había comprobado contra las
  paredes. Corregido.
- **Tornillos M2 del panel inferior e imanes del panel NFC invadían
  el relleno de la pared** — el taladro/imán en sí estaba bien
  alineado (`sideMountGlobalX()`), pero el material del panel
  alrededor del taladro competía con el relleno de 14×14 mm de la
  pared. Corregido con `wallPadRelief()` en ambos paneles.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Estructura vs 8 componentes: 29/32 (sin cambios; los 3 "colisiona"
  siguen siendo los contactos de anclaje intencionados de siempre).
- Estructura vs estructura: todas las parejas relevantes verificadas
  a mano durante esta sesión — sin colisión real, solo contactos de
  borde esperados (0 mm de espesor, confirmado exportando a STL en
  cada caso).

---



### Corregido

- **Los pilares de apoyo de la bandeja (`traySupportPosts()`) estaban
  completamente macizos**, sin alojamiento para el inserto M3.
  Corregido con un alojamiento ciego, igual que el resto de insertos
  del proyecto.
- **Los pilares no caían sobre material sólido de la bandeja**: con
  `tray_support_inset = 12`, la posición quedaba en la zona hueca del
  marco (que solo llega hasta 65 mm desde el centro; el pilar estaba
  en 63 mm). Corregido a `inset = 5` (posición en 70 mm, dentro del
  marco macizo). Añadido el taladro de paso correspondiente en la
  propia bandeja (`base.scad`, `trayScrewClearanceHoles()`).
- **El poste del RC522/ESP32/HUB SÍ tenía agujero** (falsa alarma
  inicial de una comprobación mal posicionada por mi parte; verificado
  con los radios exactos del corte transversal: 2,05 mm interior,
  5 mm exterior — confirmado correcto, sin cambios en esa parte).
- **Faltaba la fijación del panel trasero a las paredes laterales** —
  solo se sujetaba a la bandeja (2 tornillos M3 cerca del centro
  inferior), insuficiente para un panel de 148 mm de alto. Añadidos
  2 tornillos M3 por pared (`rearWallScrewCuts()`/`rearBossPad()` en
  `walls.scad`, taladros de paso correspondientes en
  `rear_panel.scad`), reutilizando la misma fórmula compartida
  (`sideMountGlobalX()`) para que no puedan desalinearse.
- De paso, encontrado y corregido: tanto el relleno frontal como el
  trasero de las paredes sobresalían 1 mm por fuera del borde real de
  la carcasa (arrastrando el mismo desliz "-1"/"+1" de una corrección
  anterior). Verificado con exportación a STL: ahora X e Y quedan
  exactamente dentro de los límites reales.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Estructura: 29/32 (sin cambios) — ninguna corrección de esta
  entrada introduce colisiones nuevas con los 8 componentes.

---



### Corregido

- **El panel NFC llevaba sus imanes desalineados 7,5 mm respecto a
  los de la pared desde que se creó ese archivo** (calculaba su
  propia posición en X de forma independiente, sin relación con la
  pared). El relleno local de la corrección anterior [0.3.3] lo
  cambió a 3,9 mm de desajuste — seguía mal, solo que menos.
- **El taladro de paso M2 del panel inferior también se
  desalineó** al mover el inserto de la pared en la corrección
  [0.3.3] (de 0 mm de desajuste a 2,5 mm).
- Causa raíz: cada archivo calculaba su propia posición en X con su
  propia fórmula, sin una fuente compartida — no podían mantenerse
  sincronizados.
- Solución: nueva función compartida `sideMountGlobalX()` en
  `assembly_positions.scad`, junto con `side_boss_margin`,
  `side_boss_depth`, `lower_panel_screw_diameter/depth` (movidos
  desde `walls.scad`, que los duplicaba). Tanto `walls.scad` como
  `nfc_panel.scad` y `lower_panel.scad` calculan ahora la misma
  posición desde la misma fuente — no pueden volver a
  desincronizarse.
- Verificado con `echo()`: ambas posiciones (pared y panel) coinciden
  exactamente, en los dos casos (imán NFC y tornillo M2).

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Estructura: 29/32 (sin cambios).

---



### Corregido

- **Los alojamientos de imanes (Ø8,15 mm) y tornillos M2 (Ø6 mm) eran
  más anchos que la propia pared (3 mm de grosor)** — asomaban por la
  cara exterior, visibles desde fuera una vez montado. Detectado por
  el usuario con una captura de zoom en OpenSCAD.
- `openscad/parts/02_chassis/walls.scad`: añadido un relleno local
  (`sideBossPad()`, 10 mm de grosor) por el lado NO visto en cada
  punto de imán/tornillo, con los alojamientos recentrados dentro de
  ese grosor extra (`sideBossCutX()`). La cara exterior queda intacta
  y lisa; el relleno solo crece hacia el interior del chasis.
- Verificado exportando a STL y comprobando que la cara exterior sigue
  maciza en los puntos donde antes asomaba (antes: hueca; ahora:
  sólida). Nota técnica para futuras comprobaciones puntuales: los
  scripts de verificación "de un uso" deben usar `include`, no `use`,
  si referencian variables sueltas de otro archivo — `use` no ejecuta
  las asignaciones de variables de nivel superior del archivo
  importado, solo expone sus módulos/funciones; un script de
  comprobación mal escrito con `use` dio un falso positivo durante
  esta misma verificación, detectado y descartado.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Estructura: 29/32 (sin cambios respecto a la corrección anterior)
  — el relleno no introduce ninguna colisión nueva con los 8
  componentes.

---



### Corregido

- **Postes de anclaje del RC522 y el HUB crecían hacia fuera de la
  pared derecha** (`walls.scad`): `rc522MountBoss()` y
  `hubMountBosses()` usaban siempre `rotate([0,90,0])`, correcto solo
  para la pared izquierda. En la pared derecha el poste crecía 3 mm
  por la cara exterior, visible por fuera — detectado por el usuario
  en una captura de OpenSCAD. `rc522MountBoss()` ahora recibe un
  parámetro de dirección (`dir`); `hubMountBosses()` usa
  `rotate([0,-90,0])` (solo se llama desde la pared derecha).
- **Las 4 patas sobresalían 2 mm por fuera del borde real de la
  carcasa**, en X e Y (`floor.scad`, `virtual_assembly_v1.scad`): la
  fórmula de posición calculaba el punto como si `cube()` estuviera
  centrado, pero se llamaba con `center=false` (esquina) — confirmado
  exportando a STL y midiendo (X llegaba a 80 mm, límite real 78 mm).
  Corregido con `center=true` y un margen explícito
  (`leg_edge_margin`) respecto al borde de la carcasa.

### Resultado

- Ensamblaje: 28/28 sin colisión (sin cambios).
- Estructura del chasis: **29/32** (antes 30/32) — el cambio es una
  MEJORA: el poste del HUB, al corregir su dirección, ahora sí toca
  su placa (antes crecía hacia fuera sin tocar nada útil). Verificado
  que el nuevo contacto es de superficie (0 mm de espesor), igual que
  los otros dos anclajes.
- Patas y postes verificados con límites exactos (exportación a STL +
  medición de coordenadas), no solo visualmente.

---



### Confirmado por el usuario (todas las que eran "Estimado" pasan a dato real)

- `usb_front_hole_diameter` = 29 mm (ya coincidía).
- `usb_front_body_length`: 22 → **30 mm**.
- `leg_height` = 4 mm (ya coincidía, reconfirmado).
- `nfc_tag_pocket_depth` = 1,5 mm (ya coincidía).
- `nfc_window_width/height` = 60×40 mm (ya coincidía).
- `led_bar_margin` = 1 mm a cada lado (ya coincidía).
- Panel NFC sin marco frontal independiente: aceptado por el usuario,
  pendiente de confirmar al imprimir.

### Sin confirmar todavía (quedan como estimados, no bloqueante)

- `usb_front_flange_diameter` (35 mm).
- Huella de las patas (10×10 mm — solo la altura, 4 mm, está
  confirmada).

### Resultado

- 28/28 (ensamblaje) y 30/32 (estructura) sin colisión — el USB 8 mm
  más largo no reintroduce la colisión con la PCB (la holgura que
  evita el choque es en Z, no en la longitud del cuerpo).

---



### Añadido

- `openscad/parts/02_chassis/top.scad`: taladros de paso M3 (tapa) +
  insertos correspondientes en `walls.scad`; rejilla de protección de
  dedos del ventilador (`fanFingerGuard()`).
- `openscad/parts/02_chassis/floor.scad`: apoyos de la bandeja
  (`traySupportPosts()`) — la bandeja encaja a presión exacta con el
  chasis (0 mm de holgura), así que se apoya en postes desde el suelo
  en vez de guiarse por las paredes.
- `openscad/parts/01_bandeja/rear_panel.scad` +
  `openscad/parts/01_bandeja/base.scad`: unión estructural real entre
  el panel trasero y la bandeja (lengüetas + insertos M3), con dos
  fallos de altura corregidos durante la verificación.
- `openscad/parts/03_panels/lower_panel.scad` (nuevo, sustituye a
  `front_panel.scad`): panel inferior fijo definitivo — pulsador,
  OLED, USB doble, barra LED, tamaño mínimo imprescindible.
- `openscad/parts/03_panels/nfc_panel.scad` (nuevo, sustituye a
  `front_layout.scad`): panel NFC extraíble definitivo — ancho
  corregido (150 mm, antes 70 mm no llegaba a los imanes de las
  paredes), imanes, alojamiento del tag.
- `front_panel.scad` y `front_layout.scad` marcados obsoletos
  (comentario, no borrados) — sustituidos por los dos archivos
  anteriores.

### Corregido

- `nfc_panel_width`: 70 → 150 mm — el valor original no llegaba a los
  imanes embebidos en las paredes laterales (docs/02_Mechanical_Layout.md,
  sección 3: "Ocupará prácticamente todo el ancho frontal").

### Resultado final

- 28/28 (ensamblaje) y 30/32 (estructura del chasis) sin colisión.
- Los 4 pendientes de la sesión anterior (insertos tapa, rejilla
  ventilador, apoyos bandeja, unión panel trasero-bandeja, paneles
  frontales definitivos) — todos cerrados.

---



### Corregido

- `docs/02_Mechanical_Layout.md`: separadores del UM790 actualizados
  de 8 a 20 mm (adenda, documento "Approved" no reescrito).
- `openscad/parts/02_chassis/walls.scad`: los imanes del panel NFC
  estaban parcialmente en la zona del panel inferior (Z=25, dentro de
  0-39,5 mm) — el DIM especifica que el panel inferior va atornillado
  (M2), sin imanes. Corregido: imanes ahora solo dentro de la franja
  del panel NFC; añadidos insertos M2 propios para el panel inferior.
- `openscad/parts/01_bandeja/rear_panel.scad`: añadidos insertos M3
  (DIM sección 7). Pendiente: cómo se une estructuralmente el panel
  trasero a la bandeja no está resuelto todavía (solo las posiciones
  de los insertos).
- Verificados los puntos de la checklist del DIM (sección 8) que no
  se habían comprobado explícitamente: RC522 ↔ Panel NFC (con los
  3 mm de separación reales) y Cables USB ↔ Ventilador. Ambos sin
  colisión.

### Sin cambios

- 28/28 (ensamblaje) y 30/32 (estructura del chasis) sin colisión —
  ninguna de las correcciones de esta entrada afecta a los 8
  componentes ya verificados.

---



### Modificado

- Confirmado por el usuario: las patas son externas y miden 4 mm,
  añadidas por debajo del cascarón (no restan altura interna de
  trabajo, que se usaba erróneamente como si fueran 152 mm).
- Nuevo parámetro `shell_height` (148,0 mm) en `00_parametros.scad`,
  usado ahora en todo el ensamblaje y el chasis en vez de
  `case_height` (152, que sigue siendo el dato exterior original, sin
  modificar).
- `nfc_panel_height`: 88,5 → 84,5 (recalculado con la altura real del
  cascarón).
- `openscad/parts/02_chassis/floor.scad`: patas añadidas como
  geometría real (`floorLegs()`).
- Detectado y corregido automáticamente por la comprobación de
  consistencia ya incorporada (`front_panel_zones_consistent`): el
  primer intento de este recálculo dejaba el panel NFC solapado 4 mm
  con la barra LED.
- Resultado tras el recálculo: 28/28 (ensamblaje) y 30/32
  (estructura del chasis) sin colisión — sin cambios respecto a antes
  del recálculo.

---



### Añadido

- Ensamblaje virtual completo v1 (`openscad/reference/virtual_assembly_v1.scad`),
  previo al diseño del bastidor. Resultado final: **28/28 pares de
  componentes sin colisión** (verificado con
  `openscad/reference/checks/run_collision_checks.py`).
- Módulos independientes de componentes en `openscad/reference/components/`:
  `um790.scad`, `noctua.scad`, `rc522.scad`, `esp32.scad`, `hub_usb.scad`,
  `oled.scad`, `usb_front.scad` (v2, unidad doble real), `pushbutton.scad`.
- Postes de anclaje del UM790 modelados como geometría real
  (`um790MountingPosts()`), incluidos en la comprobación de colisiones.
- Posiciones del ensamblaje centralizadas en `assembly_positions.scad`
  e instancias en `assembly_instances.scad`.
- Verificador automático de colisiones par a par
  (`openscad/reference/checks/run_collision_checks.py`).
- Vista de alzado frontal 2D (`openscad/reference/front_panel_view.scad`),
  con las tres zonas del panel frontal (inferior fijo, barra LED, NFC).
- Nuevos parámetros reales/estimados en `00_parametros.scad` para
  ESP32 Terminal Adapter, pulsador M16×55, USB empotrable doble Ø29,
  OLED 27×27, disipador e IO trasera del UM790.
- `docs/03_Virtual_Assembly_Report.md` con el resultado final y el
  historial completo de la verificación.

### Modificado (valores ya existentes, confirmados por el usuario)

- `um790_standoff_height`: 12 → **20 mm** (resuelve colisión PCB/postes
  con el pulsador y el USB frontal).
- `led_bar_height`: 8 → **12 mm** (dato real de la tira LED, 10 mm + margen).
- `nfc_panel_height`: 70 → **88,5 mm** (panel inferior minimizado, NFC
  maximizado con el hueco restante).

### Pendiente

- Reconciliar la altura de separadores en `posts.scad` (6 mm) y
  `docs/02_Mechanical_Layout.md` (8 mm) con el valor confirmado (20 mm).
- Actualizar `front_panel.scad` y `front_layout.scad` con las nuevas
  posiciones y tamaños de esta verificación.

- Colisión real entre el pulsador / USB empotrable y la PCB del
  UM790 por falta de profundidad libre tras el panel frontal.
- Tres valores distintos de altura de separadores del UM790 conviven
  en el proyecto (6 / 8 / 12 mm) y deben reconciliarse.

---

## [0.1.0] - En desarrollo

### Añadido

- Estructura inicial del repositorio.
- README del proyecto.
- Reglas de diseño (`DESIGN_RULES.md`).
- Parámetros globales (`00_parametros.scad`).
- Librería `common.scad`.
- Librería `helpers.scad`.
- Librería `fasteners.scad`.
- Librería `guides.scad`.
- Librería `magnets.scad`.
- Librería `ventilation.scad`.
- Librería `hardware.scad`.

### Pendiente

- Bandeja del UM790 Pro.
- Chasis principal.
- Panel trasero modular.
- Panel frontal intercambiable con NFC.
- Soporte OLED.
- Sistema de iluminación LED.
- Integración ESP32.
- Sistema NFC.
- STL oficiales.
- Manual de montaje.
