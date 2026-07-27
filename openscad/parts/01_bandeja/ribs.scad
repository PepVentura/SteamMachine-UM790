//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : ribs.scad
// Versión : 2.0
//
// Nervios estructurales de la bandeja.
//
// ============================================================================

include <../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// NERVIO HORIZONTAL
//=============================================================================

module horizontal_rib(y_pos)
{
    translate(
    [
        -(um790_mount_spacing_x/2),
        y_pos - (rib_width/2),
        0
    ])

    cube(
    [
        um790_mount_spacing_x,
        rib_width,
        rib_height
    ]);
}


//=============================================================================
// NERVIO VERTICAL
//=============================================================================

module vertical_rib(x_pos)
{
    translate(
    [
        x_pos - (rib_width/2),
        -(um790_mount_spacing_y/2),
        0
    ])

    cube(
    [
        rib_width,
        um790_mount_spacing_y,
        rib_height
    ]);
}


//=============================================================================
// CONJUNTO DE NERVIOS
//=============================================================================

module ribs()
{

    // Horizontales

    horizontal_rib(-20);
    horizontal_rib( 20);

    // Verticales

    vertical_rib(-25);
    vertical_rib( 25);

}


//=============================================================================
// PREVISUALIZACIÓN
//=============================================================================

ribs();
