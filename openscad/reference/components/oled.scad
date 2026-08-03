//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : oled.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia del módulo OLED 27 x 27 mm para el
// ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro del módulo en X/Z, cara frontal (visible
//                     a través del panel).
//   +Y = hacia el interior del chasis (pines de conexión).
//   +Z = hacia arriba.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 24;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

oledGlassColor = [0.05,0.05,0.10,1.0];
oledPinColor   = [0.80,0.80,0.20,1.0];


//=============================================================================
// MÓDULO (VIDRIO + PCB)
//=============================================================================

module oledPanel()
{

    color(oledGlassColor)

    translate([
        -oled_module_width/2,
        0,
        -oled_module_height/2
    ])

        cube([
            oled_module_width,
            oled_module_thickness,
            oled_module_height
        ]);

}


//=============================================================================
// PINES / SOLDADURA TRASERA
//=============================================================================

module oledPins()
{

    pinBlockWidth  = oled_module_width*0.6;
    pinBlockHeight = 4;

    color(oledPinColor)

    translate([
        -pinBlockWidth/2,
        oled_module_thickness,
        -oled_module_height/2 - pinBlockHeight
    ])

        cube([
            pinBlockWidth,
            oled_module_pin_height,
            pinBlockHeight
        ]);

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module oledBody()
{

    union()
    {
        oledPanel();
        oledPins();
    }

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module oled()
{

    oledBody();

}


//=============================================================================
// PREVIEW
//=============================================================================

oled();
