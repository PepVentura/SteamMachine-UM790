//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : chassis_layout.scad
// Versión : 1.0
//
// Layout general del proyecto.
// NO es una pieza imprimible.
//
// ============================================================================

include <../../00_parametros.scad>;

use <../parts/01_bandeja/tray.scad>;

$fn=64;


//=============================================================================
// PARÁMETROS DEL LAYOUT
//=============================================================================

air_gap = 12;


//=============================================================================
// CHASIS EXTERIOR (visual)
//=============================================================================

module chassis_outline()
{

    color([0.15,0.15,0.15,0.15])

    difference()
    {

        translate([
            -case_width/2,
            -case_depth/2,
            0
        ])

        cube([
            case_width,
            case_depth,
            case_height
        ]);


        translate([
            -case_width/2+wall_thickness,
            -case_depth/2+wall_thickness,
            wall_thickness
        ])

        cube([
            case_width-2*wall_thickness,
            case_depth-2*wall_thickness,
            case_height
        ]);

    }

}



//=============================================================================
// FONDO DEL CHASIS
//=============================================================================

module chassis_floor()
{

    color("DimGray")

    translate([
        -case_width/2,
        -case_depth/2,
        0
    ])

    cube([
        case_width,
        case_depth,
        bottom_thickness
    ]);

}



//=============================================================================
// TORRES SOPORTE BANDEJA
//=============================================================================

module support_post(x,y)
{

    color("Silver")

    translate([
        x,
        y,
        bottom_thickness
    ])

    cylinder(
        h=air_gap,
        d=12
    );

}



module support_posts()
{

    support_post( off_x, off_y);
    support_post(-off_x, off_y);
    support_post(-off_x,-off_y);
    support_post( off_x,-off_y);

}



//=============================================================================
// BANDEJA
//=============================================================================

module tray_position()
{

    color("LightGray")

    translate([
        0,
        0,
        bottom_thickness+air_gap
    ])

    tray();

}



//=============================================================================
// UM790 (volumen)
//=============================================================================

module um790_volume()
{

    color([0,0.6,0,0.35])

    translate([
        -pcb_width/2,
        -pcb_depth/2,
        bottom_thickness
        +air_gap
        +tray_thickness
        +um790_post_height
    ])

    cube([
        pcb_width,
        pcb_depth,
        40
    ]);

}



//=============================================================================
// NOCTUA
//=============================================================================

module fan_volume()
{

    color([0.7,0.2,0.2,0.35])

    translate([
        -60,
        -60,
        case_height-15
    ])

    cube([
        120,
        120,
        15
    ]);

}



//=============================================================================
// PANEL TRASERO
//=============================================================================

module rear_panel()
{

    color([0.2,0.2,1,0.25])

    translate([
        -case_width/2,
        case_depth/2-wall_thickness,
        0
    ])

    cube([
        case_width,
        wall_thickness,
        case_height
    ]);

}



//=============================================================================
// ENSAMBLAJE
//=============================================================================

chassis_outline();

chassis_floor();

support_posts();

tray_position();

um790_volume();

fan_volume();

rear_panel();
