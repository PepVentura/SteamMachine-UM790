//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : ribs.scad
// Versión : 5.0
//
// Nervios estructurales V5
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// NERVIO HORIZONTAL
//=============================================================================

module rib_x(len)
{
    translate([-len/2,-rib_width/2,0])

        cube(
        [
            len,
            rib_width,
            rib_height
        ]);
}



//=============================================================================
// NERVIO VERTICAL
//=============================================================================

module rib_y(len)
{
    translate([-rib_width/2,-len/2,0])

        cube(
        [
            rib_width,
            len,
            rib_height
        ]);
}



//=============================================================================
// NERVIO DIAGONAL
//=============================================================================

module rib_diag(x1,y1,x2,y2)
{

    dx=x2-x1;
    dy=y2-y1;

    L=sqrt(dx*dx+dy*dy);

    A=atan2(dy,dx);

    translate([x1,y1,0])

        rotate([0,0,A])

            cube(
            [
                L,
                rib_width,
                rib_height
            ]);

}



//=============================================================================
// BASTIDOR INTERIOR
//=============================================================================

module inner_frame()
{

    translate([0, off_y,0])
        rib_x(um790_mount_spacing_x);

    translate([0,-off_y,0])
        rib_x(um790_mount_spacing_x);

    translate([ off_x,0,0])
        rib_y(um790_mount_spacing_y);

    translate([-off_x,0,0])
        rib_y(um790_mount_spacing_y);

}



//=============================================================================
// CRUCETA CENTRAL
//=============================================================================

module center_cross()
{

    rib_x(um790_mount_spacing_x);

    rib_y(um790_mount_spacing_y);

}



//=============================================================================
// DIAGONALES ENTRE POSTES
//=============================================================================

module diagonals()
{

    rib_diag(
        -off_x,
        -off_y,
         off_x,
         off_y);

    rib_diag(
        -off_x,
         off_y,
         off_x,
        -off_y);

}



//=============================================================================
// REFUERZOS EXTERIORES
//=============================================================================

module outer_frame()
{

    m=base_frame_width+5;

    translate([0, tray_depth/2-m,0])
        rib_x(tray_width-2*m);

    translate([0,-tray_depth/2+m,0])
        rib_x(tray_width-2*m);

    translate([ tray_width/2-m,0,0])
        rib_y(tray_depth-2*m);

    translate([-tray_width/2+m,0,0])
        rib_y(tray_depth-2*m);

}



//=============================================================================
// RIBS
//=============================================================================

module ribs()
{

    union()
    {

        outer_frame();

        inner_frame();

        center_cross();

        diagonals();

    }

}



//=============================================================================
// PREVIEW
//=============================================================================

ribs();
