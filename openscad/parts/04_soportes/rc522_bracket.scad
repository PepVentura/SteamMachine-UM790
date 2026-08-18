//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : rc522_bracket.scad
// Versión  : 2.0
// Fecha    : 2026-08-03
//
// Soporte REAL e IMPRIMIBLE del lector RC522.
//
// REDISEÑO COMPLETO (aviso del usuario, v2.0):
//   - FALLO CORREGIDO: el taladro de tornillo de la v1.0 estaba
//     orientado en el eje Y — no coincidía con el eje real del poste
//     de anclaje (rc522MountBoss(), walls.scad), que crece en X. El
//     tornillo no habría podido entrar en la dirección correcta.
//   - Extremos rediseñados como prolongación en "L": el brazo
//     horizontal (en X) termina en una pletina más ancha, con
//     avellanado cónico real para la cabeza del tornillo — no un
//     simple taladro de paso al final del brazo.
//   - Encaje del lector ajustado a sus medidas EXACTAS
//     (nfc_reader_width x nfc_reader_height x nfc_reader_depth,
//     00_parametros.scad), no una huella aproximada — el lector debe
//     encajar perfectamente.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 32;

part_version = "2.0";


//=============================================================================
// COORDENADAS COMPARTIDAS CON walls.scad (rc522MountBoss())
//
// Deben coincidir exactamente: misma Y (centro de profundidad de la
// placa), misma Z (rc522_pos[2]), y en X hasta la cara interior de
// cada poste (que crece rc522_mount_depth hacia el interior desde la
// cara interior de la pared).
//=============================================================================

rc522_bracket_y     = rc522_pos[1] + nfc_reader_depth/2;
rc522_bracket_z     = rc522_pos[2];
rc522_bracket_x_end = case_width/2 - wall_thickness - rc522_mount_depth;  // 69, cara interior del poste

rc522_end_pad_size      = 15.0;  // placa plana, ancha (mucho más que el brazo, para que se note el ángulo de 90°) — limitado por la distancia al panel NFC (ver rc522BracketEndPads())
rc522_end_pad_thickness = 3.0;   // grosor de la placa (perpendicular a la pared)
rc522_csk_diameter  = 6.0;  // avellanado M3
rc522_csk_depth     = 1.6;  // dentro del grosor de la pletina


//=============================================================================
// BRAZO HORIZONTAL — de la placa hasta cerca de cada pared
//
// FALLO CORREGIDO (2026-08-03, captura del usuario): el brazo, al
// llegar centrado justo donde está el taladro de la placa, tapaba el
// propio agujero — imposible meter el tornillo por dentro, bloqueado
// por el material del propio brazo. Rediseñado como una horquilla de
// dos barras más finas, una por encima y otra por debajo del eje del
// tornillo, dejando el centro (por donde debe entrar el tornillo)
// completamente libre.
//=============================================================================

rc522_arm_prong_height = 3.0;   // alto de cada barra de la horquilla
rc522_arm_gap          = 8.0;   // hueco central libre, más ancho que el avellanado (6mm) para que quepa el destornillador

module rc522BracketArms()
{

    armInnerX = nfc_reader_width/2;
    armLength = rc522_bracket_x_end - rc522_end_pad_thickness - armInnerX;

    for(ix=[-1,1])
    for(iz=[-1,1])

        translate([
            ix>0 ? armInnerX : -armInnerX-armLength,
            rc522_bracket_y - rc522_bracket_thickness/2,
            rc522_bracket_z + iz*rc522_arm_gap/2 + (iz>0 ? 0 : -rc522_arm_prong_height)
        ])

            cube([
                armLength,
                rc522_bracket_thickness,
                rc522_arm_prong_height
            ]);

}


