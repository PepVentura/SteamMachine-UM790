// =====================================================================
//  Caja con guías internas y tapa para 6 paneles "nfc_panel_blank"
//  Medidas de la pieza (extraídas del STL): 149 x 94.5 x 5 mm
//    ancho (X) = 149   alto (Z) = 94.5   grosor (Y) = 5
//
//  Las piezas se guardan de canto (de pie), una detrás de otra,
//  cada una en su ranura. Sobresalen por arriba para poder cogerlas
//  y la tapa es una "funda" que se desliza por fuera de la caja.
//
//  Impresión (sin soportes):
//    - Caja: base apoyada en la cama.
//    - Tapa: se imprime boca abajo (ya viene girada en part="print").
// =====================================================================

/* [Qué mostrar] */
// print = caja + tapa listas para imprimir | box | lid | assembly = montada
part = "print";   // [print, box, lid, assembly]
// Muestra las piezas de ejemplo (bloques) dentro de la caja
show_pieces = true;

/* [Pieza a guardar] */
piece_w = 149;    // ancho (X)
piece_h = 94.5;   // alto (Z)
piece_t = 5;      // grosor (Y)
n_pieces = 6;     // número de piezas

/* [Holguras] */
clr_x = 0.6;      // holgura lateral por lado
clr_t = 1.0;      // holgura extra en cada ranura (grosor)
lid_clr = 0.3;    // holgura tapa/caja por lado (sube a 0.4 si queda dura)

/* [Caja] */
wall = 2.4;       // grosor de paredes
floor_t = 2.4;    // grosor del suelo
rib_t = 1.6;      // grosor de cada guía (separador entre piezas)
rib_depth = 4;    // cuánto entran las guías desde la pared lateral
floor_rib_len = 40;  // largo de las guías del suelo (0 = sin guías de suelo)
floor_rib_h = 5;     // altura de las guías del suelo
sticks_out = 10;  // cuánto sobresalen las piezas por encima de la caja
corner_r = 3;     // radio de esquinas exteriores

/* [Tapa] */
lid_wall = 2.4;   // grosor paredes de la tapa
lid_top = 2.4;    // grosor de la cara superior
lid_overlap = 10; // cuánto cubre la tapa las paredes de la caja
lid_gap = 1;      // aire entre las piezas y la tapa

$fn = 48;

// ------------------------- cálculos -------------------------
slot_w  = piece_t + clr_t;                          // ancho de cada ranura
in_x    = piece_w + 2*clr_x;                        // interior X
in_y    = n_pieces*slot_w + (n_pieces-1)*rib_t;     // interior Y
in_h    = piece_h - sticks_out;                     // interior Z útil
ox      = in_x + 2*wall;                            // exterior X
oy      = in_y + 2*wall;                            // exterior Y
box_h   = floor_t + in_h;                           // altura de la caja

lid_ix  = ox + 2*lid_clr;                           // interior tapa
lid_iy  = oy + 2*lid_clr;
lid_ox  = lid_ix + 2*lid_wall;
lid_oy  = lid_iy + 2*lid_wall;
lid_in_depth = lid_overlap + sticks_out + lid_gap;  // fondo interior tapa
lid_h   = lid_in_depth + lid_top;

assert(sticks_out < piece_h, "sticks_out debe ser menor que el alto de la pieza");

// ------------------------- módulos -------------------------
module rounded_block(x, y, h, r) {
    hull()
        for (i = [r, x-r], j = [r, y-r])
            translate([i, j, 0]) cylinder(r = r, h = h);
}

// Posición Y del inicio de la ranura k (0..n-1)
function slot_y(k) = wall + k*(slot_w + rib_t);

module box() {
    difference() {
        rounded_block(ox, oy, box_h, corner_r);
        translate([wall, wall, floor_t]) cube([in_x, in_y, in_h + 1]);
    }
    // Guías: un separador entre cada par de ranuras
    for (k = [1 : n_pieces-1]) {
        y = slot_y(k) - rib_t;
        // laterales (altura completa)
        translate([wall - 0.01, y, floor_t - 0.01])
            cube([rib_depth + 0.01, rib_t, in_h + 0.01]);
        translate([ox - wall - rib_depth, y, floor_t - 0.01])
            cube([rib_depth + 0.01, rib_t, in_h + 0.01]);
        // suelo
        if (floor_rib_len > 0)
            translate([ox/2 - floor_rib_len/2, y, floor_t - 0.01])
                cube([floor_rib_len, rib_t, floor_rib_h + 0.01]);
    }
}

// Tapa en posición natural (abierta hacia abajo, cara superior arriba)
module lid_body() {
    difference() {
        rounded_block(lid_ox, lid_oy, lid_h, corner_r + lid_clr + lid_wall);
        translate([lid_wall, lid_wall, -0.01])
            rounded_block(lid_ix, lid_iy, lid_in_depth + 0.01, corner_r + lid_clr);
    }
}

module pieces_preview() {
    color("orange", 0.8)
    for (k = [0 : n_pieces-1])
        translate([ox/2 - piece_w/2, slot_y(k) + clr_t/2, floor_t])
            cube([piece_w, piece_t, piece_h]);
}

// ------------------------- salida -------------------------
if (part == "box") {
    box();
} else if (part == "lid") {
    // tapa boca abajo, lista para imprimir
    translate([0, lid_oy, lid_h]) rotate([180, 0, 0]) lid_body();
} else if (part == "assembly") {
    color("steelblue") box();
    if (show_pieces) pieces_preview();
    color("lightgray", 0.6)
        translate([-(lid_clr + lid_wall), -(lid_clr + lid_wall), box_h - lid_overlap])
            lid_body();
} else {
    // print: caja y tapa una al lado de otra (en Y para caber en camas pequeñas)
    box();
    translate([-(lid_clr + lid_wall), oy + 10 + (lid_clr + lid_wall), 0])
        translate([0, lid_oy, lid_h]) rotate([180, 0, 0]) lid_body();
}

echo(str("Caja exterior: ", ox, " x ", oy, " x ", box_h, " mm"));
echo(str("Tapa exterior: ", lid_ox, " x ", lid_oy, " x ", lid_h, " mm"));
echo(str("Hueco por ranura: ", slot_w, " mm (pieza ", piece_t, " mm)"));
