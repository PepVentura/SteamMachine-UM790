# SteamMachine UM790

# 14 - Caja para guardar los paneles NFC

Version: 1.0
Status: Diseñada; dimensiones comprobadas contra los STL. Pendiente de validar la impresión en PETG.

Pieza: `openscad/parts/Caja paneles NFC/caja_nfc_panel.scad`
STL: `STL/caja_nfc_panel_caja.stl`, `STL/caja_nfc_panel_tapa.stl` y
`STL/caja_nfc_panel_caja_y_tapa.stl` (las dos piezas en una sola placa,
equivale a `part = "print"`).

---

## 1. Qué es

Una caja con guías interiores y una tapa tipo funda que se desliza por
fuera. Guarda **6 paneles NFC de canto**, uno detrás de otro, cada uno
en su ranura. Los paneles sobresalen 10 mm por arriba para poder
cogerlos sin tirar de la tapa.

Hoy hay 5 paneles definidos en `software/config/panel_database.json`
(Steam, RetroDECK, Maintenance, Zombies y Apagar), así que queda **1
ranura libre**.

## 2. Medidas

Calculadas a partir del `.scad` y comprobadas contra el cuadro
delimitador de los STL (coinciden):

| Pieza | Medidas (mm) |
|---|---|
| Caja (exterior) | 155 × 48,8 × 86,9 |
| Tapa (exterior) | 160,4 × 54,2 × 23,4 |
| Placa con caja y tapa | 160,4 × 115,7 × 86,9 |
| Panel a guardar | 149 × 94,5 × 5 |
| Ranura por panel | 6 (panel 5 + 1 de holgura) |

## 3. Qué paneles caben

El panel en blanco mide 5 mm de grosor: placa de 3 mm
(`front_panel_thickness`) más un marco de 2 mm (`front_bezel_depth`). Un
anagrama de 2 mm pegado sobre la placa queda a ras del marco, así que el
panel sigue midiendo 5 mm y cabe.

Los anagramas de **3 mm** (`Parrot.stl`, `Mando.stl`) sobresaldrían 1 mm
del marco y el panel pasaría a 6 mm: no cabría en una ranura de 6 mm.
Si quieres guardar alguno, sube `piece_t` a 6 en el `.scad` y regenera
los STL (la caja crece a 54,8 mm de fondo).

> Esto es un cálculo a partir de las medidas del diseño. Mide un panel
> real terminado con calibre antes de imprimir la caja.

## 4. Impresión

- **Material: PETG**, por coherencia con el resto del proyecto. La caja
  no recibe calor del equipo, así que PLA también valdría.
- Sin soportes.
- Caja: apoyada por su base. Tapa: boca abajo (ya viene girada en
  `part = "print"`).
- Parámetros orientativos: capa 0,20 mm, 3-4 perímetros, relleno 15-20 %.
- **Holguras**: `lid_clr` = 0,3 mm por lado entre tapa y caja, `clr_t` =
  1 mm de holgura por ranura. Se diseñaron con PLA+ y **no se han
  validado con PETG**. Si la tapa queda dura, sube `lid_clr` a 0,4; si
  un panel aprieta en su ranura, sube `clr_t`.

## 5. Regenerar los STL

```bash
cd "openscad/parts/Caja paneles NFC"
openscad -o ../../../STL/caja_nfc_panel_caja.stl -D 'part="box"' caja_nfc_panel.scad
openscad -o ../../../STL/caja_nfc_panel_tapa.stl -D 'part="lid"' caja_nfc_panel.scad
openscad -o ../../../STL/caja_nfc_panel_caja_y_tapa.stl -D 'part="print"' caja_nfc_panel.scad
```

Con `part = "assembly"` se ve la caja montada, con bloques de ejemplo
dentro (`show_pieces`).