//=============================================================================
// PROLONGACIÓN EN "L" DE CADA EXTREMO
//
// El brazo horizontal (en X) llega hasta cerca del poste y termina en
// una pletina — más ancha que el propio brazo, con su cara plana
// justo enfrente del poste (perpendicular a X, mismo plano que la
// cara de la pared) — el taladro avellanado atraviesa esta pletina en
// el eje X, mismo eje que el poste.
//=============================================================================

module rc522BracketEndPads()
{

    // REDISEÑADO (2026-08-03, aviso del usuario: "debe tener forma
    // de L o ángulo de 90 grados", confirmado: "plana contra la
    // pared, tornillo perpendicular a ella"): antes era un bloque
    // macizo (14x14x14) — ahora una placa plana y ancha (18x18 mm),
    // solo 3 mm de grosor en X, mucho más ancha que el propio brazo
    // (10 mm) para que el ángulo de 90° se note claramente. Su cara
    // exterior toca la punta del poste (X=69, mismo criterio que
    // antes de no invadir la pared), y el tornillo entra
    // perpendicular a ella desde la cara interior.
    for(ix=[-1,1])

        translate([
            ix>0 ? rc522_bracket_x_end - rc522_end_pad_thickness : -rc522_bracket_x_end,
            rc522_bracket_y - rc522_end_pad_size/2,
            rc522_bracket_z - rc522_end_pad_size/2
        ])

            cube([
                rc522_end_pad_thickness,
                rc522_end_pad_size,
                rc522_end_pad_size
            ]);

}

module rc522BracketScrewHoles()
{

    for(ix=[-1,1])

        translate([
            ix*rc522_bracket_x_end,
            rc522_bracket_y,
            rc522_bracket_z
        ])

            rotate([0,90,0])
            {

                // Taladro de paso, todo el grosor de la placa (3mm) —
                // su cara exterior (la que toca el poste) está en el
                // origen de este eje local (Z=0); la placa se
                // extiende hacia dentro, en +Z para el lado izquierdo
                // (ix=-1) y en -Z para el derecho (ix=1) —
                // direcciones opuestas en este eje local, aunque en
                // coordenadas globales las dos crecen hacia el
                // centro.
                translate([0,0, ix>0 ? -rc522_end_pad_thickness-0.1 : -0.1])
                    cylinder(d = 3.4, h = rc522_end_pad_thickness+1.1);

                // FALLO CORREGIDO (2026-08-03, aviso del usuario: "no
                // se puede sujetar a los laterales" / "debe tener
                // forma de L o ángulo de 90 grados"): la pletina era
                // un bloque macizo que solo tocaba la punta del
                // poste, sin ángulo de 90° real ni superficie de
                // apoyo — ahora es una placa plana y ancha,
                // perpendicular a la pared, con el avellanado en su
                // cara INTERIOR (mirando hacia la placa/el interior
                // del chasis) — el tornillo entra desde dentro, con
                // acceso real, atraviesa la placa y rosca en el
                // poste.
                translate([0,0, ix>0 ? -rc522_end_pad_thickness-0.1 : rc522_end_pad_thickness-rc522_csk_depth])
                    cylinder(
                        d1 = ix>0 ? rc522_csk_diameter : 3.4,
                        d2 = ix>0 ? 3.4 : rc522_csk_diameter,
                        h  = rc522_csk_depth+0.1
                    );

            }

}


//=============================================================================
// ENCAJE DEL LECTOR — ajustado a sus medidas exactas
//
// Marco que rodea la placa por sus 4 lados (nfc_reader_width x
// nfc_reader_height), con una holgura mínima para que encaje sin
// forzar, y una repisa por detrás donde apoya (nfc_reader_depth).
//=============================================================================

