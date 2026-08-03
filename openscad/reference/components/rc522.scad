//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : rc522.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Volumen mecánico de referencia del lector RC522 (MFRC522) y de su
// soporte a ambos laterales del chasis, para el ensamblaje virtual v1.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Requisitos de posicionamiento (ver openscad/reference/virtual_assembly_v1.scad):
//   - Centrado horizontalmente.
//   - A media altura del panel frontal superior intercambiable (panel NFC).
//   - Sujeto mediante un soporte a ambos laterales del chasis (no al panel,
//     para que el panel se pueda cambiar sin desconectar el lector).
//
// Sistema de coordenadas LOCAL de este módulo:
//   Origen (0,0,0) = centro de la placa del lector en X/Z, cara frontal
//                     (la que queda más cerca del panel intercambiable).
//   +X = hacia el lateral derecho del chasis.
//   +Y = hacia el interior del chasis (alejándose del panel).
//   +Z = hacia arriba.
//
// half_case_width se recibe como parámetro para poder dimensionar los
// brazos del soporte hasta las paredes laterales sin duplicar la lógica
// de posicionamiento del chasis en este módulo.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// COLORES
//=============================================================================

rc522BoardColor   = [0.10,0.35,0.10,1.0];
rc522BracketColor = [0.60,0.60,0.60,1.0];
rc522CableColor   = [1.00,0.65,0.00,0.15];


//=============================================================================
// PLACA DEL LECTOR
//=============================================================================

module rc522Board()
{

    color(rc522BoardColor)

    translate([
        -nfc_reader_width/2,
        0,
        -nfc_reader_height/2
    ])

        cube([
            nfc_reader_width,
            nfc_reader_depth,
            nfc_reader_height
        ]);

}


//=============================================================================
// SOPORTE A AMBOS LATERALES DEL CHASIS
//
// Dos brazos que van desde el borde de la placa hasta la cara interior
// de cada pared lateral del chasis (case_width/2 - wall_thickness).
//=============================================================================

module rc522Bracket(interiorHalfWidth = case_width/2 - wall_thickness)
{

    armLength = interiorHalfWidth - nfc_reader_width/2;

    color(rc522BracketColor)
    {

        // Brazo derecho
        translate([
            nfc_reader_width/2,
            0,
            -rc522_bracket_width/2
        ])
        cube([
            armLength,
            rc522_bracket_thickness,
            rc522_bracket_width
        ]);

        // Brazo izquierdo
        translate([
            -nfc_reader_width/2 - armLength,
            0,
            -rc522_bracket_width/2
        ])
        cube([
            armLength,
            rc522_bracket_thickness,
            rc522_bracket_width
        ]);

    }

}


//=============================================================================
// CUERPO MECÁNICO (para comprobación de colisiones "duras")
//=============================================================================

module rc522Body()
{

    union()
    {
        rc522Board();
        rc522Bracket();
    }

}


//=============================================================================
// VOLUMEN DE SEGURIDAD DE CABLEADO
//
// Espacio reservado tras la placa para el conexionado hacia el
// adaptador ESP32 (SPI + alimentación).
//=============================================================================

module rc522CableKeepout(length = 25)
{

    color(rc522CableColor)

    translate([
        -nfc_reader_width/4,
        nfc_reader_depth,
        -10
    ])

        cube([
            nfc_reader_width/2,
            length,
            20
        ]);

}


//=============================================================================
// CONJUNTO COMPLETO (visualización)
//=============================================================================

module rc522()
{

    rc522Body();

    rc522CableKeepout();

}


//=============================================================================
// PREVIEW
//=============================================================================

rc522();
