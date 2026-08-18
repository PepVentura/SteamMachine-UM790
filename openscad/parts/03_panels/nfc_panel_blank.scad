//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel_blank.scad
// Versión  : 1.0
// Fecha    : 2026-08-14
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — SIN NINGÚN LOGO. Reutiliza la base compartida de
// nfc_panel.scad (nfcPanelBase(): sólido, marco, ventana del tag,
// imanes) tal cual, sin añadir ninguna marca — pedido del usuario
// para poner su propio diseño directamente desde Anycubic Slicer
// (p. ej. con una imagen/textura aplicada en el propio laminador).
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

use <nfc_panel.scad>;

$fn = 64;

//=============================================================================
// PREVIEW
//=============================================================================

color([0.1,0.1,0.1,1])
    nfcPanelBase();
