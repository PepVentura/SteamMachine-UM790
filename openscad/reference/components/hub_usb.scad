//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : hub_usb.scad
// Versión  : 2.0
// Fecha    : 2026-10-05
//
// Volumen mecánico de referencia del Hub USB para el ensamblaje
// virtual v1.
//
// v2.0 (2026-10-05): SUSTITUYE al CJMCU-204 (44,1 x 44,1 x 12 mm).
// Hub nuevo de placa alargada (68,7 x 18,2 mm): 4 bocas USB-A
// horizontales en un lado largo (+X local) y entrada USB-C en un
// extremo (-Y local). Medidas tomadas de fotos — ver usb_hub_* en
// 00_parametros.scad.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro de la placa en X/Y, cara inferior
//                     (la que mira a la pared).
//   +Z = hacia los componentes.
//   +X = lado de las bocas USB-A (queda hacia ARRIBA en el chasis).
//   -Y = extremo del USB-C (puede montarse girada 180°: los
//        taladros son simétricos).
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 24;

part_version = "2.0";


//=============================================================================
// COLORES
//=============================================================================

hubBodyColor  = [0.20,0.20,0.20,1.0];
hubPortColor  = [0.80,0.80,0.80,1.0];
hubCableColor = [1.00,0.65,0.00,0.15];


//=============================================================================
// PLACA DEL HUB
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
                usb_hub_pcb_thickness
            ]);

        hubUsbMountHoles();

    }

}


//=============================================================================
// TALADROS DE FIJACIÓN (4x M2, simétricos)
//=============================================================================

module hubUsbMountHoles()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([ix*usb_hub_hole_spacing_x/2, iy*usb_hub_hole_spacing_y/2, -0.5])

            cylinder(
                d = usb_hub_board_hole,
                h = usb_hub_pcb_thickness+1
            );

}


//=============================================================================
// CONECTORES (4x USB-A en el lado +X, USB-C en el extremo -Y)
//
// Posiciones a lo largo (Y) medidas en las fotos: centros de las
// bocas a -19,5 / -4,9 / +10,0 / +24,4 mm del centro de la placa
// (paso ~14,6 mm). Carcasa USB-A ~13,1 x 10 x 7 mm, asomando 0,7 mm
// por el borde +X. USB-C ~9 x 7,4 x 3,2 mm, asomando 1,4 mm por -Y.
//=============================================================================

hub_port_y        = [-19.5, -4.9, 10.0, 24.4];
hub_port_width    = 13.1;
hub_port_length   = 10.0;
hub_port_overhang = 0.7;
hub_port_height   = usb_hub_height - usb_hub_pcb_thickness;

module hubUsbPorts()
{

    color(hubPortColor)
    {

        for(y = hub_port_y)

            translate([
                usb_hub_width/2 + hub_port_overhang - hub_port_length,
                y - hub_port_width/2,
                usb_hub_pcb_thickness
            ])

                cube([hub_port_length, hub_port_width, hub_port_height]);

        translate([-4.5, -usb_hub_depth/2 - 1.4, usb_hub_pcb_thickness])
            cube([9.0, 7.4, 3.2]);

    }

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
// Espacio reservado por ENCIMA de las bocas USB-A (+X local = arriba
// en el chasis) para las clavijas y el arranque de sus cables
// (clavija USB-A típica ~35-40 mm con el alivio de tensión).
//=============================================================================

module hubUsbCableKeepout(length = 40)
{

    color(hubCableColor)

    translate([
        usb_hub_width/2 + hub_port_overhang,
        -usb_hub_depth/2,
        0
    ])

        cube([
            length,
            usb_hub_depth,
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
