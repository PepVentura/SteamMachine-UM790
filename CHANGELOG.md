# Changelog

Todos los cambios importantes de este proyecto se documentarán en este archivo.

El formato está inspirado en [Keep a Changelog](https://keepachangelog.com/) y el proyecto sigue Versionado Semántico (Semantic Versioning).

---

## [0.2.0] - 2026-08-03 — Ensamblaje virtual v1 (definitivo)

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
