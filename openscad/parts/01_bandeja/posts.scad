//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : posts.scad
// Versión : 8.0
//
// Postes de fijación UM790 Pro.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// POSTE M3
//=============================================================================

module post()
{

    difference()
    {

        //---------------------------------------------------------------------
        // Cuerpo del poste
        //---------------------------------------------------------------------

        cylinder(
            h = um790_post_height,
            d = um790_post_diameter
        );

        //---------------------------------------------------------------------
        // Alojamiento del inserto M3
        //---------------------------------------------------------------------

        translate([0,0,um790_post_height-insert_depth])

            cylinder(
                h = insert_depth + 0.10,
                d = insert_diameter
            );

    }

}


//=============================================================================
// CONJUNTO DE POSTES
//=============================================================================

// PEDIDO POR EL USUARIO (2026-08-03): "desplazar los pilares que
// sujetan el UM790 para aproximar esta al panel posterior" — la
// placa quedaba 21,45mm corta respecto al panel trasero (confirmado
// por el usuario con la placa real montada, ~2cm de hueco). Se
// desplazan los 4 postes hacia atrás (+Y) la misma cantidad,
// manteniendo intacta la separación entre ellos (viene fija por los
// agujeros reales de la placa, no se puede tocar). Deja ~3,45mm de
// hueco restante hasta el panel — razonable para tolerancia y el
// propio grosor de los conectores. (um790_post_y_offset definido en
// 00_parametros.scad, compartido con base.scad para las islas de
// apoyo y con assembly_positions.scad para um790_pos).

module posts()
{

    translate([ off_x,  off_y + um790_post_y_offset, 0]) post();

    translate([-off_x,  off_y + um790_post_y_offset, 0]) post();

    translate([-off_x, -off_y + um790_post_y_offset, 0]) post();

    translate([ off_x, -off_y + um790_post_y_offset, 0]) post();

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Orange")
posts();
