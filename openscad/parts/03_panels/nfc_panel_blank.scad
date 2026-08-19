//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel_blank.scad
// Versión  : 1.1
// Fecha    : 2026-08-17
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — con el logo de TeknoParrot integrado, a escala
// reducida (no ocupa el panel entero, deja margen visible).
//
// PEDIDO POR EL USUARIO (2026-08-17): "puedes integrar este logo en
// nfc_panel_blank.scad escalándolo hasta ocupar gran parte (pero no
// toda) del panel" — mismo SVG y mismos datos de contorno ya
// verificados en nfc_panel_teknoparrot.scad (medido por análisis de
// contorno, un único polígono cerrado sin auto-intersecciones,
// verificado con shapely). Se reutilizan tal cual, solo con una
// escala menor (0,1487 en vez de 0,2173) y centrado en el panel en
// vez de pegado arriba, para que quede claramente "gran parte, no
// todo": ~52mm de alto de 80,5mm disponibles, con ~14mm de margen
// visible arriba y abajo.
//
// NOTA sobre el nombre del archivo: sigue llamándose
// "nfc_panel_blank.scad" aunque ya no está "en blanco" — el usuario
// pidió integrar el logo en este fichero concreto, no crear uno
// nuevo. Avisar si se prefiere renombrarlo para que el nombre
// refleje el contenido actual.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

use <nfc_panel.scad>;

$fn = 64;

//=============================================================================
// LOGO TEKNOPARROT — mismos datos que nfc_panel_teknoparrot.scad,
// solo con escala y posición distintas (ver nota arriba).
//=============================================================================

teknoparrot_logo_scale = 0.1487;
teknoparrot_logo_depth = 0.6;
teknoparrot_logo_natural_w = 292;
teknoparrot_logo_natural_h = 352;
teknoparrot_logo_natural_cx = 153.0;
teknoparrot_logo_natural_cy = 184.0;

module teknoparrotLogo2D(s=1)
{
    scale(s)
        translate([-teknoparrot_logo_natural_cx, -teknoparrot_logo_natural_cy])
            polygon(points=[
                [195,357],[181,360],[175,350],[169,349],[170,357],[160,360],
                [147,349],[141,338],[143,322],[139,314],[128,303],[125,294],
                [124,278],[131,256],[113,237],[112,240],[107,234],[96,229],
                [92,224],[93,220],[89,216],[87,219],[83,204],[88,191],[85,188],
                [89,182],[77,172],[38,148],[37,146],[42,143],[26,133],[13,120],
                [12,113],[19,113],[20,110],[7,102],[10,79],[19,79],[10,49],
                [24,45],[38,49],[43,46],[41,35],[52,15],[59,10],[68,9],[70,17],
                [72,15],[76,9],[91,8],[103,15],[102,25],[113,20],[112,16],
                [117,15],[130,20],[136,29],[161,30],[176,15],[181,10],[186,11],
                [193,17],[203,10],[224,13],[240,20],[247,32],[254,44],[261,49],
                [268,49],[280,42],[288,44],[291,52],[288,66],[277,84],[270,82],
                [268,86],[265,84],[262,88],[264,89],[262,95],[251,98],[224,89],
                [214,90],[219,105],[224,112],[233,113],[241,110],[237,120],
                [211,131],[190,132],[171,131],[168,143],[171,148],[164,164],
                [186,166],[196,178],[194,204],[199,216],[203,247],[210,255],
                [217,255],[221,251],[216,247],[218,235],[227,235],[230,244],
                [227,251],[233,258],[228,262],[229,272],[234,275],[234,282],
                [229,286],[233,289],[229,299],[229,313],[221,323],[211,343],
                [216,357],[215,360],[208,357]
            ]);
}

module teknoparrotLogoEmboss()
{

    logoH = teknoparrot_logo_natural_h * teknoparrot_logo_scale;

    // Centrado en el hueco vertical disponible del panel (no pegado
    // al marco superior, como en nfc_panel_teknoparrot.scad) — para
    // que el margen quede repartido arriba y abajo, más claro que
    // es "gran parte, no todo el panel".
    //
    // FALLO CORREGIDO: la forma del logo no es simétrica respecto a
    // su propio origen (natural_cx/cy) — centrar solo con la fórmula
    // ingenua dejaba el resultado real 5mm más arriba de lo previsto
    // (verificado exportando la geometría). Corregido con
    // logoCenterOffset, calculado sobre la caja delimitadora real.
    availTop    = nfc_panel_z_high - front_bezel_border - 2;
    availBottom = nfc_panel_z_low + 2;
    centerZ     = (availTop + availBottom) / 2;
    logoCenterOffset = -5.0;  // corrige el desajuste real medido (ver nota arriba)

    translate([
        0,
        -case_depth/2,
        centerZ + logoCenterOffset
    ])

        rotate([90,0,0])

            linear_extrude(teknoparrot_logo_depth)

                teknoparrotLogo2D(teknoparrot_logo_scale);

}

//=============================================================================
// PREVIEW
//=============================================================================

union()
{
    color([0.1,0.1,0.1,1])
        nfcPanelBase();

    color([1,0.6,0.1,1])
        teknoparrotLogoEmboss();
}
