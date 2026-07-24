//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo    : base.scad
// Versión    : 1.0
//
// Base estructural de la bandeja.
//
// Esta pieza genera únicamente el marco estructural principal.
// Los postes, nervios, guías y soportes se añadirán desde módulos
// independientes.
//
// ============================================================================


//=============================================================================
// INCLUDES
//=============================================================================

include <../../../00_parametros.scad>;
include <../../lib/shapes.scad>;


//=============================================================================
// BASE
//=============================================================================

module base()
{

    frame(
        width      = tray_width,
        depth      = tray_depth,
        border     = base_frame_width,
        thickness  = tray_thickness,
        center     = true
    );

}


//=============================================================================
// PREVIEW
//=============================================================================

SHOW_BASE = true;

if (SHOW_BASE)
{
    color([0.80,0.80,0.82])
        base();
}
