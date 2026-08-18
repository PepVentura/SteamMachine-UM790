//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : hub_usb.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia del Hub USB CJMCU-204
// (44,1 x 44,1 x 12 mm) para el ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Modelo ya documentado en el proyecto (docs/COMPONENT_LIBRARY.md).
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro del hub en X/Y, cara inferior
//                     (plano de apoyo sobre la repisa de montaje).
//   +Z = hacia arriba.
//   +Y = lado de los conectores USB salientes (hacia el frontal).
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 24;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

hubBodyColor  = [0.20,0.20,0.20,1.0];
hubPortColor  = [0.80,0.80,0.80,1.0];
hubCableColor = [1.00,0.65,0.00,0.15];


//=============================================================================
// CUERPO DEL HUB
//=============================================================================

module hubUsbBody()
{

    color(hubBodyColor)

    difference()
    {

        translate([
            -usb_hub_width/2,
            -usb_hub_depth/2,
            0
        ])

            cube([
                usb_hub_width,
                usb_hub_depth,
                usb_hub_height
            ]);

        hubUsbMountHoles();

    }

}


//=============================================================================
// TALADROS DE FIJACIÓN
//=============================================================================

module hubUsbMountHoles()
{

    hx = usb_hub_width/2  - usb_hub_mount_inset_z;
    hy = usb_hub_depth/2  - usb_hub_mount_inset_y;

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([ix*hx, iy*hy, -0.5])

            cylinder(
                d = usb_hub_mount_hole,
                h = usb_hub_height+1
            );

}


//=============================================================================
// PUERTOS USB SALIENTES (referencia visual, lado +Y)
//=============================================================================

module hubUsbPorts()
{

    portWidth  = 12;
    portDepth  = 6;
    portHeight = 6;

    color(hubPortColor)

    for(ix=[-1,1])

        translate([
            ix*(usb_hub_width/4),
            usb_hub_depth/2,
            usb_hub_height/2 - portHeight/2
        ])

            cube([
                portWidth,
                portDepth,
                portHeight
            ]);

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module hubUsbBodyFull()
{

    union()
    {
        hubUsbBody();
        hubUsbPorts();
    }

}


//=============================================================================
// VOLUMEN DE SEGURIDAD DE CABLEADO
//
// Espacio reservado para los cables cortos hacia los USB frontales
// empotrables y hacia el ESP32.
//=============================================================================

module hubUsbCableKeepout(length = 20)
{

    color(hubCableColor)

    translate([
        -usb_hub_width/2,
        usb_hub_depth/2,
        0
    ])

        cube([
            usb_hub_width,
            length,
            usb_hub_height
        ]);

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module hubUsb()
{

    hubUsbBodyFull();

    hubUsbCableKeepout();

}


//=============================================================================
// PREVIEW
//=============================================================================

hubUsb();
