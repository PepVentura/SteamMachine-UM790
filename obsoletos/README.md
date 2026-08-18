# Archivos obsoletos

Esta carpeta reúne archivos que ya no forman parte activa del
proyecto — no los usa ningún `use`/`include` real desde ningún
archivo activo (verificado antes de moverlos). Se conservan como
referencia histórica del proceso de diseño, no para imprimir ni
para usarse como base de nada nuevo.

Movidos aquí el 2026-08-14, a petición del usuario, tras una
revisión completa del repositorio. Estructura original preservada
en subcarpetas.

## parts_03_panels/

- **front_panel.scad** — ya marcado ⚠️ OBSOLETO en el propio
  archivo desde el 2026-08-03. Combinaba en una sola pieza lo que
  el ensamblaje virtual v1 determinó que debían ser dos piezas
  separadas. Sustituido por `openscad/parts/03_panels/lower_panel.scad`
  y `nfc_panel.scad`.
- **front_layout.scad** — ya marcado ⚠️ OBSOLETO. Plano de
  distribución del frontal con medidas desactualizadas (USB de
  boceto, panel NFC de 70mm). Sustituido por `lower_panel.scad` y
  `nfc_panel.scad` (piezas reales).
- **rc522_bracket_v1.scad** (renombrado desde `rc522_bracket.scad`
  para no chocar con el nombre actual) — versión 1.0 del soporte
  del lector RC522, con el taladro de tornillo mal orientado (no
  coincidía con el eje real del poste de anclaje). Sustituida por
  completo por la v2.0 en `openscad/parts/04_soportes/rc522_bracket.scad`,
  que es la que se usa realmente.

## reference/

- **virtual_assembly_v1.scad** — ensamblaje virtual de la fase
  previa al diseño del chasis (explícitamente no imprimible).
  Cumplió su función antes de que existieran las piezas reales.
- **front_panel_view.scad** — alzado 2D de ayuda, solo lo usaba
  `front_layout.scad` (ya obsoleto).
- **chassis_layout.scad** — visor de ensamblaje completo de una
  fase anterior del proyecto, sin referencias entrantes.
- **um790_reference.scad** — modelo de referencia del UM790
  duplicado; el que se usa realmente en todo el proyecto es
  `openscad/reference/components/um790.scad`.

## No incluido aquí, pero desactualizado

`openscad/parts/02_chassis/checks/run_structure_checks.py` sigue en
su sitio original — no es un duplicado, pero no se ha ejecutado ni
actualizado durante los muchos cambios recientes a `rear_panel.scad`,
`walls.scad`, etc. Si se usa, tenerlo en cuenta.
