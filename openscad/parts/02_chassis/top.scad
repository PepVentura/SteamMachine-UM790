//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : top.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Tapa superior — pieza DESMONTABLE, independiente del chasis fijo
// (docs/DESIGN_RULES.md: "Panel superior desmontable.").
//
// Incluye:
//   - Hueco para el ventilador Noctua NF-A12x15, en la posición ya
//     validada (fan_pos, ver assembly_positions.scad), con orificios
//     de tornillo según fan_hole_pitch.
//   - Rejilla de ventilación de salida (refrigeración vertical:
//     entrada inferior en floor.scad, salida superior aquí).
//
// Sistema de coordenadas: igual que
// openscad/reference/components/assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del chasis
// (la tapa se sitúa en su posición real, cerca de Z=shell_height).
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <../../lib/ventilation.scad>;

$fn = 64;

part_version = "1.0";


//=============================================================================
// PLACA MACIZA DE LA TAPA
//=============================================================================

module topPlateSolid()
{

    translate([-case_width/2, -case_depth/2, shell_height - top_thickness])

        cube([case_width, case_depth, top_thickness]);

}


//=============================================================================
// HUECO DEL VENTILADOR — RETIRADO (2026-08-03, foto de referencia del
// usuario)
//
// Ya no hace falta ningún hueco grande dedicado al ventilador: la
// rejilla cubre ahora casi toda la tapa (ver topVentCut() más abajo),
// con agujeros pequeños y densos — el aire pasa por la rejilla que
// queda encima del ventilador igual que por el resto, sin necesitar
// una abertura propia del tamaño del ventilador. El ventilador sigue
// atornillado por debajo (fanMountBosses()/fanScrewHoles()/
// fanInsertCuts(), sin cambios).
//=============================================================================


//=============================================================================
// SOPORTES DEL VENTILADOR (con inserto M3)
//
// PEDIDO POR EL USUARIO (2026-08-03): "debe de tener soportaciones
// para fijar a ella el extractor" — antes solo había un taladro de
// paso liso en los 3 mm de la propia tapa (débil para un tornillo
// autorroscante). Ahora: un poste que sobresale hacia abajo desde la
// cara interior de la tapa, con un alojamiento ciego para inserto M3
// térmico en su extremo — mismo patrón que el resto de insertos del
// proyecto (insert_diameter/insert_depth).
//=============================================================================

fan_boss_diameter = 9.0;
fan_boss_height   = insert_depth + 2.0;  // sobresale hacia abajo desde la tapa

// Alturas de referencia (de arriba abajo): cara superior de la tapa,
// cara inferior de la tapa (= techo del poste), suelo del poste,
// techo del inserto (= fondo del taladro de paso).
fan_z_top        = shell_height;
fan_z_panel_low  = shell_height - top_thickness;
fan_z_boss_low   = fan_z_panel_low - fan_boss_height;
fan_z_insert_top = fan_z_boss_low + insert_depth;

module fanMountBosses()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            fan_pos[0] + ix*fan_hole_pitch/2,
            fan_pos[1] + iy*fan_hole_pitch/2,
            fan_z_boss_low
        ])

            cylinder(d = fan_boss_diameter, h = fan_boss_height);

}


//=============================================================================
// BRAZOS DE SUJECIÓN DE LOS POSTES DEL VENTILADOR
//
// Los postes caen DENTRO del hueco cuadrado del ventilador (a
// fan_hole_pitch/2 = 52,5 mm del centro, el hueco llega hasta
// fan_size/2 = 60 mm) — sin este brazo quedarían flotando, sin
// conexión a la tapa. Un brazo radial diagonal, hacia la esquina más
// cercana, los conecta con el material sólido justo fuera del hueco
// (patrón habitual en ventiladores reales, "araña" de sujeción).
//=============================================================================

fan_arm_width  = 6.0;
fan_arm_length = 16.0;  // suficiente para superar el borde cuadrado del hueco (10,6mm) con margen

