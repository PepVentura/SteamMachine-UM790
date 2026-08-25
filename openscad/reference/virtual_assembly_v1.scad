//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : virtual_assembly_v1.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// ENSAMBLAJE VIRTUAL COMPLETO — FASE PREVIA AL DISEÑO DEL CHASIS
//
// Objetivo: verificar visualmente que todos los componentes electrónicos
// caben dentro del volumen exterior real de la Steam Machine (148 mm sin
// patas / 152 mm con patas · 156 mm · 162,4 mm) antes de diseñar
// cualquier pieza imprimible del chasis definitivo.
//
// NO ES UNA PIEZA IMPRIMIBLE. Nada de este archivo debe usarse para
// generar STL de impresión.
//
// Este archivo NO define geometría propia de los componentes: se apoya
// por completo en:
//   - openscad/reference/components/assembly_positions.scad (dónde va cada cosa)
//   - openscad/reference/components/assembly_instances.scad (cada componente ya
//     colocado en su posición)
//
// La comprobación automática de colisiones vive en
// openscad/reference/checks/ y usa estos mismos archivos, de modo que
// el resultado del render y el de la comprobación son siempre coherentes.
//
// Ver docs/Virtual_Assembly_Report.md para el informe de resultados
// de esta primera verificación.
//
// ============================================================================

include <../../00_parametros.scad>;
include <components/assembly_positions.scad>;

use <components/assembly_instances.scad>;

$fn = 48;

part_version = "1.0";


//=============================================================================
// MODO DE VISUALIZACIÓN
//
//   show_case       → envolvente exterior real (156 x 162,4 x 152 mm)
//   show_bodies     → volúmenes mecánicos rígidos de los componentes
//   show_keepouts   → volúmenes de seguridad / cableado (semitransparentes)
//   show_axes       → ejes de referencia en el origen
//   show_fan_column → columna de aire ventilador → disipador (informativo)
//=============================================================================

show_case       = true;
show_bodies     = true;
show_keepouts   = true;
show_axes       = true;
show_fan_column = true;


//=============================================================================
// ENVOLVENTE EXTERIOR DE REFERENCIA
//
// Representa el volumen exterior real de la Steam Machine original:
// el cascarón (shell_height = 148 mm) más 4 patas externas de
// leg_height = 4 mm por debajo (CONFIRMADO por el usuario,
// 2026-08-03 — ver 00_parametros.scad). Únicamente para comprobar
// que nada sobresale. NO es el chasis definitivo (ese se diseña en
// openscad/parts/02_chassis con su propio sistema de coordenadas).
//=============================================================================

module caseEnvelope()
{

    color([0.75,0.75,0.75,0.10])

    difference()
    {

        translate([-case_width/2,-case_depth/2,0])
            cube([case_width,case_depth,shell_height]);

        translate([
            -case_width/2+wall_thickness,
            -case_depth/2+wall_thickness,
            bottom_thickness
        ])
            cube([
                case_width-2*wall_thickness,
                case_depth-2*wall_thickness,
                shell_height
            ]);

    }

}


//=============================================================================
// PATAS EXTERNAS (4x, CONFIRMADAS por el usuario: externas, 4 mm,
// por debajo del cascarón — Z negativa, ver leg_height en
// 00_parametros.scad)
//=============================================================================

leg_footprint = 10.0;  // estimado, lado de cada pata cuadrada

module externalLegs()
{

    // FALLO CORREGIDO (2026-08-03): misma corrección que
    // openscad/parts/02_chassis/floor.scad (floorLegs()) — la pata
    // quedaba 2 mm por fuera del borde real de la carcasa.

    leg_edge_margin = 2.0;
    leg_center_offset_x = case_width/2 - leg_footprint/2 - leg_edge_margin;
    leg_center_offset_y = case_depth/2 - leg_footprint/2 - leg_edge_margin;

    color([0.5,0.5,0.5,0.6])

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*leg_center_offset_x,
            iy*leg_center_offset_y,
            -leg_height/2
        ])

            cube([leg_footprint, leg_footprint, leg_height], center=true);

}


//=============================================================================
// EJES DE REFERENCIA
//=============================================================================

module referenceAxes(length=40)
{

    color("red")   cube([length,1,1]);
    color("green") cube([1,length,1]);
    color("blue")  cube([1,1,length]);

}


//=============================================================================
// COLUMNA DE AIRE VENTILADOR → DISIPADOR (informativo)
//
// Representa el volumen que debe permanecer libre de obstáculos entre
// la cara inferior del ventilador y la cara superior del disipador.
//=============================================================================

module fanToCoolerColumn()
{

    color([0.30,0.70,1.00,0.06])

    translate([
        fan_pos[0]-fan_size/2,
        fan_pos[1]-fan_size/2,
        z_cooler_top
    ])

        cube([
            fan_size,
            fan_size,
            z_fan_bottom - z_cooler_top
        ]);

}


//=============================================================================
// ENSAMBLAJE
//=============================================================================

if (show_axes)
    referenceAxes();

if (show_case)
{
    caseEnvelope();
    externalLegs();
}

if (show_fan_column)
    fanToCoolerColumn();

if (show_bodies)
{
    um790InstanceBody();
    noctuaInstanceBody();
    rc522InstanceBody();
    esp32InstanceBody();
    hubInstanceBody();
    oledInstanceBody();
    pushbuttonInstanceBody();
    usbFrontInstanceBody();
}

if (show_keepouts)
{
    um790InstanceKeepout();
    noctuaInstanceKeepout();
    rc522InstanceKeepout();
    esp32InstanceKeepout();
    hubInstanceKeepout();
}


//=============================================================================
// TRAZAS DE CONTROL (visibles en la consola de OpenSCAD)
//=============================================================================

echo("=====================================================");
echo("SteamMachine UM790 — Ensamblaje virtual v1");
echo("=====================================================");
echo(str("Carcasa exterior: ", case_width, " x ", case_depth, " x ", case_height, " mm (con patas)"));
echo(str("Altura sin patas (cascarón): ", shell_height, " mm"));
echo(str("z_pcb_bottom = ", z_pcb_bottom, " mm"));
echo(str("z_cooler_top = ", z_cooler_top, " mm"));
echo(str("z_fan_bottom = ", z_fan_bottom, " mm  (hueco sobre el disipador: ", z_fan_bottom - z_cooler_top, " mm)"));
echo(str("rc522_pos = ", rc522_pos));
echo(str("esp32_pos = ", esp32_pos));
echo(str("hub_pos   = ", hub_pos));
echo(str("oled_pos  = ", oled_pos));
echo(str("pushbutton_pos = ", pushbutton_pos));
echo(str("usb_front_pos  = ", usb_front_pos));
echo("Ver docs/Virtual_Assembly_Report.md para el resultado");
echo("de la comprobación automática de colisiones.");
echo("=====================================================");
