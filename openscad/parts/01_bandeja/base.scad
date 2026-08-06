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

    difference()
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


        //---------------------------------------------------------------------
        // Insertos de unión con el panel trasero
        // (openscad/parts/01_bandeja/rear_panel.scad, rearBridgeTabs()/
        // rearBridgeScrewHoles() — deben coincidir en X con
        // rear_bridge_x_inset y en Z con rear_insert_z de ese archivo).
        //---------------------------------------------------------------------

        trayRearBridgeInserts();

    }

    // FALLO CORREGIDO (2026-08-03, aviso del usuario): faltaba el
    // taladro de paso para el tornillo que fija la bandeja a los
    // pilares de apoyo del suelo (openscad/parts/02_chassis/floor.scad,
    // traySupportPosts()) — sin este taladro no hay forma de
    // atornillar la bandeja a esos pilares.
    trayScrewClearanceHoles();

    }

}


//=============================================================================
// TALADROS DE PASO DE LOS PILARES DE APOYO
//
// Deben coincidir en X/Y con traySupportPosts() en
// openscad/parts/02_chassis/floor.scad (misma fuente,
// tray_support_inset_x/y, ver 00_parametros.scad).
//=============================================================================

tray_screw_clearance = 3.4;  // holgura de paso para M3

module trayScrewClearanceHoles()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*(tray_width/2 - tray_support_inset_x),
            iy*(tray_depth/2 - tray_support_inset_y),
            -0.1
        ])

            cylinder(d = tray_screw_clearance, h = tray_thickness+0.2);

}


//=============================================================================
// INSERTOS DE UNIÓN CON EL PANEL TRASERO
//=============================================================================

rear_bridge_x_inset_local = 15.0;  // = rear_bridge_x_inset en rear_panel.scad
rear_bridge_insert_diameter = 10.0;
rear_bridge_post_height = insert_depth + 1.0;  // sobresale del grosor de la bandeja (3mm < 5mm de inserto)

module trayRearBridgeInserts()
{

    for(ix=[-1,1])

        translate([
            ix*(case_width/2 - rear_bridge_x_inset_local),
            tray_depth/2 - rear_bridge_insert_diameter/2,
            0
        ])

            difference()
            {

                cylinder(
                    d = rear_bridge_insert_diameter,
                    h = rear_bridge_post_height
                );

                translate([0,0,rear_bridge_post_height-insert_depth])
                    cylinder(d = insert_diameter, h = insert_depth+0.1);

            }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    base();
