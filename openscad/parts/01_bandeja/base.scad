//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo    : base.scad
// Versión    : 1.0
//
// Base estructural de la Steam Machine.
//
// Pieza base del proyecto. Genera únicamente la estructura inferior de la
// bandeja. El resto de elementos (postes, nervios, guías, etc.) se añadirán
// mediante módulos independientes.
//
// ============================================================================

include <../../00_parametros.scad>;
include <../../lib/shapes.scad>;


//=============================================================================
// BASE
//=============================================================================

module base()
{

    difference()
    {

        //---------------------------------------------------------------------
        // Contorno exterior
        //---------------------------------------------------------------------

        chamferedPlate(
            width      = tray_width,
            depth      = tray_depth,
            thickness  = tray_thickness,
            chamfer    = base_outer_chamfer,
            center     = true
        );


        //---------------------------------------------------------------------
        // Ventana interior
        //---------------------------------------------------------------------

        translate([0,0,-0.10])

            chamferedPlate(
                width      = tray_width  - (2 * base_frame_width),
                depth      = tray_depth  - (2 * base_frame_width),
                thickness  = tray_thickness + 0.20,
                chamfer    = base_inner_chamfer,
                center     = true
            );

    }


    //---------------------------------------------------------------------
    // Islas estructurales
    //---------------------------------------------------------------------

    for (x=[-1,1])
    for (y=[-1,1])

        translate([
            x*(tray_width/2-base_frame_width-base_island_size/2),
            y*(tray_depth/2-base_frame_width-base_island_size/2),
            0
        ])

            cube(
                [
                    base_island_size,
                    base_island_size,
                    tray_thickness
                ],
                center=true
            );


    //---------------------------------------------------------------------
    // Puente superior
    //---------------------------------------------------------------------

    translate([
        0,
        tray_depth/2-base_frame_width/2,
        0
    ])

        cube(
            [
                base_bridge_width,
                base_frame_width,
                tray_thickness
            ],
            center=true
        );


    //---------------------------------------------------------------------
    // Puente inferior
    //---------------------------------------------------------------------

    translate([
        0,
        -tray_depth/2+base_frame_width/2,
        0
    ])

        cube(
            [
                base_bridge_width,
                base_frame_width,
                tray_thickness
            ],
            center=true
        );


    //---------------------------------------------------------------------
    // Puente izquierdo
    //---------------------------------------------------------------------

    translate([
        -tray_width/2+base_frame_width/2,
        0,
        0
    ])

        rotate([0,0,90])

            cube(
                [
                    base_bridge_width,
                    base_frame_width,
                    tray_thickness
                ],
                center=true
            );


    //---------------------------------------------------------------------
    // Puente derecho
    //---------------------------------------------------------------------

    translate([
        tray_width/2-base_frame_width/2,
        0,
        0
    ])

        rotate([0,0,90])

            cube(
                [
                    base_bridge_width,
                    base_frame_width,
                    tray_thickness
                ],
                center=true
            );

}


//=============================================================================
// PREVIEW
//=============================================================================

SHOW_BASE = true;

if (SHOW_BASE)
{

    color("lightgray")

        base();

}