//=============================================================================
// ENCAJE DEL LECTOR — ajustado a sus medidas exactas
//
// FALLO CORREGIDO: la primera versión tenía una pared frontal que se
// extendía hasta la cara frontal del propio panel NFC (invadiendo su
// espacio, colisión real confirmada) — el hueco de separación entre
// el lector y el panel (rc522_panel_gap = 3 mm) ya está reservado
// para eso, no hace falta ninguna pared del soporte ahí. El panel ya
// hace de "tope" frontal.
//
// Ahora: SIN pared frontal — solo una repisa trasera (apoyo) y guías
// laterales/superior/inferior, todo dentro de la profundidad real de
// la placa (rc522_pos[1] a rc522_pos[1]+nfc_reader_depth).
//=============================================================================

//=============================================================================
// ORIFICIO DE SALIDA DE CONECTORES/CABLES
//
// PEDIDO POR EL USUARIO (2026-08-15, marcado a mano en una foto del
// soporte real): el lector tiene una fila de pines de conexión que
// sobresalen por uno de sus bordes — la repisa trasera (el "tope"
// donde apoya el lector) los bloquea sin dejarles salida. Se abre un
// hueco rectangular en esa repisa, cerca del borde donde están los
// pines según la foto.
//
// ESTIMADO — posición y tamaño calculados a partir de las
// proporciones visibles en la foto, no de una medida exacta del
// conector. Revisar tras imprimir y ajustar si hace falta.
//=============================================================================

rc522_connector_hole_width  = 10.0;  // ESTIMADO
rc522_connector_hole_height = 26.0;  // ESTIMADO
// PEDIDO POR EL USUARIO (2026-08-15): "debe quedar alineado a la
// derecha del todo, pero sin invadir el marco lateral" — antes
// centrado en X=20, quedaba visiblemente hacia el centro. Ahora el
// borde derecho del hueco coincide exactamente con el borde derecho
// de la cavidad del lector (nfc_reader_width/2 + la holgura de
// encaje), justo hasta donde empieza la pared estructural — sin
// tocarla.
rc522_connector_hole_x      = 25.3;  // antes 20.0 — borde derecho ahora en 30.3 (= nfc_reader_width/2 + rc522_fit_clearance), el límite de la cavidad

module rc522ConnectorCutout()
{

    translate([
        rc522_connector_hole_x - rc522_connector_hole_width/2,
        rc522_pos[1] + nfc_reader_depth - rc522_bracket_thickness - 0.1,
        rc522_bracket_z - rc522_connector_hole_height/2
    ])

        cube([
            rc522_connector_hole_width,
            rc522_bracket_thickness + 0.2,
            rc522_connector_hole_height
        ]);

}

module rc522BracketCradle()
{

    rc522_fit_clearance = 0.3;  // holgura para que el lector entre sin forzar

    outerW = nfc_reader_width + 2*rc522_bracket_thickness + 2*rc522_fit_clearance;
    outerH = nfc_reader_height + 2*rc522_bracket_thickness + 2*rc522_fit_clearance;

    difference()
    {

        translate([
            -outerW/2,
            rc522_pos[1],
            rc522_bracket_z - outerH/2
        ])

            cube([outerW, nfc_reader_depth, outerH]);

        // Hueco donde encaja la placa — abierto hacia el panel (Y
        // menor), cerrado por detrás (la cara trasera de la caja de
        // arriba hace de repisa/tope).
        translate([
            -nfc_reader_width/2-rc522_fit_clearance,
            rc522_pos[1]-0.1,
            rc522_bracket_z-nfc_reader_height/2-rc522_fit_clearance
        ])
            cube([
                nfc_reader_width+2*rc522_fit_clearance,
                nfc_reader_depth-rc522_bracket_thickness+0.1,
                nfc_reader_height+2*rc522_fit_clearance
            ]);

        rc522ConnectorCutout();

    }

}


//=============================================================================
// SOPORTE COMPLETO
//=============================================================================

module rc522BracketPrintable()
{

    difference()
    {

        union()
        {
            rc522BracketArms();
            rc522BracketEndPads();
            rc522BracketCradle();
        }

        rc522BracketScrewHoles();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Silver")
    rc522BracketPrintable();
