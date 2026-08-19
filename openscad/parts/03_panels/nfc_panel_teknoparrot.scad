//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel_teknoparrot.scad
// Versión  : 0.1 (BORRADOR — pendiente del icono del loro)
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — TEMA TEKNOPARROT. Reutiliza la base compartida de
// nfc_panel.scad (nfcPanelBase()), igual que nfc_panel_retrobat.scad.
//
// ESTADO: el texto "TEKNOPARROT" ya está listo y verificado. El
// icono del loro está PENDIENTE — no he podido acceder a una imagen
// del logo con el detalle de píxel necesario para medirlo con
// precisión (como sí se hizo con Steam y RetroBat, ambos aportados
// directamente por el usuario). En cuanto se suba una imagen de
// referencia, se mide igual que los otros dos temas y se rellena
// teknoparrotLogo2D()/teknoparrotLogoEmboss() más abajo.
//
// Colores oficiales de la marca (de teknoparrot.com, por si ayudan a
// elegir el filamento): azul "Chambray" #2F5B89, crema "White Linen"
// #F8F3E8, azul marino "Blue Zodiac" #0A1E32.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

use <nfc_panel.scad>;

$fn = 64;

//=============================================================================
// LOGO TEKNOPARROT — PENDIENTE
//
// Placeholder vacío hasta tener la imagen de referencia. Mismo
// criterio de espacio que Steam/RetroBat: icono arriba (hasta 64mm
// de alto disponibles), texto "TEKNOPARROT" debajo.
//=============================================================================

//=============================================================================
// LOGO TEKNOPARROT (loro pirata + texto integrado en el diseño)
//
// PEDIDO POR EL USUARIO (2026-08-03): "Podrías modificar el panel de
// teknoparrot con el anagrama del fichero adjunto" — el usuario
// aportó un SVG limpio (teknoparrot-logo.svg, creado con Inkscape,
// con un diseño a color de líneas limpias — no una foto de una pieza
// física como la primera versión). Aunque el SVG en sí envolvía una
// imagen PNG incrustada (no rutas vectoriales puras), la imagen es
// mucho más limpia que la foto anterior — se ha vuelto a medir por
// análisis de contorno (máscara por canal alfa + simplificación de
// polígono), sustituyendo la silueta anterior por completo.
//
// El texto "TEKNO PARROT" sigue viniendo integrado en el propio
// diseño (no hace falta texto aparte). Sigue siendo UN ÚNICO
// contorno cerrado (mismo criterio que la versión anterior, para el
// "llenar" del laminador).
//
// PEDIDO POR EL USUARIO: "ajustar el tamaño para que ocupe gran
// parte del panel" — escala calculada para ocupar la altura útil
// completa del panel.
//=============================================================================

teknoparrot_logo_scale = 0.2173;  // ajustado para ocupar la altura útil completa del panel (80,5mm menos margen de seguridad)
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
    logoTopZ = nfc_panel_z_high - front_bezel_border - 2;

    translate([
        0,
        -case_depth/2,
        logoTopZ - logoH/2
    ])

        rotate([90,0,0])

            linear_extrude(teknoparrot_logo_depth)

                teknoparrotLogo2D(teknoparrot_logo_scale);

}


//=============================================================================
// TEXTO SEPARADO — NO HACE FALTA
//
// A diferencia de Steam/RetroBat, aquí "TEKNO PARROT" ya viene
// integrado en el propio contorno del logo (ver nota en
// teknoparrotLogo2D() más arriba) — no se añade un texto aparte para
// no duplicarlo.
//=============================================================================


//=============================================================================
// PANEL COMPLETO (tema TeknoParrot)
//=============================================================================

module nfcPanelTeknoParrot()
{

    union()
    {

        nfcPanelBase();

        teknoparrotLogoEmboss();

    }

}


//=============================================================================
// PREVIEW (base + emblema en color distinto, para ver el resultado
// con más contraste — el acabado real depende del filamento elegido
// en el laminador)
//=============================================================================

color([0.15,0.15,0.15,1])
    nfcPanelBase();

color([1,0.6,0.1,1])
    teknoparrotLogoEmboss();
