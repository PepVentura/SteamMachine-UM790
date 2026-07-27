//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : ribs.scad
// Versión : 2.0
//
// Nervios estructurales de la bandeja
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// NERVIO HORIZONTAL
//=============================================================================

module rib_x(length)
{
    cube(
        [length, rib_width, rib_height],
        center = true
    );
}


//=============================================================================
// NERVIO VERTICAL
//=============================================================================

module rib_y(length)
{
    cube(
        [rib_width, length, rib_height],
        center = true
    );
}


//=============================================================================
// NERVIOS COMPLETOS
//=============================================================================

module ribs()
{

    //
    // Superior
    //
    translate(
        [
            0,
            tray_depth/2 - base_frame_width/2,
            tray_thickness
        ])
        rib_x(tray_width);


    //
    // Inferior
    //
    translate(
        [
            0,
            -tray_depth/2 + base_frame_width/2,
            tray_thickness
        ])
        rib_x(tray_width);


    //
    // Izquierdo
    //
    translate(
        [
            -tray_width/2 + base_frame_width/2,
            0,
            tray_thickness
        ])
        rib_y(tray_depth);


    //
    // Derecho
    //
    translate(
        [
            tray_width/2 - base_frame_width/2,
            0,
            tray_thickness
        ])
        rib_y(tray_depth);


    //
    // Refuerzo horizontal central
    //
    translate(
        [
            0,
            0,
            tray_thickness
        ])
        rib_x(hole_dist_x);


    //
    // Refuerzo vertical central
    //
    translate(
        [
            0,
            0,
            tray_thickness
        ])
        rib_y(hole_dist_y);


    //
    // Refuerzo superior postes
    //
    translate(
        [
            0,
            off_y,
            tray_thickness
        ])
        rib_x(hole_dist_x);


    //
    // Refuerzo inferior postes
    //
    translate(
        [
            0,
            -off_y,
            tray_thickness
        ])
        rib_x(hole_dist_x);


    //
    // Refuerzo izquierdo postes
    //
    translate(
        [
            -off_x,
            0,
            tray_thickness
        ])
        rib_y(hole_dist_y);


    //
    // Refuerzo derecho postes
    //
    translate(
        [
            off_x,
            0,
            tray_thickness
        ])
        rib_y(hole_dist_y);

}


//=============================================================================
// PREVIEW
//=============================================================================

if ($preview)
{
    color("RoyalBlue")
        ribs();
}
