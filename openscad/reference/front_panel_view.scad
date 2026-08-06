//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : front_panel_view.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Alzado frontal 2D del panel, generado por proyección plana de las
// posiciones ya validadas en virtual_assembly_v1.scad. Es una AYUDA
// VISUAL para revisar la disposición de agujeros/recortes, NO un
// plano acotado ni una pieza imprimible.
//
// Convención: se proyecta el ensamblaje 3D sobre el plano frontal
// (X = anchura, Z = altura), descartando la profundidad (Y).
//
// ============================================================================

include <../../00_parametros.scad>;
include <components/assembly_positions.scad>;

use <components/assembly_instances.scad>;

$fn = 48;


//=============================================================================
// SILUETA DEL PANEL (contorno exterior del frontal)
//=============================================================================

//=============================================================================
// ZONA DEL PANEL NFC (superior, intercambiable) — solo el contorno
//=============================================================================

module nfcZoneOutlineSolid(frame=2)
{
    translate([-nfc_panel_width/2, -1, nfc_panel_z_low])
    difference()
    {
        cube([nfc_panel_width,1,nfc_panel_height]);
        translate([frame,-1,frame])
            cube([nfc_panel_width-2*frame,3,nfc_panel_height-2*frame]);
    }
}


//=============================================================================
// SEPARACIÓN DE LOS TRES PANELES DEL FRONTAL
//
//   1. Panel inferior FIJO — aloja pulsador, OLED y USB doble. Tamaño
//      MÍNIMO imprescindible (petición del usuario).
//   2. Barra LED — se imprime EN LA MISMA PIEZA que el panel inferior,
//      con la Anycubic Kobra X en dos filamentos independientes (no es
//      una pieza separada, es una zona de color distinto en la misma
//      impresión). Altura real (led_bar_height).
//   3. Panel superior EXTRAÍBLE — aloja el tag NFC intercambiable.
//      Tamaño MÁXIMO posible (el resto del hueco disponible).
//
// Todas las cotas (front_panel_lower_top, front_panel_led_z_low/high)
// están ya calculadas en assembly_positions.scad — este archivo NO
// las recalcula, solo las dibuja, para no repetir la misma lógica en
// dos sitios (ver aviso de front_panel_zones_consistent más abajo).
//=============================================================================

module lowerPanelZoneSolid()
{
    translate([-case_width/2,-1,0])
        cube([case_width,1,front_panel_lower_top]);
}

module ledBarZoneSolid()
{
    translate([-case_width/2,-1,front_panel_led_z_low])
        cube([case_width,1,front_panel_led_z_high-front_panel_led_z_low]);
}

module nfcZoneFillSolid()
{
    translate([-case_width/2,-1,nfc_panel_z_low])
        cube([case_width,1,nfc_panel_z_high-nfc_panel_z_low]);
}

module upperMarginZoneSolid()
{
    translate([-case_width/2,-1,nfc_panel_z_high])
        cube([case_width,1,shell_height-nfc_panel_z_high]);
}


//=============================================================================
// ALZADO
//
// IMPORTANTE — orden de dibujado: las CUATRO zonas de color se pintan
// PRIMERO, opacas, cubriendo entre todas el panel completo (Z 0 a
// case_height). El contorno del panel, el marco NFC y los
// componentes se dibujan DESPUÉS, por encima. Si se invierte este
// orden, el contorno opaco tapa por completo las zonas de color
// (fallo del primer intento de esta vista).
//=============================================================================

module frontElevation()
{
    // Zona 1 — panel inferior fijo (pulsador, OLED, USB)
    color([0.60,0.78,0.90,1])
        projection(cut=false) rotate([-90,0,0]) lowerPanelZoneSolid();

    // Zona 2 — barra LED (MISMA pieza que la zona 1, 2º filamento)
    color([1.00,0.82,0.10,1])
        projection(cut=false) rotate([-90,0,0]) ledBarZoneSolid();

    // Zona 3 — panel NFC extraíble
    color([1.00,0.93,0.75,1])
        projection(cut=false) rotate([-90,0,0]) nfcZoneFillSolid();

    // Zona 4 — margen fijo del chasis (no es un panel)
    color([0.75,0.75,0.75,1])
        projection(cut=false) rotate([-90,0,0]) upperMarginZoneSolid();

    // Contorno exterior del panel, por encima de las zonas (solo el borde)
    color([0.3,0.3,0.3,1])
    {
        translate([-case_width/2,-2,0])           cube([case_width,0.1,0.6]);
        translate([-case_width/2,-2,shell_height-0.6]) cube([case_width,0.1,0.6]);
        translate([-case_width/2,-2,0])           cube([0.6,0.1,shell_height]);
        translate([case_width/2-0.6,-2,0])        cube([0.6,0.1,shell_height]);
    }

    // Marco del panel NFC (borde de la pieza extraíble)
    color([0.9,0.4,0.05,1])
        projection(cut=false) rotate([-90,0,0]) nfcZoneOutlineSolid();

    color([0.15,0.35,0.15,1])
        projection(cut=false) rotate([-90,0,0]) rc522InstanceBody();

    color([0.85,0.05,0.05,1])
        projection(cut=false) rotate([-90,0,0]) pushbuttonInstanceBody();

    color([0.05,0.05,0.4,1])
        projection(cut=false) rotate([-90,0,0]) oledInstanceBody();

    color([0.1,0.1,0.1,1])
        projection(cut=false) rotate([-90,0,0]) usbFrontInstanceBody();

    // Líneas divisorias entre las tres zonas
    color([0.1,0.1,0.1,1])
    {
        translate([-case_width/2,-2,front_panel_lower_top-0.3])
            cube([case_width,0.1,0.6]);
        translate([-case_width/2,-2,front_panel_led_z_high-0.3])
            cube([case_width,0.1,0.6]);
        translate([-case_width/2,-2,nfc_panel_z_high-0.3])
            cube([case_width,0.1,0.6]);
    }
}

frontElevation();

echo(str("Panel inferior fijo (MÍNIMO): Z 0 - ", front_panel_lower_top, " (", front_panel_lower_top, " mm alto)"));
echo(str("Barra LED (misma pieza, 2º filamento): Z ", front_panel_led_z_low, " - ", front_panel_led_z_high, " (", front_panel_led_z_high-front_panel_led_z_low, " mm alto)"));
echo(str("Panel NFC extraíble (MÁXIMO): Z ", nfc_panel_z_low, " - ", nfc_panel_z_high, " (", nfc_panel_height, " mm alto)"));
echo(str("Margen fijo superior del chasis: Z ", nfc_panel_z_high, " - ", shell_height, " (", shell_height-nfc_panel_z_high, " mm alto)"));
echo(front_panel_zones_consistent
    ? "OK: nfc_panel_height (00_parametros.scad) coincide con el cálculo de abajo hacia arriba."
    : "AVISO: nfc_panel_height (00_parametros.scad) NO coincide con el cálculo de abajo hacia arriba — revisar.");
