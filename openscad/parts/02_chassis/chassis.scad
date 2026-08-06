//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : chassis.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Chasis principal FIJO — sustituye a openscad/parts/02_chassis/chassis_lower.scad
// (diseñado desde cero, ver conversación: "no tenemos porque
// aprovechar los prototipos anteriores").
//
// Compuesto de:
//   - Suelo, con rejilla de ventilación (floor.scad)
//   - Pared izquierda y derecha (walls.scad)
//
// NO incluye:
//   - Pared/panel frontal — desmontable, magnético (docs/DESIGN_RULES.md)
//   - Pared/panel trasero — va unido a la bandeja, no al chasis fijo
//   - Techo/tapa — pieza desmontable aparte
//
// Sistema de coordenadas: igual que
// openscad/reference/components/assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del chasis.
//
// ============================================================================

include <../../../00_parametros.scad>;

use <floor.scad>;
use <walls.scad>;

$fn = 64;

part_version = "1.0";


//=============================================================================
// CHASIS COMPLETO
//=============================================================================

module chassisFixed()
{

    union()
    {

        chassisFloor();

        chassisSideWalls();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    chassisFixed();
