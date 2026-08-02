# SteamMachine UM790
## Mechanical Layout
Version: 1.0
Status: Approved
Date: 2026-08-02

SteamMachine UM790 – Documento de Implantación Mecánica (DIM v1.0)
1. Objetivos

La implantación debe garantizar:

Cero interferencias entre componentes.
Flujo de aire vertical eficiente.
Acceso sencillo para mantenimiento.
Modularidad del frontal.
Respeto de las dimensiones originales de la Steam Machine.
2. Dimensiones exteriores (congeladas)
Parámetro	Valor
Anchura	156 mm
Profundidad	162,4 mm
Altura del cuerpo	148 mm
Altura total con patas	152 mm

Estas dimensiones no se modificarán.

3. Componentes principales
UM790 Pro

Elemento principal.

Se colocará centrado respecto al chasis.

Orientación:

Conectores originales hacia el panel trasero.

Separación respecto a la base:

8 mm mediante separadores.

Ventilador

Noctua NF-A12x15

120×120×15 mm

Se situará exactamente encima del UM790.

No desplazado.

La tapa superior tendrá una gran rejilla centrada.

RC522

Posición:

Detrás del panel NFC superior.

No irá fijado al panel.

Quedará suspendido mediante dos soportes laterales integrados en el bastidor.

Separación al panel:

3 mm.

Panel NFC

Ocupará prácticamente todo el ancho frontal.

Llevará:

logotipo en relieve.
alojamiento posterior para el tag NFC.

Será completamente intercambiable.

Panel inferior

Una sola pieza.

Contendrá:

pulsador.
OLED.
USB.
barra LED.

No soportará electrónica.

Toda la electrónica irá en el bastidor.

ESP32

Situado en el lateral izquierdo.

Motivos:

cerca del RC522.
cerca del OLED.
cerca del LED.

Montaje:

4 separadores M3.

Insertos térmicos.

HUB USB

Situado en el lateral derecho.

No alineado con el frontal.

Los USB frontales serán los empotrables de Ø29 mm.

USB empotrable

Montaje:

Frontal.

Taladro Ø29 mm.

Conectado mediante cables USB al HUB.

Pulsador

Situado a la izquierda.

Rosca:

M16.

Longitud:

55 mm.

Quedará totalmente libre por detrás.

OLED

Situado aproximadamente centrado.

Ventana:

27×27 mm.

Montaje sobre soporte independiente.

4. Cableado

Quedará dividido en dos zonas.

Lado izquierdo
ESP32
RC522
OLED
LED
Lado derecho
HUB
USB
alimentación interna

No habrá cruces sobre el UM790.

5. Flujo de aire

Entrada:

Base.

Paso:

UM790.

Salida:

Ventilador Noctua.

Tapa superior.

No habrá rejillas laterales.

6. Paneles
Superior

Atornillado.

Rejilla ventilación.

Trasero

Atornillado.

Insertos M3.

Panel NFC

Imanes.

Panel inferior

No imanes.

Se fijará mediante tornillos M2 sobre insertos térmicos.

7. Insertos térmicos

M2

panel inferior.

M3

panel trasero.
panel superior.
soportes electrónicos.
front frame.
8. Verificación de colisiones (lista de comprobación)

Antes de modelar el bastidor se verificará:

☐ Pulsador ↔ UM790.
☐ OLED ↔ UM790.
☐ USB frontal ↔ HUB.
☐ RC522 ↔ Ventilador.
☐ RC522 ↔ Panel NFC.
☐ ESP32 ↔ HUB.
☐ Cables USB ↔ Ventilador.
☐ Cables OLED ↔ Ventilador.
☐ Cables RC522 ↔ UM790.
☐ Conector de alimentación UM790 ↔ Panel trasero.
☐ Tornillos ↔ componentes.
☐ Insertos ↔ nervios del bastidor.
9. Orden de desarrollo

Una vez aprobado este documento:

Modelo de implantación 3D (componentes simplificados a escala, sin detalles estéticos).
Verificación de colisiones.
Diseño del bastidor (chassis.scad).
front_frame.scad.
Panel inferior.
Panel NFC.
Panel trasero.
Panel superior.
