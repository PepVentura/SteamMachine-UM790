//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// base.scad
//
// VERSION 5.0
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 80;


//==========================================================
// RECTÁNGULO REDONDEADO
//==========================================================

module rounded_rect(x,y,r)
{

    hull()
    {

        for(ix=[-1,1])

        for(iy=[-1,1])

            translate(
            [
                ix*(x/2-r),
                iy*(y/2-r)
            ])
                circle(r=r);

    }

}



//==========================================================
// BASE
//==========================================================

module base()
{

difference()
{

    //------------------------------------------------------
    // Placa principal
    //------------------------------------------------------

    linear_extrude(tray_thickness)

        rounded_rect(
            tray_width,
            tray_depth,
            base_outer_chamfer
        );


    //------------------------------------------------------
    // Hueco central
    //------------------------------------------------------

    translate([0,0,-0.1])

    linear_extrude(tray_thickness+0.2)

        rounded_rect(

            tray_width-2*base_frame_width,

            tray_depth-2*base_frame_width,

            base_inner_chamfer

        );

}



//==========================================================
// ISLAS DE REFUERZO
//==========================================================

translate([0,0,tray_thickness])

{

    island=base_island_size;



    //--------------------------------------------------
    // 4 islas bajo los postes
    //--------------------------------------------------

    for(px=[-off_x,off_x])

    for(py=[-off_y,off_y])

        translate([px,py,0])

        linear_extrude(2)

            rounded_rect(
                island,
                island,
                3
            );



    //--------------------------------------------------
    // Puente horizontal
    //--------------------------------------------------

    linear_extrude(2)

        square(
        [
            um790_mount_spacing_x,
            base_bridge_width
        ],
        center=true);



    //--------------------------------------------------
    // Puente vertical
    //--------------------------------------------------

    linear_extrude(2)

        square(
        [
            base_bridge_width,
            um790_mount_spacing_y
        ],
        center=true);

}

}



//==========================================================
// PREVIEW
//==========================================================

base();
