//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — pieza EXTRAÍBLE/intercambiable, fijada por imanes
// (docs/02_Mechanical_Layout.md, sección 6: "Panel NFC: Imanes.").
// Sustituye a front_panel.scad/front_layout.scad (obsoletos).
//
// Ocupa prácticamente todo el ancho frontal (docs/02_Mechanical_Layout.md,
// sección 3: "Panel NFC: Ocupará prácticamente todo el ancho
// frontal."), con el borde llegando exactamente a la cara interior de
// las paredes laterales, donde están embebidos los imanes
// (openscad/parts/02_chassis/walls.scad, frontMagnetCuts()).
//
// Lleva la ventana/alojamiento del tag NFC, centrada, a media altura
// del panel — el RC522 queda detrás, sujeto al bastidor (no a este
// panel), separado 3 mm (ya verificado, ver
// docs/03_Virtual_Assembly_Report.md).
//
// Sistema de coordenadas: igual que assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del cascarón.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 48;

part_version = "1.0";


//=============================================================================
// PARÁMETROS DE ESTA PIEZA
//=============================================================================

nfc_tag_pocket_depth = 1.5;  // Dato real confirmado por el usuario (2026-08-03)
nfc_magnet_diameter  = magnet_diameter + magnet_clearance;


//=============================================================================
// PLACA MACIZA
//=============================================================================

module nfcPanelSolid()
{

    translate([
        -nfc_panel_width/2,
        -case_depth/2,
        nfc_panel_z_low
    ])

        cube([
            nfc_panel_width,
            front_panel_thickness,
            nfc_panel_height
        ]);

}


//=============================================================================
// VENTANA / ALOJAMIENTO DEL TAG NFC
//
// Hueco trasero (no pasante) para pegar el tag, centrado a media
// altura del panel — coincide con nfc_panel_z_mid
// (assembly_positions.scad), la misma referencia que usa el RC522.
//=============================================================================

module nfcTagPocket()
{

    translate([
        -nfc_window_width/2,
        -case_depth/2 + front_panel_thickness - nfc_tag_pocket_depth,
        nfc_panel_z_mid - nfc_window_height/2
    ])

        cube([
            nfc_window_width,
            nfc_tag_pocket_depth + 0.1,
            nfc_window_height
        ]);

}


//=============================================================================
// IMANES — ALOJAMIENTO CIEGO, SIN SOBRESALIR
//
// FALLO CORREGIDO (2026-08-03, tres rondas de aviso del usuario):
// primero una muesca cuadrada visible, luego un saliente redondo
// hacia el exterior (bulto), luego sin ningún alojamiento en
// absoluto ("no tiene encajes para los imanes") — ninguna de las
// tres era aceptable.
//
// El alojamiento del imán en la pared (walls.scad, frontMagnetCuts())
// se reculó 3 mm y se abre justo en la cara INTERIOR del panel
// (Y=-78,2), creciendo desde ahí hacia el interior de la pared. Si el
// alojamiento del panel TAMBIÉN creciera desde ese mismo punto hacia
// el interior, invadiría el mismo hueco que ya ocupa el imán de la
// pared — no pueden compartir el mismo espacio. Por eso el
// alojamiento del panel tiene que quedarse DENTRO de su propio
// grosor (Y -81,2 a -78,2), sin sobresalir por detrás.
//
// Con eso, un imán del grosor estándar del proyecto (magnet_height =
// 3 mm, igual que el grosor del panel) no cabe con piel delante — el
// alojamiento aquí es más fino (nfc_magnet_pocket_depth = 1,5 mm),
// pensado para una arandela de acero o un imán delgado, no el imán
// de 3 mm usado en la pared. Deja 1,5 mm de piel sólida por delante,
// oculta desde fuera.
//
// PENDIENTE DE CONFIRMAR: el grosor real de la arandela/imán que se
// vaya a usar aquí — 1,5 mm es una estimación con margen razonable,
// no una medida real confirmada.
//=============================================================================

nfc_magnet_z_low  = nfc_panel_z_low  + 15;
nfc_magnet_z_high = nfc_panel_z_high - 15;

nfc_magnet_pocket_depth    = 1.5;  // ESTIMADO — pendiente de confirmar el grosor real de la arandela/imán
nfc_magnet_pocket_diameter = magnet_diameter + magnet_clearance;

// FALLO CORREGIDO (2026-08-03, captura del usuario): la X se copiaba
// directamente de sideMountGlobalX(), la misma fórmula que usa la
// pared — válida ahí porque la pared llega hasta X=78, pero el panel
// NFC solo llega hasta X=nfc_panel_width/2=75. Con esa X (72,925) el
// alojamiento se salía 2 mm por el borde del panel. Ahora se calcula
// con margen respecto al borde REAL del panel, no respecto al de la
// pared — coincide de forma aproximada, no exacta, con el imán de la
// pared (unos 3 mm de diferencia en X), inevitable si el alojamiento
// tiene que caber entero dentro del panel.
nfc_magnet_edge_margin = 1.5;

module nfcMagnetPockets()
{

    magnetX = nfc_panel_width/2 - nfc_magnet_edge_margin - nfc_magnet_pocket_diameter/2;

    for(ix=[-1,1])
    for(z=[nfc_magnet_z_low, nfc_magnet_z_high])

        translate([
            ix*magnetX,
            -case_depth/2 + front_panel_thickness - nfc_magnet_pocket_depth,
            z
        ])

            rotate([-90,0,0])
                cylinder(d = nfc_magnet_pocket_diameter, h = nfc_magnet_pocket_depth + 0.1);

}


//=============================================================================
// PANEL NFC COMPLETO
//=============================================================================

module nfcPanel()
{

    difference()
    {

        nfcPanelSolid();

        nfcTagPocket();

        nfcMagnetPockets();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color([0.1,0.1,0.1,1])
    nfcPanel();
