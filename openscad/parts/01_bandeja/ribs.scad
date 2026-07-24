//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo    : ribs.scad
// Versión    : 1.0
//
// Nervios estructurales de la bandeja.
//
// ============================================================================


//=============================================================================
// INCLUDES
//=============================================================================

include <../../../00_parametros.scad>;


//=============================================================================
// PARÁMETROS (añadir a 00_parametros.scad si aún no existen)
//=============================================================================
//
// rib_width  = 3.0;
// rib_height = 5.0;
//


//=============================================================================
// NERVIO HORIZONTAL
//=============================================================================

module rib_x(length)
{
    cube(
    [
        length,
        rib_width,
        rib_height
    ]);
}


//=============================================================================
// NERVIO VERTICAL
//=============================================================================

module rib_y(length)
{
    cube(
    [
        rib_width,
        length,
        rib_height
    ]);
}


//=============================================================================
// CONJUNTO DE NERVIOS
//=============================================================================

module ribs()
{

    sx = um790_mount_spacing_x/2;
    sy = um790_mount_spacing_y/2;

    //
    // Dos nervios horizontales
    //

    translate(
    [
        -sx,
        -sy-rib_width/2,
        0
    ])
        rib_x(um790_mount_spacing_x);

    translate(
    [
        -sx,
        sy-rib_width/2,
        0
    ])
        rib_x(um790_mount_spacing_x);

    //
    // Dos nervios verticales
    //

    translate(
    [
        -sx-rib_width/2,
        -sy,
        0
    ])
        rib_y(um790_mount_spacing_y);

    translate(
    [
        sx-rib_width/2,
        -sy,
        0
    ])
        rib_y(um790_mount_spacing_y);

    //
    // Nervio central longitudinal
    //

    translate(
    [
        -sx,
        -rib_width/2,
        0
    ])
        rib_x(um790_mount_spacing_x);

    //
    // Nervio central transversal
    //

    translate(
    [
        -rib_width/2,
        -sy,
        0
    ])
        rib_y(um790_mount_spacing_y);

}


//=============================================================================
// PREVIEW
//=============================================================================

SHOW_RIBS = true;

if (SHOW_RIBS)
{

    color("DodgerBlue")

        ribs();

}
