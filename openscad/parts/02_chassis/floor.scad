//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : floor.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Suelo del chasis principal fijo, con rejilla de ventilación de
// entrada de aire (refrigeración vertical: entrada inferior, salida
// superior — docs/DESIGN_RULES.md).
//
// Sistema de coordenadas: igual que
// openscad/reference/components/assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del chasis.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <../../lib/ventilation.scad>;

$fn = 64;

part_version = "1.0";


//=============================================================================
// PLACA MACIZA DEL SUELO
//=============================================================================

module floorPlate()
{

    translate([-case_width/2, -case_depth/2, 0])

        cube([case_width, case_depth, bottom_thickness]);

}


//=============================================================================
// REJILLA DE VENTILACIÓN
//
// Patrón tipo Valve (valvePattern, ya presente en ventilation.scad),
// con el margen ya definido en 00_parametros.scad
// (bottom_grill_margin). Se sitúa bajo la huella del disipador,
// centrada en X/Y, para maximizar el flujo de aire justo debajo del
// UM790.
//=============================================================================

module floorVentCut()
{

    ventWidth  = case_width  - 2*bottom_grill_margin;
    ventDepth  = case_depth  - 2*bottom_grill_margin;
    ventDepthCut = bottom_thickness + 2;

    translate([
        -ventWidth/2,
        -ventDepth/2,
        -1
    ])

        valvePattern(
            width   = ventWidth,
            height  = ventDepth,
            hole    = vent_slot_width*2.5,
            spacing = vent_spacing,
            depth   = ventDepthCut
        );

}


//=============================================================================
// REBAJE BAJO EL CLÚSTER FRONTAL
//
// Hallazgo de la comprobación de colisiones: el OLED y el USB
// frontal, en su posición ya validada (front_cluster_z = 19, ver
// assembly_positions.scad), bajan hasta Z=1,5 mm — por debajo de la
// cara superior del suelo (bottom_thickness = 3 mm). Sin este rebaje,
// el suelo invade el bloque de pines del OLED y el cuerpo del USB.
//
// Se recorta el suelo por completo (Z 0 a bottom_thickness) en la
// franja frontal donde vive el clúster, con margen.
//=============================================================================

module frontClusterRelief()
{

    reliefXmin = pushbutton_pos[0] - pushbutton_cap_diameter/2 - 3;
    reliefXmax = usb_front_pos[0]  + usb_front_flange_diameter/2 + 3;
    reliefYmax = usb_front_pos[1] + usb_front_flange_diameter/2 + usb_front_body_length + 3;

    translate([
        reliefXmin,
        -case_depth/2 - 1,
        -1
    ])

        cube([
            reliefXmax - reliefXmin,
            (reliefYmax - (-case_depth/2 - 1)),
            bottom_thickness + 2
        ]);

}


//=============================================================================
// APOYOS DE LA BANDEJA
//
// La bandeja (tray_width = 150 mm) encaja EXACTAMENTE con el ancho
// interior del chasis (case_width - 2*wall_thickness = 150 mm): sin
// holgura, un ajuste a presión poco realista para impresión 3D. Por
// eso no se guía por las paredes (invadiría ese hueco inexistente),
// sino que se apoya en 4 postes que suben desde el suelo hasta la
// cámara de aire inferior (lower_air_chamber = 12 mm), dentro de la
// huella de la bandeja, sin tocar las paredes.
//
// PENDIENTE: valorar reducir tray_width/tray_depth ligeramente
// (0,4-0,6 mm) en una futura revisión para dar holgura de impresión
// real; no se ha hecho aquí porque tray_width ya se usa en la
// bandeja construida (openscad/parts/01_bandeja) y cambiarlo se sale
// del alcance de esta sesión.
//=============================================================================

// tray_support_diameter / tray_support_inset: ver 00_parametros.scad
// (compartidos con openscad/parts/01_bandeja/base.scad)

module traySupportPosts()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*(tray_width/2  - tray_support_inset_x),
            iy*(tray_depth/2  - tray_support_inset_y),
            bottom_thickness
        ])

            difference()
            {

                cylinder(d = tray_support_diameter, h = lower_air_chamber);

                // FALLO CORREGIDO (2026-08-03, aviso del usuario): el
                // poste estaba completamente macizo, sin alojamiento
                // para el inserto M3 que fija la bandeja.
                translate([0,0,lower_air_chamber-insert_depth])
                    cylinder(d = insert_diameter, h = insert_depth+0.1);

            }

}


//=============================================================================
// PATAS EXTERNAS
//
// CONFIRMADO por el usuario (2026-08-03): externas, 4 mm, por debajo
// del cascarón (leg_height, 00_parametros.scad). Mismo criterio de
// posición que openscad/reference/virtual_assembly_v1.scad
// (externalLegs()) — 4 patas cuadradas en las esquinas.
//=============================================================================

leg_footprint = 10.0;  // estimado, lado de cada pata cuadrada

module floorLegs()
{

    // FALLO CORREGIDO (2026-08-03): la fórmula anterior calculaba la
    // posición como si cube() estuviera centrado, pero se llamaba con
    // center=false (esquina, no centro) — la pata acababa 2 mm por
    // fuera del borde real de la carcasa en X e Y (detectado en una
    // captura del usuario: "hay pies que quedan por fuera de la
    // base"). Ahora con center=true, leg_center_offset es
    // directamente el centro real de la pata.

    leg_edge_margin = 2.0;  // margen entre el borde exterior de la pata y el borde de la carcasa
    leg_center_offset_x = case_width/2 - leg_footprint/2 - leg_edge_margin;
    leg_center_offset_y = case_depth/2 - leg_footprint/2 - leg_edge_margin;

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
// SUELO COMPLETO
//=============================================================================

module chassisFloor()
{

    union()
    {

        difference()
        {

            floorPlate();

            floorVentCut();

            frontClusterRelief();

        }

        floorLegs();

        traySupportPosts();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    chassisFloor();
