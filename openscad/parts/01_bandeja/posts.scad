//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : posts.scad
// Versión : 2.0
//
// Postes de fijación de la placa Minisforum UM790 PRO
//
// ============================================================================

include <../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// POSTE INDIVIDUAL
//=============================================================================

module post()
{

    difference()
    {

        // Poste exterior
        cylinder(
            d = standoff_dia,
            h = standoff_height);

        // Alojamiento inserto M3
        translate(
            [0,0,
             standoff_height-insert_depth])

            cylinder(
                d = insert_dia,
                h = insert_depth + 0.20);

    }

}



//=============================================================================
// MATRIZ DE POSTES UM790
//=============================================================================

module posts()
{

    positions =
    [

        [-off_x,-off_y],

        [ off_x,-off_y],

        [-off_x, off_y],

        [ off_x, off_y]

    ];


    for(p = positions)
    {

        translate(
        [
            p[0],
            p[1],
            0
        ])

        post();

    }

}



//=============================================================================
// PREVISUALIZACIÓN
//=============================================================================
//
// Permite abrir directamente este archivo
// para comprobar únicamente los postes.
//
// En tray.scad se llamará igualmente
// mediante:
//
//     posts();
//
//=============================================================================

posts();