module fanMountArms()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            fan_pos[0] + ix*fan_hole_pitch/2,
            fan_pos[1] + iy*fan_hole_pitch/2,
            fan_z_panel_low
        ])

            rotate([0,0, atan2(iy,ix)])

                translate([-fan_arm_width/2, 0, 0])

                    cube([fan_arm_width, fan_arm_length, top_thickness]);

}

module fanScrewHoles(screwDiameter = 3.4)
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            fan_pos[0] + ix*fan_hole_pitch/2,
            fan_pos[1] + iy*fan_hole_pitch/2,
            fan_z_insert_top
        ])

            cylinder(
                d = screwDiameter,
                h = fan_z_top - fan_z_insert_top + 1
            );

}

module fanInsertCuts()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            fan_pos[0] + ix*fan_hole_pitch/2,
            fan_pos[1] + iy*fan_hole_pitch/2,
            fan_z_boss_low - 0.1
        ])

            cylinder(d = insert_diameter, h = insert_depth + 0.1);

}


//=============================================================================
// REJILLA DE VENTILACIÓN DE SALIDA
//
// FALLO CORREGIDO (2026-08-03, aviso del usuario: "quedan piezas en
// el aire"): esta rejilla reutilizaba bottom_grill_margin, el mismo
// parámetro que se redujo a 3 mm para ampliar la rejilla del SUELO
// — sin querer, ese cambio también vació la tapa casi hasta el
// borde, demasiado cerca de los taladros de tornillo y del relleno
// de los insertos, dejando fragmentos de rejilla sin apoyo. Ahora
// tiene su propio margen (top_grill_margin), con espacio de sobra
// para esas zonas.
//
// Cambiado también de valvePattern() (rombos) a squareGrid()
// (agujeros cuadrados), a petición del usuario — patrón más
// uniforme, menos propenso a dejar fragmentos sueltos cerca de los
// bordes.
//=============================================================================

//=============================================================================
// REJILLA DE VENTILACIÓN — REDISEÑADA (2026-08-03, foto de referencia
// del usuario)
//
// Antes: rejilla solo en un anillo estrecho alrededor de un hueco
// grande dedicado al ventilador. Ahora: rejilla densa que cubre CASI
// TODA la tapa (como en la foto de referencia), con exclusiones
// locales pequeñas solo donde hace falta material sólido real
// (postes del ventilador, taladros de tornillo de la tapa) — no un
// gran hueco reservado para el ventilador entero.
//
// Agujeros más pequeños y densos que antes (5 mm con 2,5 mm de pared,
// antes 10 mm con 8 mm de pared), para un aspecto de rejilla fina
// como en la foto, no unos pocos agujeros sueltos.
//=============================================================================

module topVentCut()
{

    ventWidth = case_width - 2*top_grill_margin;
    ventDepth = case_depth - 2*top_grill_margin;

    fanBossClearance = fan_boss_diameter + 6;  // margen alrededor de cada poste del ventilador

    difference()
    {

        translate([
            -ventWidth/2,
            -ventDepth/2,
            shell_height - top_thickness - 1
        ])

            squareGrid(
                width   = ventWidth,
                height  = ventDepth,
                hole    = vent_slot_width*1.25,
                wall    = vent_slot_width*0.625,
                depth   = top_thickness + 2
            );

        // Islas sólidas alrededor de cada poste del ventilador — sin
        // esto, un poste podría caer justo sobre un hueco de la
        // rejilla y quedar sin apoyo.
        for(ix=[-1,1])
        for(iy=[-1,1])

            translate([
                fan_pos[0] + ix*fan_hole_pitch/2 - fanBossClearance/2,
                fan_pos[1] + iy*fan_hole_pitch/2 - fanBossClearance/2,
                shell_height - top_thickness - 2
            ])
                cube([fanBossClearance, fanBossClearance, top_thickness+4]);

    }

}


