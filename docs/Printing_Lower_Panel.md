# SteamMachine UM790
## Guía de impresión — Panel inferior (lower_panel.stl)
Version: 1.0
Status: Aprobado, verificado con impresión real
Date: 2026-08-17

Pieza: `openscad/parts/03_panels/lower_panel.scad` → `lower_panel.stl`

---

## 1. Resumen

El panel inferior se imprime en **dos filamentos**: el cuerpo
completo en el color base, y una franja estrecha (el difusor de la
tira LED) en un segundo filamento translúcido. El cambio de
filamento se hace por **rango de altura** (Z), no pintando a mano —
es una franja recta de lado a lado del panel, ideal para ese
método.

Laminador de referencia: Anycubic Slicer Next (basado en
OrcaSlicer). Los nombres de herramienta deberían ser equivalentes en
cualquier laminador con soporte de modificadores por rango de altura
y multi-material/AMS.

---

## 2. Filamentos

| Filamento | Uso | Notas |
|---|---|---|
| Filamento 1 | Cuerpo completo del panel | Color base a elección |
| Filamento 2 | Franja del difusor LED | Translúcido, para dejar pasar la luz de la tira LED |

---

## 3. Orientación de la pieza

Orientar la pieza **de pie**, con su eje Z hacia arriba, apoyada
sobre su borde más largo (el mismo criterio que el resto de paneles
frontales del proyecto). No imprimir plana.

---

## 4. Rango de altura del difusor

**Z: 40,5 mm a 46,5 mm**

Este rango está verificado por cálculo directo sobre los parámetros
actuales del proyecto (`front_panel_led_z_low`,
`front_panel_led_z_high`, `front_bezel_border`, `led_diffuser_width`
— ver `lower_panel.scad`, módulo `ledDiffuserZone()`). No ha
cambiado a pesar de varios ajustes de ancho y tornillería del panel
en rondas anteriores — el ancho del panel (149 mm) y el grosor
(3 mm) no afectan a la posición Z de esta franja.

Pasos en Anycubic Slicer Next:

1. Cargar `lower_panel.stl` y orientarlo como se indica en la
   sección 3.
2. Confirmar que ambos filamentos están cargados (ver sección 2).
3. En la **lista de objetos** (panel lateral, no la barra de
   iconos de arriba), hacer **clic derecho** sobre el nombre
   `lower_panel.stl`.
4. En el menú contextual, elegir **"Modificador de rango de
   altura"**.
   > ⚠️ El icono de la barra de herramientas superior con forma de
   > cubo y línea de puntos **no es esto** — es una herramienta de
   > pintado de superficie distinta (pincel, sin modo de rango de
   > altura). El modificador de rango de altura solo se añade desde
   > el menú contextual de la pieza.
5. Se crea un sub-elemento "Capas" bajo la pieza, con un rango por
   defecto. Introducir el rango **40,5 a 46,5 mm** en los campos
   "Rango de altura".
6. Con ese rango seleccionado en la lista, asignarle el
   **filamento 2** (aparece como una casilla de color junto al
   rango) — no al objeto completo. El resto de la pieza
   (`lower_panel.stl` en sí) debe quedar en filamento 1.

---

## 5. Soportes

La pared del canal de la tira LED tiene un voladizo (10 mm de
grosor, ver `led_channel_wall_thickness` en `lower_panel.scad`) que
necesita soporte. Activar soportes en el laminador antes de
laminar.

---

## 6. Verificación antes de imprimir

En la vista de **Previsualización**, con el esquema de color puesto
en **Filamento**, comprobar que:

- La franja del difusor (40,5–46,5 mm) se distingue claramente del
  resto del cuerpo del panel.
- Los soportes aparecen bajo la pared del canal LED.
- El resto de la pieza queda enteramente en el filamento 1.

> ⚠️ **El modelo 3D en gris no significa que falte configuración.**
> Tanto la vista "Preparar" como la vista "Previsualización" (antes
> de mover el deslizador de capas) pueden mostrar la pieza en un
> solo color aunque el rango de altura esté correctamente
> configurado — el color por filamento solo se ve capa a capa,
> moviendo el **deslizador vertical de capas/altura** (a la derecha
> de la vista 3D, tras laminar) hasta una capa dentro del rango
> 40,5–46,5 mm (con altura de capa 0,2 mm, aproximadamente las
> capas 202 a 232).

**Confirmación más fiable** — el panel **Esquema de colores**
(columna izquierda tras laminar) desglosa el consumo por filamento;
si el filamento 2 aparece con longitud/peso distinto de cero y hay
al menos 2 "Tiempos de cambio de filamento", el rango está aplicado
correctamente, con independencia de lo que se vea en la vista 3D.

---

## 6.1. Verificación real (2026-08-17)

Confirmado con una laminación real en Anycubic Slicer Next:

| Filamento | Longitud | Peso |
|---|---|---|
| 1 (Anycubic PLA) | 6,81 m | 20,32 g |
| 2 (Anycubic PLA+) | 1,96 m | 5,83 g |

- Tiempos de cambio de filamento: **2** (uno al entrar en la franja
  del difusor, otro al salir — coincide con lo esperado para un
  único rango de altura).
- Tiempo de impresión del modelo: 1h 8m. Tiempo total (incluyendo
  purgas): 1h 9m.
- Coste estimado: 0,53 (moneda del laminador).

---

## 7. Historial

- **2026-08-06**: primera versión de este flujo de trabajo,
  confirmada con una impresión real (franja de 6 mm, dentro del
  hueco libre de marco).
- **2026-08-17**: parámetros reverificados tras varias rondas de
  ajuste del panel (ancho a 149 mm, tornillería M3, pared del canal
  LED a 10 mm) — el rango Z del difusor no se ha visto afectado por
  ninguno de esos cambios. Documento creado a partir de esta
  verificación, a petición del usuario.
- **2026-08-17 (más tarde)**: guía corregida tras confusión real del
  usuario siguiendo estos mismos pasos — el paso 3-4 original
  (icono de la barra de herramientas) señalaba una herramienta
  equivocada (pintado de superficie, sin modo de rango de altura).
  Corregido al método real: clic derecho sobre la pieza → menú
  contextual. Añadido el aviso sobre el modelo en gris (normal, no
  es un fallo) y la verificación real de consumo de filamento tras
  laminar (sección 6.1), que confirma que el rango se aplica
  correctamente.
