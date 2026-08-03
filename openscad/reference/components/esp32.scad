//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : esp32.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia de la placa "ESP32 Terminal Adapter"
// (78 x 63 mm, taladros M3 con separación 73 x 58 mm) para el
// ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro de la placa en X/Y, cara inferior
//                     (plano de apoyo sobre la repisa de montaje).
//   +Z = hacia arriba (hacia el módulo ESP32 y las regletas).
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 24;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

esp32BoardColor     = [0.65,0.10,0.10,1.0];
esp32ModuleColor    = [0.15,0.15,0.55,1.0];
esp32HoleColor      = [1.00,0.00,0.00,1.0];
esp32CableColor     = [1.00,0.65,0.00,0.15];


//=============================================================================
// PLACA ADAPTADORA
//=============================================================================

module esp32AdapterBoard()
{

    color(esp32BoardColor)

    difference()
    {

        translate([
            -esp32_adapter_width/2,
            -esp32_adapter_depth/2,
            0
        ])

            cube([
                esp32_adapter_width,
                esp32_adapter_depth,
                esp32_adapter_thickness
            ]);

        esp32MountHoles();

    }

}


//=============================================================================
// TALADROS M3 (73 x 58 mm)
//=============================================================================

module esp32MountHoles()
{

    color(esp32HoleColor)

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*esp32_adapter_hole_spacing_x/2,
            iy*esp32_adapter_hole_spacing_y/2,
            -0.5
        ])

            cylinder(
                d = esp32_adapter_hole_diameter,
                h = esp32_adapter_thickness+1
            );

}


//=============================================================================
// VOLUMEN DEL MÓDULO ESP32 + REGLETAS + CABLEADO SUPERIOR
//
// Bloque simplificado que engloba el DevKit ESP32, las regletas de
// terminales y el margen para el cableado que sale hacia arriba.
// Se apoya centrado sobre la placa adaptadora, con un margen respecto
// a los taladros de fijación.
//=============================================================================

module esp32ComponentVolume()
{

    componentWidth = esp32_adapter_hole_spacing_x - 6;
    componentDepth = esp32_adapter_hole_spacing_y - 6;

    color(esp32ModuleColor)

    translate([
        -componentWidth/2,
        -componentDepth/2,
        esp32_adapter_thickness
    ])

        cube([
            componentWidth,
            componentDepth,
            esp32_adapter_component_height
        ]);

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module esp32Body()
{

    union()
    {
        esp32AdapterBoard();
        esp32ComponentVolume();
    }

}


//=============================================================================
// VOLUMEN DE SEGURIDAD DE CABLEADO
//
// Espacio reservado en el borde -Y de la placa para el conexionado
// hacia el RC522, el HUB USB, el OLED y el pulsador.
//=============================================================================

module esp32CableKeepout(length = 15)
{

    color(esp32CableColor)

    translate([
        -esp32_adapter_width/2,
        -esp32_adapter_depth/2 - length,
        0
    ])

        cube([
            esp32_adapter_width,
            length,
            esp32_adapter_thickness + esp32_adapter_component_height
        ]);

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module esp32()
{

    esp32Body();

    esp32CableKeepout();

}


//=============================================================================
// PREVIEW
//=============================================================================

esp32();
