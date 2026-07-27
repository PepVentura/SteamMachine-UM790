//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : base.scad
// Versión : 2.1
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

    difference()
    {

        //---------------------------------------------------------------------
        // Contorno exterior
        //---------------------------------------------------------------------

        linear_extrude(height = tray_thickness)
        hull()
        {

            translate([-tray_width/2 + 6, -tray_depth/2 + 6])
                circle(r = 6);

            translate([ tray_width/2 - 6, -tray_depth/2 + 6])
                circle(r = 6);

            translate([ tray_width/2 - 6,  tray_depth/2 - 6])
                circle(r = 6);

            translate([-tray_width/2 + 6,  tray_depth/2 - 6])
                circle(r = 6);

        }


        //---------------------------------------------------------------------
        // Ventana central de aligerado
        //---------------------------------------------------------------------

        translate([0,0,-0.1])

        linear_extrude(height = tray_thickness + 0.2)
        hull()
        {

            translate([-45,-35])
                circle(r = 5);

            translate([45,-35])
                circle(r = 5);

            translate([45,35])
                circle(r = 5);

            translate([-45,35])
                circle(r = 5);

        }

    }


    //---------------------------------------------------------------------
    // Marco estructural superior
    //---------------------------------------------------------------------

    translate([0,0,tray_thickness])

    difference()
    {

        linear_extrude(height = 2)
        hull()
        {

            translate([-tray_width/2 + 6,-tray_depth/2 + 6])
                circle(r=6);

            translate([ tray_width/2 - 6,-tray_depth/2 + 6])
                circle(r=6);

            translate([ tray_width/2 - 6, tray_depth/2 - 6])
                circle(r=6);

            translate([-tray_width/2 + 6, tray_depth/2 - 6])
                circle(r=6);

        }


        translate([0,0,-0.1])

        linear_extrude(height = 2.2)
        hull()
        {

            translate([-tray_width/2 + base_frame_width,
                       -tray_depth/2 + base_frame_width])
                circle(r = 5);

            translate([ tray_width/2 - base_frame_width,
                       -tray_depth/2 + base_frame_width])
                circle(r = 5);

            translate([ tray_width/2 - base_frame_width,
                        tray_depth/2 - base_frame_width])
                circle(r = 5);

            translate([-tray_width/2 + base_frame_width,
                        tray_depth/2 - base_frame_width])
                circle(r = 5);

        }

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

base();
