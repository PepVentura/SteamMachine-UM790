//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel_blank.scad
// Versión  : 1.2
// Fecha    : 2026-08-19
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — SIN NINGÚN LOGO. Reutiliza la base compartida de
// nfc_panel.scad (nfcPanelBase(): sólido, marco, ventana del tag,
// imanes) tal cual, sin añadir ninguna marca — pedido original del
// usuario para poner su propio diseño directamente desde Anycubic
// Slicer (p. ej. con una imagen/textura aplicada en el propio
// laminador).
//
// PEDIDO POR EL USUARIO (2026-08-19): "Nfc panel blank tiene un
// dibujo que no debería estar" — el logo de TeknoParrot que se
// integró aquí el 2026-08-17 (a petición del usuario en su momento)
// se ha quitado, volviendo el archivo a su estado en blanco
// original. Si se quiere ese logo en un panel, sigue disponible tal
// cual en openscad/parts/03_panels/nfc_panel_teknoparrot.scad.
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
