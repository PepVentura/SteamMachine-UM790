//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : pushbutton.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia del pulsador M16 x 55 mm para el
// ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro del embellecedor, cara frontal (la que
//                     queda visible en el panel).
//   +Z = hacia el interior del chasis (rosca + cuerpo del mecanismo).
//        Se usa +Z, no +Y, para que el cilindro se extruya de forma
//        natural; el ensamblaje (virtual_assembly_v1.scad) rota este
//        módulo 90º sobre X al montarlo en el panel frontal.
//
// pushbutton_total_length (55 mm) es el dato real proporcionado para
// este componente y se modela aquí como cuerpo rígido completo, sin
// suponer una parte flexible de cableado. La comprobación de
// colisiones de virtual_assembly_v1.scad puede por tanto detectar
// una interferencia real con la PCB del UM790 si la posición de
// montaje no deja 55 mm libres detrás del panel; ver
// docs/Virtual_Assembly_Report.md.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

pushbuttonCapColor    = [0.85,0.05,0.05,1.0];
pushbuttonBodyColor   = [0.60,0.60,0.60,1.0];


//=============================================================================
// EMBELLECEDOR VISIBLE
//=============================================================================

module pushbuttonCap(capThickness = 4)
{

    color(pushbuttonCapColor)

        cylinder(
            d = pushbutton_cap_diameter,
            h = capThickness
        );

}


//=============================================================================
// ROSCA + CUERPO DEL MECANISMO (longitud total real: 55 mm)
//=============================================================================

module pushbuttonBody(capThickness = 4)
{

    color(pushbuttonBodyColor)

    translate([0,0,capThickness])

        cylinder(
            d = pushbutton_thread_diameter,
            h = pushbutton_total_length
        );

}


//=============================================================================
// CUERPO MECÁNICO COMPLETO (para comprobación de colisiones "duras")
//=============================================================================

module pushbuttonFull()
{

    union()
    {
        pushbuttonCap();
        pushbuttonBody();
    }

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module pushbutton()
{

    pushbuttonFull();

}


//=============================================================================
// PREVIEW
//=============================================================================

pushbutton();
