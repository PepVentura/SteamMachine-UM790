//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// front_layout.scad
//
// Plano de distribución del frontal.
// NO es una pieza imprimible.
//
// ⚠️ OBSOLETO (2026-08-03) — sustituido por:
//   - openscad/reference/front_panel_view.scad (alzado 2D con las
//     posiciones ya validadas y verificadas)
//   - openscad/parts/03_panels/lower_panel.scad y nfc_panel.scad
//     (piezas imprimibles reales)
//
// Las posiciones de este archivo (USB de Ø12 mm a modo de boceto,
// panel NFC de 70 mm de ancho) quedaron desactualizadas tras el
// ensamblaje virtual v1 — ver docs/03_Virtual_Assembly_Report.md. Se
// conserva sin borrar como referencia histórica.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn=48;

//============================================================
// DIMENSIONES
//============================================================

panel_w = case_width;
panel_h = case_height;

//============================================================
// PANEL NFC
//============================================================

nfc_w = nfc_panel_width;
nfc_h = nfc_panel_height;

nfc_x = (panel_w-nfc_w)/2;
nfc_y = panel_h-12-nfc_h;

//============================================================
// BARRA LED
//============================================================

led_margin = 8;

led_w = panel_w-led_margin*2;
led_h = led_bar_height;

led_x = led_margin;
led_y = nfc_y-10-led_h;

//============================================================
// MÓDULO USB
//============================================================

usb_module_w = 70;
usb_module_h = 35;

usb_module_x = panel_w-usb_module_w-12;
usb_module_y = 12;

//============================================================
// PULSADOR
//============================================================

button_d = 16;

button_x = 24;
button_y = usb_module_y+usb_module_h/2;

//============================================================
// OLED
//============================================================

oled_size = 27;

oled_x = (panel_w-oled_size)/2;
oled_y = usb_module_y+2;

//============================================================
// PANEL EXTERIOR
//============================================================

color([0.15,0.15,0.15])

translate([0,0,-2])

cube(
[
panel_w,
panel_h,
2
]);

//============================================================
// PANEL NFC
//============================================================

color("RoyalBlue")

translate(
[
nfc_x,
nfc_y,
0
])

cube(
[
nfc_w,
nfc_h,
2
]);

//============================================================
// BARRA LED
//============================================================

color("White")

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
2
]);

//============================================================
// USB MODULE
//============================================================

color("Orange")

translate(
[
usb_module_x,
usb_module_y,
0
])

cube(
[
usb_module_w,
usb_module_h,
2
]);

//============================================================
// USB VISIBLES
//============================================================

usb_d = 12;
usb_sep = 18;

color("Silver")

translate(
[
usb_module_x+20,
usb_module_y+usb_module_h/2,
2
])

cylinder(
d=usb_d,
h=2
);

translate(
[
usb_module_x+20+usb_sep,
usb_module_y+usb_module_h/2,
2
])

cylinder(
d=usb_d,
h=2
);

//============================================================
// PULSADOR
//============================================================

color("Red")

translate(
[
button_x,
button_y,
2
])

cylinder(
d=button_d,
h=2
);

//============================================================
// OLED
//============================================================

color("DarkSlateGray")

translate(
[
oled_x,
oled_y,
2
])

cube(
[
oled_size,
oled_size,
2
]);

echo("===============");
echo("SteamMachine UM790");
echo("Front Layout V1");
echo("===============");
