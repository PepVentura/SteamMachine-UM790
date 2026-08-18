//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : rc522_bracket.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Soporte REAL e IMPRIMIBLE del lector RC522 — hasta ahora solo
// existía su volumen de referencia (openscad/reference/components/rc522.scad,
// "NO ES UNA PIEZA IMPRIMIBLE", usado solo para comprobar colisiones).
//
// Une el lector a ambas paredes laterales del chasis (no al panel
// NFC, para poder cambiar el panel sin desconectar el lector —
// docs/02_Mechanical_Layout.md), atornillado a los postes de anclaje
// ya existentes en las paredes (openscad/parts/02_chassis/walls.scad,
// rc522MountBoss()).
//
// Una sola pieza continua (no dos brazos sueltos): el propio tramo
// central hace de bandeja donde se apoya/pega la placa del lector —
// no se conocen las posiciones exactas de los taladros de montaje
// del RC522 real (varían según el modelo de la placa), así que se
// deja como una bandeja plana con un hueco pasacables, en vez de
// asumir unos taladros que podrían no coincidir.
//
// Sistema de coordenadas: igual que el resto del proyecto (X=0
// centro de la carcasa, Y=0 centro en profundidad, Z=0 suelo del
// cascarón).
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// PARÁMETROS DE ESTA PIEZA
//
// rc522_mount_diameter/depth ya existían (openscad/parts/02_chassis/walls.scad)
// — el poste de anclaje real. Aquí solo el taladro de paso, calculado
// con las mismas fuentes para que coincida exactamente.
//=============================================================================

bracket_screw_clearance = 3.4;  // holgura de paso M3
bracket_y = rc522_pos[1] + nfc_reader_depth/2;  // misma Y que el poste de anclaje (walls.scad)
bracket_z = rc522_pos[2];                        // misma Z que el poste de anclaje

// Alcance del brazo: desde el borde de la placa hasta donde EMPIEZA
// el poste de anclaje de la pared (no hasta la pared misma) —
// CORREGIDO (2026-08-03): el poste (rc522MountBoss(), walls.scad) es
// un tubo hueco que ya ocupa el tramo final (rc522_mount_depth = 6mm)
// junto a cada pared; si el brazo macizo llegara hasta la pared,
// invadiría el material del propio tubo. El brazo macizo para justo
// donde empieza el tubo; el taladro de paso sí continúa hasta la
// pared, pero como hueco (ver rc522BracketScrewHoles()).
bracket_half_span = case_width/2 - wall_thickness - rc522_mount_depth;


//=============================================================================
// BANDEJA + BRAZOS (pieza continua)
//=============================================================================

module rc522BracketSolid()
{

    translate([
        -bracket_half_span,
        bracket_y - rc522_bracket_thickness/2,
        bracket_z - rc522_bracket_width/2
    ])

        cube([
            bracket_half_span*2,
            rc522_bracket_thickness,
            rc522_bracket_width
        ]);

}


//=============================================================================
// HUECO PASACABLES (bajo la placa, hacia el conector SPI/alimentación)
//=============================================================================

module rc522CableSlot()
{

    slotWidth = nfc_reader_width*0.6;

    translate([
        -slotWidth/2,
        bracket_y - rc522_bracket_thickness/2 - 1,
        bracket_z - rc522_bracket_width/2 - 1
    ])

        cube([
            slotWidth,
            rc522_bracket_thickness+2,
            rc522_bracket_width*0.4
        ]);

}


//=============================================================================
// TALADROS DE PASO M3 (a los postes de anclaje de las paredes)
//
// Deben coincidir en Y/Z con rc522MountBoss() en
// openscad/parts/02_chassis/walls.scad (misma fuente, rc522_pos —
// ver assembly_positions.scad). En X, dentro del alcance del poste
// (que crece 6 mm hacia el interior desde cada pared:
// rc522_mount_depth, definido en walls.scad).
//=============================================================================

module rc522BracketScrewHoles()
{

    for(ix=[-1,1])

        translate([
            ix*(bracket_half_span + rc522_mount_depth/2),
            bracket_y,
            bracket_z
        ])

            rotate([0,90,0])
                cylinder(d = bracket_screw_clearance, h = rc522_mount_depth+4, center=true);

}


//=============================================================================
// SOPORTE COMPLETO
//=============================================================================

module rc522Bracket()
{

    difference()
    {

        rc522BracketSolid();

        rc522CableSlot();

        rc522BracketScrewHoles();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Silver")
    rc522Bracket();
