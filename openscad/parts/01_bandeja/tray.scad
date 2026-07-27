//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : tray.scad
// Bandeja estructural definitiva
//
// ============================================================================

include <../../00_parametros.scad>;
use <posts.scad>;
use <ribs.scad>;

$fn = 64;

//------------------------------------------------------------
// Base con esquinas redondeadas
//------------------------------------------------------------

module tray_base()
{
    linear_extrude(height = tray_thickness)

    hull()
    {
        translate([-(tray_width/2)+6, -(tray_depth/2)+6])
            circle(r=6);

        translate([(tray_width/2)-6, -(tray_depth/2)+6])
            circle(r=6);

        translate([-(tray_width/2)+6, (tray_depth/2)-6])
            circle(r=6);

        translate([(tray_width/2)-6, (tray_depth/2)-6])
            circle(r=6);
    }
}

//------------------------------------------------------------
// Ventana central
//------------------------------------------------------------

module tray_window()
{
    linear_extrude(height = tray_thickness + 0.5)

    hull()
    {
        translate([-35,-25]) circle(r=6);
        translate([ 35,-25]) circle(r=6);
        translate([-35, 25]) circle(r=6);
        translate([ 35, 25]) circle(r=6);
    }
}

//------------------------------------------------------------
// Bandeja completa
//------------------------------------------------------------

module tray()
{

    difference()
    {
        tray_base();

        translate([0,0,-0.2])
            tray_window();
    }

    // Postes UM790
    translate([0,0,tray_thickness])
        posts();

    // Nervios
    translate([0,0,tray_thickness])
        ribs();

}

tray();
