//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : usb_front.scad
// Versión  : 2.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia del conector USB empotrable frontal
// para el ensamblaje virtual v1.
//
// v2.0 — Sustituye el diseño anterior (dos unidades independientes)
// por una única unidad de DOBLE puerto USB-A en un solo cuerpo
// roscado, conectada al HUB mediante dos cables flexibles con
// conector USB-A macho (componente real localizado por el usuario).
// Un solo orificio en el panel en vez de dos.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro de la brida, cara frontal (apoya sobre
//                     el panel).
//   +Z = hacia el interior del chasis (cuerpo rígido roscado, luego
//        cable flexible). Se usa +Z, no +Y, para que los cilindros
//        se extruyan de forma natural; el ensamblaje
//        (virtual_assembly_v1.scad) rota este módulo 90º sobre X al
//        montarlo en el panel frontal.
//
// IMPORTANTE — el cable (usbFrontCableKeepout) es FLEXIBLE: se
// modela como volumen de seguridad recto solo a efectos de
// visualización y de una comprobación orientativa, pero en el
// montaje real puede curvarse para esquivar otros componentes. Una
// intersección con el cable es un aviso a revisar, no una colisión
// mecánica dura como con el cuerpo rígido.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 32;

part_version = "2.0";


//=============================================================================
// COLORES
//=============================================================================

usbFrontFlangeColor = [0.75,0.75,0.75,1.0];
usbFrontBodyColor   = [0.15,0.15,0.15,1.0];
usbFrontCableColor  = [1.00,0.65,0.00,0.15];


//=============================================================================
// BRIDA (apoyada en la cara exterior del panel)
//=============================================================================

module usbFrontFlange(flangeThickness = 3)
{

    color(usbFrontFlangeColor)

        cylinder(
            d = usb_front_flange_diameter,
            h = flangeThickness
        );

}


//=============================================================================
// CUERPO RÍGIDO (rosca + fuelle corrugado)
//=============================================================================

module usbFrontRigidBody(flangeThickness = 3)
{

    color(usbFrontBodyColor)

    translate([0,0,flangeThickness])

        cylinder(
            d = usb_front_hole_diameter,
            h = usb_front_body_length
        );

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module usbFrontBody()
{

    union()
    {
        usbFrontFlange();
        usbFrontRigidBody();
    }

}


//=============================================================================
// CABLE FLEXIBLE HACIA EL HUB (volumen de seguridad, NO rígido)
//
// Se representan los dos cables como dos cilindros finos, rectos a
// efectos de este ensamblaje de referencia. En el montaje real
// pueden curvarse; cualquier aviso de intersección aquí es orientativo.
//=============================================================================

module usbFrontCableKeepout(flangeThickness = 3)
{

    color(usbFrontCableColor)

    for(ix=[-1,1])

        translate([
            ix*usb_front_cable_diameter*0.7,
            0,
            flangeThickness + usb_front_body_length
        ])

            cylinder(
                d = usb_front_cable_diameter,
                h = usb_front_cable_length
            );

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module usbFront()
{

    usbFrontBody();

    usbFrontCableKeepout();

}


//=============================================================================
// PREVIEW
//=============================================================================

usbFront();
