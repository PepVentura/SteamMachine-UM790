//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : tray.scad
// Versión : 8.0
//
// Ensamblaje completo de la bandeja estructural.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

use <base.scad>;
use <posts.scad>;
use <ribs.scad>;

$fn = 64;


//=============================================================================
// BANDEJA COMPLETA
//
// FALLO CORREGIDO (2026-08-03, petición del usuario de revisar la
// fijación del UM790): la bandeja se renderizaba en su propio origen
// local (Z=0, apoyada directamente en el suelo), pero en el
// ensamblaje real queda ELEVADA sobre los pilares de apoyo del suelo
// (openscad/parts/02_chassis/floor.scad, traySupportPosts()) — a
// z_chamber_top = 15 mm (ver openscad/reference/components/assembly_positions.scad).
// Todo el resto del ensamblaje (posición del UM790, del panel
// trasero, etc.) ya asumía esta elevación — solo faltaba
// materializarla aquí. Sin este ajuste, el hueco entre el conector
// del UM790 y el recorte del panel trasero no se puede verificar de
// verdad, porque la bandeja nunca ha estado en su sitio real.
//=============================================================================

module tray()
{

    translate([0, 0, z_chamber_top])

    union()
    {

        //---------------------------------------------------------------------
        // Base
        //---------------------------------------------------------------------

        base();


        //---------------------------------------------------------------------
        // Postes
        //---------------------------------------------------------------------

        translate([0,0,tray_thickness])
            posts();


        //---------------------------------------------------------------------
        // Nervios
        //---------------------------------------------------------------------

        ribs();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("LightGray")
    tray();
