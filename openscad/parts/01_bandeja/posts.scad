//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : posts.scad
// Versión : 2.0
//
// Postes de fijación de la placa UM790 PRO
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// POSTE INDIVIDUAL
//=============================================================================

module post()
{
    difference()
    {
        cylinder(
            h = standoff_height,
            d = standoff_dia
        );

        translate([0,0,standoff_height-insert_depth])
            cylinder(
                h = insert_depth+0.10,
                d = insert_dia
            );
    }
}


//=============================================================================
// MATRIZ DE POSTES
//=============================================================================

module posts()
{

    translate([-off_x,-off_y,0])
        post();

    translate([ off_x,-off_y,0])
        post();

    translate([-off_x, off_y,0])
        post();

    translate([ off_x, off_y,0])
        post();

}


//=============================================================================
// PREVIEW
//=============================================================================

if ($preview)
{

    color("orange")
        posts();

}
