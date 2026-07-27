//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : base.scad
// Versión : 2.0
//
// Base estructural de la bandeja
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// BASE EXTERIOR
//=============================================================================

module base_plate()
{
    linear_extrude(height = tray_thickness)
    hull()
    {

        translate([
            -tray_width/2 + base_outer_chamfer,
            -tray_depth/2 + base_outer_chamfer
        ])
            circle(r = base_outer_chamfer);

        translate([
             tray_width/2 - base_outer_chamfer,
            -tray_depth/2 + base_outer_chamfer
        ])
            circle(r = base_outer_chamfer);

        translate([
            -tray_width/2 + base_outer_chamfer,
             tray_depth/2 - base_outer_chamfer
        ])
            circle(r = base_outer_chamfer);

        translate([
             tray_width/2 - base_outer_chamfer,
             tray_depth/2 - base_outer_chamfer
        ])
            circle(r = base_outer_chamfer);

    }
}


//=============================================================================
// VENTANA CENTRAL
//=============================================================================

module center_cutout()
{

    cut_x = tray_width - (base_frame_width * 2);
    cut_y = tray_depth - (base_frame_width * 2);

    translate([0,0,-0.1])

    linear_extrude(height = tray_thickness + 0.2)

    hull()
    {

        translate([
            -cut_x/2 + base_inner_chamfer,
            -cut_y/2 + base_inner_chamfer
        ])
            circle(r = base_inner_chamfer);

        translate([
             cut_x/2 - base_inner_chamfer,
            -cut_y/2 + base_inner_chamfer
        ])
            circle(r = base_inner_chamfer);

        translate([
            -cut_x/2 + base_inner_chamfer,
             cut_y/2 - base_inner_chamfer
        ])
            circle(r = base_inner_chamfer);

        translate([
             cut_x/2 - base_inner_chamfer,
             cut_y/2 - base_inner_chamfer
        ])
            circle(r = base_inner_chamfer);

    }

}


//=============================================================================
// BASE COMPLETA
//=============================================================================

module base()
{

    difference()
    {

        base_plate();

        center_cutout();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

if($preview)
{

    color("Gainsboro")
        base();

}
