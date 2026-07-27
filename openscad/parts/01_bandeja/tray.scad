//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : tray.scad
// Versión : 2.0
//
// Bandeja estructural definitiva
//
// ============================================================================

include <../../00_parametros.scad>;

use <posts.scad>;
use <ribs.scad>;

$fn = 64;


//=============================================================================
// BASE REDONDEADA
//=============================================================================

module tray_base()
{

    linear_extrude(height = tray_thickness)

        hull()
        {

            translate(
            [
                -tray_width/2 + 6,
                -tray_depth/2 + 6
            ])
            circle(r=6);

            translate(
            [
                 tray_width/2 - 6,
                -tray_depth/2 + 6
            ])
            circle(r=6);

            translate(
            [
                -tray_width/2 + 6,
                 tray_depth/2 - 6
            ])
            circle(r=6);

            translate(
            [
                 tray_width/2 - 6,
                 tray_depth/2 - 6
            ])
            circle(r=6);

        }

}



//=============================================================================
// VENTANA CENTRAL
//=============================================================================

module ventilation_window()
{

    linear_extrude(height = tray_thickness + 0.5)

        hull()
        {

            translate([-35,-25]) circle(r=6);
            translate([ 35,-25]) circle(r=6);
            translate([-35, 25]) circle(r=6);
            translate([ 35, 25]) circle(r=6);

        }

}



//=============================================================================
// TALADROS DE FIJACIÓN AL CHASIS
//=============================================================================

module chassis_holes()
{

    hole_d = 3.4;

    positions =
    [

        [-60,-60],
        [ 60,-60],
        [-60, 60],
        [ 60, 60]

    ];

    for(p = positions)
    {

        translate(
        [
            p[0],
            p[1],
            -0.2
        ])

        cylinder(
            d = hole_d,
            h = tray_thickness + 0.4);

    }

}



//=============================================================================
// BANDEJA COMPLETA
//=============================================================================

module tray()
{

    difference()
    {

        tray_base();

        ventilation_window();

        chassis_holes();

    }


    //-----------------------------------------------------------------
    // Postes UM790
    //-----------------------------------------------------------------

    translate(
    [
        0,
        0,
        tray_thickness
    ])

    posts();


    //-----------------------------------------------------------------
    // Nervios
    //-----------------------------------------------------------------

    translate(
    [
        0,
        0,
        tray_thickness
    ])

    ribs();

}



//=============================================================================
// PREVISUALIZACIÓN
//=============================================================================

tray();
