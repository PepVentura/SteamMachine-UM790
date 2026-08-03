//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : um790.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Volumen mecánico de referencia del Minisforum UM790 Pro para el
// ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro de la PCB en X/Y, cara inferior de la PCB
//                     (el plano donde apoya sobre los separadores).
//   +X = hacia el lateral derecho de la placa.
//   +Y = hacia la IO trasera (RJ45 / USB / alimentación).
//   +Z = hacia arriba (hacia el disipador).
//
// Componentes representados:
//   - PCB
//   - Disipador (volumen aproximado)
//   - Conectores traseros (volumen aproximado hasta el panel trasero)
//   - Postes de anclaje / separadores
//   - Volumen de seguridad de cableado alrededor de la placa
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

um790PcbColor    = [0.10,0.45,0.12,1.0];
um790CoolerColor = [0.55,0.55,0.55,1.0];
um790IOColor     = [0.75,0.75,0.75,1.0];
um790SafetyColor = [1.00,0.65,0.00,0.15];


//=============================================================================
// PCB
//=============================================================================

module um790Pcb()
{

    color(um790PcbColor)

    translate([-pcb_width/2,-pcb_depth/2,0])

        cube([
            pcb_width,
            pcb_depth,
            pcb_thickness
        ]);

}


//=============================================================================
// DISIPADOR
//=============================================================================

module um790Cooler()
{

    color(um790CoolerColor)

    translate([
        -um790_cooler_width/2,
        -um790_cooler_depth/2,
        pcb_thickness
    ])

        cube([
            um790_cooler_width,
            um790_cooler_depth,
            um790_cooler_height
        ]);

}


//=============================================================================
// CONECTORES TRASEROS
//
// Bloque situado en el borde +Y de la PCB, extendido hasta alcanzar
// la cara interior del panel trasero (um790_rearIO_depth, calculado
// en 00_parametros.scad a partir de case_depth, wall_thickness y
// pcb_depth).
//=============================================================================

module um790RearIO()
{

    color(um790IOColor)

    translate([
        -um790_rearIO_width/2,
        pcb_depth/2,
        pcb_thickness
    ])

        cube([
            um790_rearIO_width,
            um790_rearIO_depth,
            um790_rearIO_height
        ]);

}


//=============================================================================
// POSTES DE ANCLAJE (SEPARADORES)
//
// Misma posición que openscad/parts/01_bandeja/posts.scad
// (um790_mount_spacing_x/y, um790_post_diameter), pero con la altura
// vigente en este ensamblaje virtual (um790_standoff_height, ver
// 00_parametros.scad y docs/03_Virtual_Assembly_Report.md respecto a
// la reconciliación pendiente con posts.scad: 6 mm allí).
//
// Se dibujan hacia abajo desde la cara inferior de la PCB (Z=0 local)
// hasta la bandeja, para que cualquier componente que pase por debajo
// de la PCB (p. ej. el pulsador o el USB frontal, si se elevase la
// PCB lo suficiente) se compruebe también contra ellos.
//=============================================================================

module um790MountingPosts()
{

    off_x_local = um790_mount_spacing_x/2;
    off_y_local = um790_mount_spacing_y/2;

    color(um790IOColor)

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*off_x_local,
            iy*off_y_local,
            -um790_standoff_height
        ])

            cylinder(
                d = um790_post_diameter,
                h = um790_standoff_height
            );

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module um790Body()
{

    union()
    {
        um790Pcb();
        um790Cooler();
        um790RearIO();
        um790MountingPosts();
    }

}


//=============================================================================
// VOLUMEN DE SEGURIDAD DE CABLEADO
//
// Envolvente alrededor de la PCB (lateral izquierdo, lateral derecho
// y borde frontal -Y) reservada para el paso de cableado interno
// (alimentación, ESP32, ventilador). No incluye el borde trasero,
// que ya dispone de su propio volumen de IO.
//=============================================================================

module um790CableKeepout()
{

    color(um790SafetyColor)

    translate([
        -pcb_width/2 - um790_cable_margin,
        -pcb_depth/2 - um790_cable_margin,
        0
    ])

        cube([
            pcb_width + um790_cable_margin*2,
            pcb_depth + um790_cable_margin,
            pcb_thickness + um790_cooler_height
        ]);

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module um790()
{

    um790Body();

    um790CableKeepout();

}


//=============================================================================
// PREVIEW
//=============================================================================

um790();
