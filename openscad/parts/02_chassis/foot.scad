//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : foot.scad
// Versión  : 1.0
// Fecha    : 2026-08-19
// Autor    : Pep Ventura (asistido por Claude)
//
// Pie desmontable, atornillado al suelo del chasis.
//
// PEDIDO POR EL USUARIO (2026-08-19): "Lo quiero liso y diseñar
// cuatro patas para atornillarlas a posteriori" — sustituye las
// patas integradas de una pieza (que dejaban voladizos y
// necesitaban soporte de impresión al tumbar el suelo). El suelo
// (floor.scad) ahora tiene insertos M3 ciegos en las mismas 4
// posiciones donde antes estaban las patas
// (floorLegMountInserts()); este pie se atornilla desde abajo.
//
// Coincide en tamaño con las patas originales (leg_footprint,
// 00_parametros.scad/floor.scad) para no dejar hueco visible al
// borde del suelo.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 64;

part_version = "1.0";


//=============================================================================
// MEDIDAS DEL PIE
//=============================================================================

foot_diameter = 10.0;  // = leg_footprint en floor.scad, mismo tamaño que las patas originales
foot_height   = 6.0;   // ESTIMADO — antes 4mm integrado; algo más de margen de ventilación al ser pieza aparte, ajustable sin tocar el suelo

foot_screw_clearance_diameter = 3.4;  // holgura de paso para M3
foot_screw_csk_diameter = 6.5;  // ESTIMADO — igual que floor_mount_csk_diameter en floor.scad
foot_screw_csk_depth = 2.0;  // ESTIMADO — profundidad del avellanado, dentro del grosor del pie


//=============================================================================
// PIE COMPLETO
//=============================================================================

module foot()
{

    difference()
    {

        cylinder(d = foot_diameter, h = foot_height);

        // Taladro de paso — el tornillo entra por abajo (donde toca
        // el suelo real) y sale roscando hacia arriba en el
        // inserto del suelo del chasis.
        translate([0, 0, -0.1])
            cylinder(d = foot_screw_clearance_diameter, h = foot_height + 0.2);

        // Avellanado en la cara inferior (la que toca el suelo
        // real), para que la cabeza del tornillo no sobresalga y
        // el pie apoye plano.
        translate([0, 0, -0.05])
            cylinder(d1 = foot_screw_csk_diameter, d2 = foot_screw_clearance_diameter, h = foot_screw_csk_depth + 0.05);

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("SlateGray")
    foot();
