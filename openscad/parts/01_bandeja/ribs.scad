//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : ribs.scad
// Versión : 2.0
//
// Nervios estructurales
//
// ============================================================================

include <../../../00_parametros.scad>;


//=============================================================================
// NERVIO ENTRE DOS PUNTOS
//=============================================================================

module rib_between(p1, p2,
                   width  = rib_width,
                   height = rib_height)
{
    dx = p2[0] - p1[0];
    dy = p2[1] - p1[1];

    len = sqrt(dx*dx + dy*dy);

    angle = atan2(dy, dx);

    translate([p1[0], p1[1], 0])

        rotate([0,0,angle])

            cube(
            [
                len,
                width,
                height
            ]);
}


//=============================================================================
// ESTRUCTURA
//=============================================================================

module ribs()
{

    sx = um790_mount_spacing_x/2;
    sy = um790_mount_spacing_y/2;

    p1=[-sx,-sy];
    p2=[ sx,-sy];
    p3=[ sx, sy];
    p4=[-sx, sy];

    //
    // Marco principal
    //

    rib_between(p1,p2);
    rib_between(p2,p3);
    rib_between(p3,p4);
    rib_between(p4,p1);

    //
    // Cruz central
    //

    rib_between([-sx,0],[sx,0]);
    rib_between([0,-sy],[0,sy]);

    //
    // Diagonales
    //

    rib_between(p1,p3);
    rib_between(p2,p4);

}


//=============================================================================
// PREVIEW
//=============================================================================

SHOW_RIBS=true;

if(SHOW_RIBS)
{

    color("SteelBlue")

        ribs();

}