//=============================================================================
// TALADROS DE PASO PARA LOS TORNILLOS M3 DE LA TAPA
//
// docs/02_Mechanical_Layout.md, sección 6: "Superior: Atornillado."
// Los insertos M3 correspondientes van en el borde superior de las
// paredes laterales (ver openscad/parts/02_chassis/walls.scad,
// topScrewInsertCuts()) — deben coincidir en X/Y con estos taladros.
//=============================================================================

top_screw_diameter = 3.4;  // holgura de paso para M3
top_screw_csk_diameter = 6.0;  // avellanado M3
top_screw_csk_depth    = 1.8;  // dentro de los 3mm de la tapa

module topScrewHoles()
{

    screwX = sideMountGlobalX(insert_diameter/2);

    for(ix=[-1,1])
    for(iy=[-1,1])
    {

        // Taladro de paso, todo el grosor de la tapa
        translate([
            ix*screwX,
            iy*(case_depth/2 - wall_thickness - top_screw_y_inset),
            shell_height - top_thickness - 1
        ])

            cylinder(
                d = top_screw_diameter,
                h = top_thickness + 2
            );

        // Avellanado cónico, recesado en la cara exterior (no
        // atraviesa la tapa: cabe en 1,8 de los 3 mm de grosor)
        translate([
            ix*screwX,
            iy*(case_depth/2 - wall_thickness - top_screw_y_inset),
            shell_height - top_screw_csk_depth - 0.1
        ])

            cylinder(d1 = top_screw_diameter, d2 = top_screw_csk_diameter, h = top_screw_csk_depth+0.1);

    }

}


//=============================================================================
// REJILLA DE PROTECCIÓN DE DEDOS DEL VENTILADOR
//
// Varillas finas dentro del propio hueco del ventilador (no una
// pieza aparte). Grosor reducido (fan_guard_thickness) para no
// bloquear apenas el flujo de aire.
//=============================================================================

fan_guard_bar_width  = 2.0;
fan_guard_spacing    = 14.0;
fan_guard_thickness  = 2.0;

module fanFingerGuard()
{

    // FALLO CORREGIDO (2026-08-03, aviso del usuario: "agujeros
    // cuadrados, no tiras transversales"): usaba slots() (tiras
    // paralelas, en sólido). squareGrid() genera cubos sueltos
    // (pensados para restar) — para usarlos aquí, en sólido, hay que
    // invertirlo: una placa maciza MENOS squareGrid(), así queda una
    // rejilla continua con agujeros cuadrados, no cuadrados sueltos
    // flotando sin conexión entre sí.
    translate([
        fan_pos[0] - fan_size/2,
        fan_pos[1] - fan_size/2,
        shell_height - fan_guard_thickness
    ])

        intersection()
        {

            difference()
            {

                cube([fan_size, fan_size, fan_guard_thickness]);

                squareGrid(
                    width   = fan_size,
                    height  = fan_size,
                    hole    = fan_guard_spacing - fan_guard_bar_width,
                    wall    = fan_guard_bar_width,
                    depth   = fan_guard_thickness+0.2
                );

            }

            translate([fan_size/2, fan_size/2, 0])
                cylinder(d = fan_size, h = fan_guard_thickness);

        }

}


//=============================================================================
// MUESCA DE ALIVIO DEL RELLENO DEL INSERTO — RETIRADA (2026-08-03,
// aviso del usuario: "perforaciones rectangulares en vez de agujeros
// avellanados")
//
// Ya no hace falta: el relleno de la pared (topInsertPad(),
// walls.scad) ahora para en la cara interior de la tapa, no llega a
// la exterior — la tapa queda libre para tener su propio material
// (con el avellanado normal, dentro de su grosor) sin necesitar
// ninguna muesca de alivio.
//=============================================================================


//=============================================================================
// TAPA COMPLETA
//=============================================================================

module chassisTop()
{

    difference()
    {

        union()
        {
            topPlateSolid();
            fanMountBosses();
        }

        fanScrewHoles();

        fanInsertCuts();

        topVentCut();

        topScrewHoles();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    chassisTop();
