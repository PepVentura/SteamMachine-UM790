//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : ribs.scad
// Versión : 8.0
//
// Nervios estructurales de la bandeja.
//
// ============================================================================

include <../../../00_parametros.scad>;

$fn = 64;


//=============================================================================
// NERVIO ENTRE DOS PUNTOS
//=============================================================================

module rib(x1, y1, x2, y2, width=rib_width, height=rib_height)
{

    dx = x2 - x1;
    dy = y2 - y1;

    len = sqrt(dx*dx + dy*dy);

    angle = atan2(dy, dx);

    translate([x1, y1, tray_thickness])

        rotate([0,0,angle])

            cube(
            [
                len,
                width,
                height
            ]);

}


//=============================================================================
// NERVIOS
//=============================================================================

module ribs()
{

    //---------------------------------------------------------
    // Horizontal superior
    //
    // PEDIDO POR EL USUARIO (2026-08-03, marcado en una captura de
    // su laminador): toca el disipador inferior del UM790 — altura
    // rebajada 3mm (5 → 2mm).
    //---------------------------------------------------------

    rib(
        -off_x,
         off_y-rib_width/2,

         off_x,
         off_y-rib_width/2,

         rib_width,
         rib_height - 3
    );


    //---------------------------------------------------------
    // Horizontal inferior — ELIMINADO (2026-08-03, petición del
    // usuario, marcado en una captura de su laminador): chocaba con
    // el conector USB interno y el pulsador de la placa UM790. Es el
    // mismo nervio que ya se había identificado por la proximidad
    // con el disipador tras el desplazamiento de los postes.
    //---------------------------------------------------------


    //---------------------------------------------------------
    // Vertical izquierdo
    //
    // FALLO CORREGIDO (2026-08-03, aviso del usuario: "mover tray y
    // posts para que no tapen los orificios de sujeción"): con el
    // ancho normal (3mm), el borde de este nervio quedaba a solo
    // 0,5mm del taladro de paso al pilar del suelo — el nervio, al
    // ser 5mm más alto que el taladro, tapaba parcialmente el acceso
    // en ángulo con el destornillador. Estrechado a 1,7mm y
    // reposicionado; sigue conectando con la isla (que llega hasta
    // mucho más allá), dejando ~2mm de separación real con el
    // taladro. Verificado con la geometría exportada, no solo
    // calculado — los valores exactos de ancho/desplazamiento de un
    // nervio rotado no son intuitivos.
    //---------------------------------------------------------

    translate([1.7,0,0])

    rib(
        -off_x,
        -off_y,

        -off_x,
         off_y,
         1.7
    );


    //---------------------------------------------------------
    // Vertical derecho
    //
    // FALLO CORREGIDO (2026-08-03, aviso del usuario: "mover tray y
    // posts para que no tapen los orificios de sujeción"): con el
    // ancho normal (3mm), el borde de este nervio quedaba a solo
    // 0,5mm del taladro de paso al pilar del suelo — el nervio, al
    // ser 5mm más alto que el taladro, tapaba parcialmente el acceso
    // en ángulo con el destornillador. Estrechado a 1,7mm; sigue
    // conectando con la isla (que llega hasta mucho más allá),
    // dejando ~1,8mm de separación real con el taladro. Verificado
    // con la geometría exportada, no solo calculado.
    //---------------------------------------------------------

    rib(
         off_x,
        -off_y,

         off_x,
         off_y,
         1.7
    );


    //---------------------------------------------------------
    // Cruz central horizontal
    //
    // PEDIDO POR EL USUARIO (2026-08-03, tras imprimir la bandeja
    // real): toca la parte inferior del UM790 — rebajada a la misma
    // altura que el horizontal superior (2mm), la pieza equivalente
    // más cercana a la parte trasera.
    //---------------------------------------------------------

    rib(
        -off_x,
        -rib_width/2,

         off_x,
        -rib_width/2,

         rib_width,
         rib_height - 3
    );


    //---------------------------------------------------------
    // Cruz central vertical
    //
    // PEDIDO POR EL USUARIO (2026-08-03, marcado en una captura de
    // su laminador): toca el disipador inferior del UM790 — altura
    // rebajada 3mm (5 → 2mm), igual que el horizontal superior.
    //---------------------------------------------------------

    translate([-rib_width/2,0,0])

    rib(
        0,
        -off_y,

        0,
         off_y,

         rib_width,
         rib_height - 3
    );

}


//=============================================================================
// PREVIEW
//=============================================================================

color("RoyalBlue")
ribs();
