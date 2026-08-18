//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// front_panel.scad
// PARTE 1
//
// ⚠️ OBSOLETO (2026-08-03) — sustituido por:
//   - openscad/parts/03_panels/lower_panel.scad (pulsador, OLED, USB
//     doble, barra LED — panel inferior fijo)
//   - openscad/parts/03_panels/nfc_panel.scad (panel NFC extraíble)
//
// Este archivo combinaba en una sola pieza lo que el ensamblaje
// virtual v1 (docs/03_Virtual_Assembly_Report.md) determinó que
// deben ser DOS piezas separadas (una fija atornillada, otra
// extraíble magnética), y no incluía el USB frontal ni reflejaba las
// posiciones y tamaños ya validados (panel inferior mínimo, NFC
// máximo, USB doble real). Se conserva sin borrar como referencia
// histórica, pero no debe usarse para imprimir.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;

//------------------------------------------------------------
// Parámetros
//------------------------------------------------------------

panel_w = case_width;
panel_h = case_height;
panel_t = front_panel_thickness;

corner_r = 6;

//------------------------------------------------------------
// Posiciones
//------------------------------------------------------------

// Panel NFC

nfc_w = nfc_panel_width;
nfc_h = nfc_panel_height;

nfc_x = (panel_w-nfc_w)/2;
nfc_y = panel_h-15-nfc_h;


// Barra LED

led_margin = 8;

led_w = panel_w-led_margin*2;
led_h = led_bar_height;

led_x = led_margin;
led_y = nfc_y-14;


// Pulsador

button_d = 16;

button_x = 24;
button_y = 26;


// OLED

oled_size = 27;

oled_x = (panel_w-oled_size)/2;
oled_y = 10;


//------------------------------------------------------------
// Panel principal
//------------------------------------------------------------

module front_panel()
{

    difference()
    {

        // Panel exterior

        minkowski()
        {

            cube(
            [
                panel_w-corner_r*2,
                panel_h-corner_r*2,
                panel_t
            ]);

            cylinder(
                r=corner_r,
                h=0.01
            );

        }

        //----------------------------------------------------
        // Hueco NFC
        //----------------------------------------------------

        translate(
        [
            nfc_x,
            nfc_y,
            -1
        ])

        cube(
        [
            nfc_w,
            nfc_h,
            panel_t+2
        ]);


        //----------------------------------------------------
        // Hueco OLED
        //----------------------------------------------------

        translate(
        [
            oled_x,
            oled_y,
            -1
        ])

        cube(
        [
            oled_size,
            oled_size,
            panel_t+2
        ]);


        //----------------------------------------------------
        // Hueco pulsador
        //----------------------------------------------------

        translate(
        [
            button_x,
            button_y,
            -1
        ])

        cylinder(
            d=button_d,
            h=panel_t+2
        );

    }

}


//------------------------------------------------------------
// Barra LED (pieza de doble color)
//------------------------------------------------------------

module led_diffuser()
{

    translate(
    [
        led_x,
        led_y,
        0
    ])

    cube(
    [
        led_w,
        led_h,
        panel_t
    ]);

}


//------------------------------------------------------------
// Vista previa
//------------------------------------------------------------

color("Black")
front_panel();

color([1,1,1,0.8])
led_diffuser();
