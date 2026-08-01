//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : front_panel.scad
// Versión : 1.0
//
// PANEL FRONTAL
//
// PARTE 1
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;

//=============================================================================
// PARÁMETROS
//=============================================================================

front_width = case_width;

front_height = case_height;

front_thickness = front_panel_thickness;

corner_radius = 6;

// Margen general

front_margin = 8;


//=============================================================================
// POSICIONES
//=============================================================================

// Panel NFC

nfc_x = (front_width-nfc_panel_width)/2;

nfc_y = front_height-15-nfc_panel_height;


// Barra LED

led_x = front_margin;

led_y = nfc_y-14;

led_width = front_width-front_margin*2;


// Pulsador

button_x = 22;

button_y = 26;


// OLED

oled_x = (front_width-27)/2;

oled_y = 10;


//=============================================================================
// PANEL BASE
//=============================================================================

module front_plate()
{

    difference()
    {

        minkowski()
        {

            cube(
            [
                front_width-corner_radius*2,
                front_height-corner_radius*2,
                front_thickness
            ]);

            cylinder(
                r=corner_radius,
                h=0.01
            );

        }

        //-------------------------------------------------------------
        // Hueco panel NFC
        //-------------------------------------------------------------

        translate(
        [
            nfc_x,
            nfc_y,
            -1
        ])

        cube(
        [
            nfc_panel_width,
            nfc_panel_height,
            front_thickness+2
        ]);


        //-------------------------------------------------------------
        // Ventana OLED
        //-------------------------------------------------------------

        translate(
        [
            oled_x,
            oled_y,
            -1
        ])

        cube(
        [
            27,
            27,
            front_thickness+2
        ]);


        //-------------------------------------------------------------
        // Pulsador
        //-------------------------------------------------------------

        translate(
        [
            button_x,
            button_y,
            -1
        ])

        cylinder(
            d=16,
            h=front_thickness+2
        );

    }

}


//=============================================================================
// DIFUSOR LED
//=============================================================================

module led_window()
{

    translate(
    [
        led_x,
        led_y,
        0
    ])

    cube(
    [
        led_width,
        led_bar_height,
        front_thickness
    );

}


//=============================================================================
// CANAL POSTERIOR PARA LA TIRA LED
//=============================================================================

module led_channel()
{

    translate(
    [
        led_x,
        led_y,
        front_thickness
    ])

    difference()
    {

        cube(
        [
            led_width,
            led_bar_height,
            5
        ]);

        translate(
        [
            1.5,
            1,
            1
        ])

        cube(
        [
            led_width-3,
            led_bar_height-2,
            5
        ]);

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

front_plate();

color("White")
led_window();

color("Gray")
led_channel();
