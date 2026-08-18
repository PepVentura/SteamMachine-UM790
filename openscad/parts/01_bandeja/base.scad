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
        //
        // FALLO CORREGIDO (2026-08-03, petición del usuario, marcado
        // directamente en una captura de su laminador — "el que está
        // más al exterior"): el segmento DELANTERO de este marco (no
        // el nervio interior, que ya se quitó en una ronda anterior
        // por error) choca con el conector USB interno y el pulsador
        // de la placa UM790. Se recorta solo ese tramo (el resto del
        // marco — trasero, izquierdo, derecho — sigue intacto).
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

            // tramo delantero del marco — eliminado
            translate([
                -tray_width/2-0.1,
                -tray_depth/2-0.1,
                -0.1
            ])
            cube([
                tray_width+0.2,
                base_frame_width+0.1,
                tray_thickness+0.2
            ]);

        }


        //---------------------------------------------------------------------
        // Islas de apoyo de los postes
        //
        // FALLO CORREGIDO (2026-08-03): la unión con el marco exterior
        // producía una arista no-manifold exactamente en X=55,
        // Y=±41,5 (el borde interior del marco coincidía en un punto
        // exacto con el borde de la isla) — un caso típico de
        // coincidencia geométrica exacta que confunde a CGAL.
        // Corregido con un pequeño margen (island_overlap) para que
        // la isla se solape claramente, sin bordes exactamente
        // coincidentes.
        //---------------------------------------------------------------------

        island_overlap = 0.2;

        for(ix=[-1,1])
        for(iy=[-1,1])
        {

            translate([
                ix*off_x-base_island_size/2-island_overlap,
                iy*off_y+um790_post_y_offset-base_island_size/2-island_overlap,
                0
            ])
            cube([
                base_island_size+2*island_overlap,
                base_island_size+2*island_overlap,
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
        // Refuerzo alrededor de los taladros de paso a los pilares
        // del suelo — ver traySupportHolePads() más abajo.
        //---------------------------------------------------------------------

        traySupportHolePads();


        //---------------------------------------------------------------------
        // Insertos de unión con el panel trasero
        // (openscad/parts/01_bandeja/rear_panel.scad, rearBridgeTabs()/
        // rearBridgeScrewHoles() — deben coincidir en X con
        // rear_bridge_x_inset y en Z con rear_insert_z de ese archivo).
        //---------------------------------------------------------------------

        trayRearBridgeInserts();

        trayRearBridgeInsertPads();

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
// REFUERZO ALREDEDOR DE LOS TALADROS DE PASO A LOS PILARES
//
// FALLO CORREGIDO (2026-08-03, aviso del usuario: "hay dos agujeros
// que quedan medio tapados"): el taladro (X=±60, Y=±40) caía casi
// entero fuera de la isla de apoyo del poste (que solo llega hasta
// Y=±41,5) — la mayor parte del taladro (3,2 de sus 3,4mm de
// diámetro) quedaba en hueco abierto, sin apenas material alrededor.
// Como la posición del taladro depende de los pilares del suelo (ya
// impresos, no se puede mover), se añade un parche de material
// alrededor de cada taladro, conectando con la isla existente, en
// vez de mover el taladro o la isla entera.
//=============================================================================

tray_support_pad_margin = 2.0;  // margen alrededor del taladro

module traySupportHolePads()
{

    padHalf = tray_screw_clearance/2 + tray_support_pad_margin;

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*(tray_width/2 - tray_support_inset_x) - padHalf,
            iy*(tray_depth/2 - tray_support_inset_y) - padHalf,
            0
        ])

            cube([padHalf*2, padHalf*2, tray_thickness]);

}


//=============================================================================
// REFUERZO DEL INSERTO DE UNIÓN CON EL PANEL TRASERO
//
// FALLO CORREGIDO (2026-08-03, captura del usuario): el inserto
// (X=±63, Ø10mm) sobresalía 3mm más allá del propio borde de la
// bandeja (que termina en X=±65) — la parte exterior del inserto
// quedaba sin apoyo, fuera del marco de la bandeja. Se añade un
// parche que extiende el marco hasta cubrir el inserto entero, con
// margen de sobra respecto a la pared (7mm disponibles antes de
// llegar a ella).
//=============================================================================

module trayRearBridgeInsertPads()
{

    padMargin = 1.0;
    postCenterX = case_width/2 - rear_bridge_x_inset_local;
    postOuterX  = postCenterX + rear_bridge_insert_diameter/2 + padMargin;
    padWidth    = postOuterX - tray_width/2;

    for(ix=[-1,1])

        translate([
            ix>0 ? tray_width/2 : -postOuterX,
            tray_depth/2 - rear_bridge_insert_diameter - padMargin,
            0
        ])

            cube([
                padWidth,
                rear_bridge_insert_diameter + 2*padMargin,
                tray_thickness
            ]);

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
