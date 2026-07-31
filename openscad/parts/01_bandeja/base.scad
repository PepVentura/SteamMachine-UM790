//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : base.scad
// Versión : 8.0
//
// Base estructural de la bandeja.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;

//=============================================================================
// BASE
//=============================================================================

module base()
{

    union()
    {

        //---------------------------------------------------------------------
        // Marco exterior
        //---------------------------------------------------------------------

        difference()
        {

            translate([
                -tray_width/2,
                -tray_depth/2,
                0
            ])
            cube([
                tray_width,
                tray_depth,
                tray_thickness
            ]);


            translate([
                -(tray_width-2*base_frame_width)/2,
                -(tray_depth-2*base_frame_width)/2,
                -0.1
            ])
            cube([
                tray_width-2*base_frame_width,
                tray_depth-2*base_frame_width,
                tray_thickness+0.2
            ]);

        }


        //---------------------------------------------------------------------
        // Islas de apoyo de los postes
        //---------------------------------------------------------------------

        for(ix=[-1,1])
        for(iy=[-1,1])
        {

            translate([
                ix*off_x-base_island_size/2,
                iy*off_y-base_island_size/2,
                0
            ])
            cube([
                base_island_size,
                base_island_size,
                tray_thickness
            ]);

        }


        //---------------------------------------------------------------------
        // Refuerzo horizontal
        //---------------------------------------------------------------------

        translate([
            -off_x,
            -base_bridge_width/2,
            0
        ])
        cube([
            off_x*2,
            base_bridge_width,
            tray_thickness
        ]);


        //---------------------------------------------------------------------
        // Refuerzo vertical
        //---------------------------------------------------------------------

        translate([
            -base_bridge_width/2,
            -off_y,
            0
        ])
        cube([
            base_bridge_width,
            off_y*2,
            tray_thickness
        ]);

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

if ($preview)
{
    color("Gainsboro")
        base();
}
