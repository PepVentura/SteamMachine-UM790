//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : oled_bracket.scad
// Versión  : 1.0
// Fecha    : 2026-08-22
// Autor    : Pep Ventura (asistido por Claude)
//
// Brida de sujeción de la OLED — pieza NUEVA, separada del panel
// inferior. PEDIDO POR EL USUARIO: fijación robusta y visible para la
// pantalla, en vez de pegamento — inspirado en
// https://www.thingiverse.com/thing:7296586 (carcasa + 2 insertos
// M2x2,5x3,2 + 2 tornillos M2x3, que sujeta el módulo por detrás).
//
// Se atornilla en los dos bosses de lower_panel.scad
// (oledInsertBosses(), coordenadas en oled_bracket_screw_positions,
// assembly_positions.scad), presionando el módulo OLED contra la cara
// interior del panel — el módulo queda atrapado entre la brida y el
// panel, sin pegamento.
//
// Hueco central amplio: no debe tapar ni la pantalla visible
// (oled_screen_width/height) ni el rebaje de los pines por encima.
//
// Sistema de coordenadas: igual que assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del cascarón.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// PLACA — cubre el módulo OLED (27x27mm) y llega hasta los bosses,
// que ahora están a los lados de la pantalla (ver
// oled_bracket_boss_x_offset en assembly_positions.scad)
//=============================================================================

oled_bracket_edge_margin = 1.0;   // ESTIMADO — margen entre el borde del boss y el borde exterior de la brida
oled_bracket_thickness   = 2.5;   // ESTIMADO — grosor de la brida
oled_bracket_v_margin    = 3.0;   // margen vertical respecto al módulo (27mm de alto), a cada lado

oled_bracket_width  = 2*(oled_bracket_boss_x_offset + oled_bracket_boss_diameter/2 + oled_bracket_edge_margin);
oled_bracket_height = oled_module_height + 2*oled_bracket_v_margin;

// Y: se apoya directamente contra el respaldo del boss (donde termina
// el propio boss, oled_bracket_boss_length desde la cara interior del
// panel) — mismo criterio que cualquier tornillo que aprieta contra
// un tope.
oled_bracket_y = -case_depth/2 + front_panel_thickness + oled_bracket_boss_length;

module oledBracketPlate()
{

    translate([
        oled_pos[0] - oled_bracket_width/2,
        oled_bracket_y,
        oled_pos[2] - oled_bracket_height/2
    ])

        cube([oled_bracket_width, oled_bracket_thickness, oled_bracket_height]);

}


//=============================================================================
// HUECO CENTRAL — no debe tapar la pantalla ni el rebaje de los pines
//
// COMPROBADO NUMÉRICAMENTE (2026-08-22): con los bosses ahora a los
// LADOS de la pantalla (no en las esquinas inferiores), el margen de
// la ventana ya no compite por el mismo espacio — el hueco puede
// mantener el margen de alineación sin solapar los tornillos.
//=============================================================================

oled_bracket_window_margin = 1.0;  // ESTIMADO (reducido de 1,5 a 1,0 — comprobado numéricamente para dejar hueco libre a los bosses, ahora a los lados de la pantalla)

module oledBracketWindowCut()
{

    windowWidth  = oled_screen_width  + 2*oled_bracket_window_margin;
    windowHeight = oled_screen_height + oled_pin_clearance_height + 2*oled_bracket_window_margin;

    translate([
        oled_pos[0] - windowWidth/2,
        oled_bracket_y - 0.1,
        oled_pos[2] - oled_screen_height/2 - oled_bracket_window_margin
    ])

        cube([windowWidth, oled_bracket_thickness+0.2, windowHeight]);

}


//=============================================================================
// TALADROS DE PASO PARA LOS TORNILLOS M2
//=============================================================================

oled_bracket_screw_clearance = 2.4;  // holgura estándar para M2

module oledBracketScrewHoles()
{

    for (p = oled_bracket_screw_positions)

        translate([p[0], oled_bracket_y-0.1, p[1]])
            rotate([-90,0,0])
                cylinder(d = oled_bracket_screw_clearance, h = oled_bracket_thickness+0.2);

}


//=============================================================================
// PIEZA COMPLETA
//=============================================================================

module oledBracket()
{

    difference()
    {
        oledBracketPlate();
        oledBracketWindowCut();
        oledBracketScrewHoles();
    }

}


//=============================================================================
// PREVIEW
//=============================================================================

oledBracket();
