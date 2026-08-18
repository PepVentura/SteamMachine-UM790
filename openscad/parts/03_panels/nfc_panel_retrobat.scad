//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel_retrobat.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — TEMA RETROBAT. Reutiliza la base compartida de
// nfc_panel.scad (nfcPanelBase(): sólido, marco, ventana del tag,
// imanes) y añade su propia marca — parte del sistema de "un panel
// por sistema" del usuario: cada etiqueta NFC / panel arranca un
// sistema distinto (Steam, RetroBat, ...).
//
// Logo medido directamente sobre la imagen oficial de RetroBat
// aportada por el usuario (extracción de contorno por análisis de
// píxeles, mismo método que steamLogo2D() en nfc_panel.scad) — sigue
// siendo geometría propia generada en OpenSCAD, no un archivo
// importado ni un trazado vectorial automático de la imagen.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

use <nfc_panel.scad>;

$fn = 64;

//=============================================================================
// LOGO RETROBAT (alas de murciélago + mando de consola)
//=============================================================================

retrobat_logo_scale = 0.26;  // reducido ligeramente para dejar hueco seguro al texto (ver nota en retrobat_text_gap)
retrobat_logo_depth = 0.6;    // ESTIMADO — misma profundidad que el emblema de Steam
retrobat_logo_natural_w = 202;
retrobat_logo_natural_h = 235;
retrobat_logo_natural_cx = 128.0;
retrobat_logo_natural_cy = 130.5;

module retrobatSilhouette()
{
    polygon(points=[
        [28,248],[39,230],[43,215],[42,191],[33,173],[48,168],[60,152],
        [61,114],[73,119],[83,118],[103,102],[58,99],[35,83],[27,65],
        [27,49],[38,27],[54,16],[67,13],[91,18],[109,36],[147,36],
        [162,20],[184,13],[199,15],[213,22],[229,47],[229,67],[223,81],
        [214,91],[199,99],[154,102],[174,118],[196,114],[194,140],
        [197,153],[205,165],[223,173],[215,189],[213,211],[218,231],
        [229,248],[192,231],[164,203],[149,176],[161,156],[160,136],
        [148,119],[136,113],[113,116],[97,135],[96,158],[108,175],
        [91,205],[66,230]
    ]);
}

module retrobatDpadCutout()
{
    polygon(points=[
        [63,81],[75,81],[76,68],[88,68],[90,66],[90,55],[88,53],
        [76,53],[75,40],[63,40],[62,53],[48,54],[48,67],[62,68]
    ]);
}

module retrobatButtonsCutout()
{
    translate([190,40]) circle(r=9);
    translate([208,58]) circle(r=9);
    translate([172,58]) circle(r=8.5);
    translate([190,76]) circle(r=9);
}

module retrobatLogo2D(s=1)
{
    scale(s)
        translate([-retrobat_logo_natural_cx, -retrobat_logo_natural_cy])
            difference()
            {
                retrobatSilhouette();
                retrobatDpadCutout();
                retrobatButtonsCutout();
            }
}

module retrobatLogoEmboss()
{

    iconTopZ = nfc_panel_z_high - front_bezel_border - 2;
    iconH    = retrobat_logo_natural_h * retrobat_logo_scale;

    translate([
        0,
        -case_depth/2,
        iconTopZ - iconH/2
    ])

        rotate([90,0,0])

            linear_extrude(retrobat_logo_depth)

                retrobatLogo2D(retrobat_logo_scale);

}


//=============================================================================
// TEXTO "RETROBAT" (relieve decorativo, debajo del logo)
//=============================================================================

retrobat_text_height = 12;
retrobat_text_gap    = 1.5;  // FALLO CORREGIDO (2026-08-03): con el hueco original (4,5mm, copiado del panel Steam) el texto se salía por el borde inferior — la fuente real de "RETROBAT" es más alta de lo estimado. Ajustado junto con retrobat_logo_scale para que quepan ambos con margen por los dos lados.

module retrobatText()
{

    iconTopZ    = nfc_panel_z_high - front_bezel_border - 2;
    iconH       = retrobat_logo_natural_h * retrobat_logo_scale;
    iconBottomZ = iconTopZ - iconH;
    textCenterZ = iconBottomZ - retrobat_text_gap - retrobat_text_height/2;

    translate([
        0,
        -case_depth/2,
        textCenterZ
    ])

        rotate([90,0,0])

            linear_extrude(retrobat_logo_depth)

                text(
                    "RETROBAT",
                    size = retrobat_text_height * 1.15,
                    font = "Liberation Sans:style=Bold",
                    spacing = 1.05,
                    halign = "center",
                    valign = "center"
                );

}


//=============================================================================
// PANEL COMPLETO (tema RetroBat)
//=============================================================================

module nfcPanelRetrobat()
{

    union()
    {

        nfcPanelBase();

        retrobatLogoEmboss();

        retrobatText();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color([0.1,0.1,0.1,1])
    nfcPanelRetrobat();
