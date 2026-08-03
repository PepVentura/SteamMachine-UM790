//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : noctua.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia del ventilador Noctua NF-A12x15 PWM
// (120 x 120 x 15 mm) para el ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro del ventilador en X/Y, cara inferior
//                     (cara de aspiración, hacia el disipador).
//   +Z = hacia la cara superior (cara de expulsión, hacia la rejilla
//        de la tapa).
//
// Refrigeración vertical del proyecto: entrada inferior, salida
// superior (ver docs/DESIGN_RULES.md). Este ventilador se monta
// pegado a la tapa, expulsando el aire hacia arriba.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 48;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

noctuaFrameColor = [0.10,0.10,0.10,1.0];
noctuaHubColor   = [0.65,0.55,0.20,1.0];
noctuaFlowColor  = [0.30,0.70,1.00,0.12];


//=============================================================================
// MARCO DEL VENTILADOR
//=============================================================================

module noctuaFrame()
{

    color(noctuaFrameColor)

    translate([-fan_size/2,-fan_size/2,0])

    linear_extrude(height = fan_thickness)

        offset(r = -fan_frame_corner_r)
        offset(delta = fan_frame_corner_r)

            square([fan_size,fan_size]);

}


//=============================================================================
// BUJE / MOTOR CENTRAL (referencia visual)
//=============================================================================

module noctuaHub()
{

    color(noctuaHubColor)

    translate([0,0,fan_thickness*0.15])

        cylinder(
            d = fan_hub_diameter,
            h = fan_thickness*0.7
        );

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module noctuaBody()
{

    union()
    {
        noctuaFrame();
        noctuaHub();
    }

}


//=============================================================================
// VOLUMEN DE SEGURIDAD DEL FLUJO DE AIRE
//
// Columna de aire bajo el ventilador (hacia el disipador) que debe
// permanecer libre de cualquier otro componente u obstáculo impreso.
//=============================================================================

module noctuaAirflowKeepout(depth = 20)
{

    color(noctuaFlowColor)

    translate([-fan_size/2,-fan_size/2,-depth])

        cube([
            fan_size,
            fan_size,
            depth
        ]);

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module noctua()
{

    noctuaBody();

    noctuaAirflowKeepout();

}


//=============================================================================
// PREVIEW
//=============================================================================

noctua();
