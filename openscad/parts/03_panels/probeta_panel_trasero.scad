//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : probeta_panel_trasero.scad
// Versión  : 1.0
// Fecha    : 2026-08-16
// Autor    : Pep Ventura (asistido por Claude)
//
// PROBETA DE PRUEBA — no es la pieza definitiva. Solo la franja con
// los 6 recortes de conectores (rearIOCut(), reutilizado tal cual del
// panel trasero real — así se garantiza que los recortes son
// EXACTAMENTE los mismos que llevará la pieza definitiva, no una
// aproximación aparte), sobre una placa mucho más pequeña que el
// panel completo (150mm de ancho).
//
// PEDIDO POR EL USUARIO (2026-08-16): "¿Podrías preparar este
// fichero pero para imprimir una prueba? [...] más estrecho y así
// verificamos las medidas en el chasis antes de imprimir el
// definitivo" — tras pasar las medidas reales del CAD de los
// conectores traseros.
//
// CÓMO USARLA: imprime esta pieza tal cual y pruébala contra la
// placa UM790 ya montada en el chasis — con las medidas reales del
// CAD debería alinear directamente con los conectores. Si algo no
// encaja, dímelo con la mayor precisión posible (qué conector, en
// qué dirección y cuánto) antes de dar la pieza definitiva por buena.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

use <rear_panel.scad>;

$fn = 32;

//=============================================================================
// PLACA DE LA PROBETA — ANCHO COMPLETO (extremo a extremo, igual que
// el panel real) para poder comprobar que el centrado coincide con
// las paredes reales del chasis, no solo las posiciones relativas
// entre conectores. Solo se recorta la ALTURA (mucho más baja que el
// panel completo), para que la pieza siga siendo rápida de imprimir.
//
// PEDIDO POR EL USUARIO (2026-08-16): "mejor que sea de extremo a
// extremo (derecha e izquierda), para verificar que esté bien
// centrado con las salidas reales del UM790" — versión anterior
// (119mm, solo el ancho de los conectores) sustituida por esta.
//
// AJUSTADO (2026-08-16, tras la prueba física): "la probeta del
// panel trasero también debería hacer 149mm de ancho" — mismo
// ajuste que el resto de paneles (rear_panel_width en
// rear_panel.scad), confirmado con la prueba real: encajaba bien
// ajustándolo desde la izquierda (lado USB), con sobrante por la
// derecha (lado DC) — coincide con el mismo 1mm de exceso ya
// corregido en los paneles frontales.
//=============================================================================

probeta_margin_z = 8;   // margen por encima/debajo del conector más alto/bajo

probeta_span_x = rear_panel_width;  // 149mm — mismo ancho que el panel trasero real (rear_panel.scad)
probeta_z_low  = 41.14 - probeta_margin_z;  // suelo del conector DC, con margen
probeta_z_high = 57.14 + probeta_margin_z;  // techo del USB/HDMI, con margen

module probetaPanelTrasero()
{

    difference()
    {

        translate([
            -probeta_span_x/2,
            case_depth/2 - wall_thickness,
            probeta_z_low
        ])

            cube([probeta_span_x, wall_thickness, probeta_z_high-probeta_z_low]);

        rearIOCut();

    }

}

probetaPanelTrasero();
