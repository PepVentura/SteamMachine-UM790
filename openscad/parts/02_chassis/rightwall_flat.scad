//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : rightwall_flat.scad
// Versión  : 1.0
// Fecha    : 2026-08-19
//
// Pared derecha, girada y tumbada para imprimir — mismo criterio
// que leftwall_flat.scad (cara exterior lisa apoyada en la cama,
// relieves hacia arriba, sin necesitar soportes), girada al lado
// contrario por ser la pared opuesta.
//
// Verificado (2026-08-19): watertight, 1 solo cuerpo, cara inferior
// (Z=0) completamente plana.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <walls.scad>;

$fn = 64;

translate([0, 0, 78])
    rotate([0, 90, 0])
        rightWall();
