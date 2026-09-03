//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : leftwall_flat.scad
// Versión  : 1.0
// Fecha    : 2026-08-19
//
// Pared izquierda, girada y tumbada para imprimir — la cara
// exterior (lisa, sin ningún relieve) queda apoyada en la cama
// (Z=0), con todos los relieves de refuerzo (imanes, tornillos del
// panel inferior, insertos de la tapa, tornillo del panel trasero,
// insertos de fijación al suelo) hacia arriba. No debería necesitar
// soportes de impresión.
//
// De pie (orientación original de leftWall() en walls.scad), la
// altura en Z es de 148mm (shell_height) — varios cientos de capas.
// Tumbada así, la altura en Z pasa a ser solo el grosor de la pared
// con sus relieves (~10mm) — reducción de capas de más del 90%.
//
// Verificado (2026-08-19): watertight, 1 solo cuerpo, cara inferior
// (Z=0) completamente plana.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <walls.scad>;

$fn = 64;

// Girada 90° sobre el eje Y (con el signo que deja la cara exterior
// lisa hacia abajo, no los relieves) y desplazada +78 en Z para que
// apoye exactamente en Z=0.
translate([0, 0, 78])
    rotate([0, -90, 0])
        leftWall();
