//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : nfc_panel.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel NFC — pieza EXTRAÍBLE/intercambiable, fijada por imanes
// (docs/02_Mechanical_Layout.md, sección 6: "Panel NFC: Imanes.").
// Sustituye a front_panel.scad/front_layout.scad (obsoletos).
//
// Ocupa prácticamente todo el ancho frontal (docs/02_Mechanical_Layout.md,
// sección 3: "Panel NFC: Ocupará prácticamente todo el ancho
// frontal."), con el borde llegando exactamente a la cara interior de
// las paredes laterales, donde están embebidos los imanes
// (openscad/parts/02_chassis/walls.scad, frontMagnetCuts()).
//
// Lleva la ventana/alojamiento del tag NFC, centrada, a media altura
// del panel — el RC522 queda detrás, sujeto al bastidor (no a este
// panel), separado 3 mm (ya verificado, ver
// docs/Virtual_Assembly_Report.md).
//
// Sistema de coordenadas: igual que assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del cascarón.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 48;

part_version = "1.0";


//=============================================================================
// PARÁMETROS DE ESTA PIEZA
//=============================================================================

nfc_tag_pocket_depth = 1.5;  // Dato real confirmado por el usuario (2026-08-03)
nfc_magnet_diameter  = magnet_diameter + magnet_clearance;


//=============================================================================
// PLACA MACIZA
//=============================================================================

module nfcPanelSolid()
{

    translate([
        -nfc_panel_width/2,
        -case_depth/2,
        nfc_panel_z_low
    ])

        cube([
            nfc_panel_width,
            front_panel_thickness,
            nfc_panel_height
        ]);

}


//=============================================================================
// MARCO ELEVADO (bisel) — puramente añadido hacia fuera, ver nota en
// 00_parametros.scad (front_bezel_depth/front_bezel_border). No toca
// front_panel_thickness ni la cara que mira a la pared.
//=============================================================================

module nfcPanelBezel()
{

    // PEDIDO POR EL USUARIO (2026-08-03): sin marco en el borde
    // donde este panel conecta con el inferior (el inferior de este
    // panel) — mismo criterio que lowerPanelBezel(), para que el
    // marco sea continuo entre ambos.
    translate([
        -nfc_panel_width/2,
        -case_depth/2 - front_bezel_depth,
        nfc_panel_z_low
    ])

        difference()
        {

            cube([nfc_panel_width, front_bezel_depth, nfc_panel_height]);

            translate([front_bezel_border, -0.1, -0.1])
                cube([
                    nfc_panel_width - 2*front_bezel_border,
                    front_bezel_depth + 0.2,
                    nfc_panel_height - front_bezel_border + 0.1
                ]);

        }

}


//=============================================================================
// LOGO ESTILO STEAM (relieve decorativo)
//
// PEDIDO POR EL USUARIO (2026-08-03): "diseñes un panel superior
// (NFC) con la carátula de Steam. La base del panel en negro y el
// anagrama en otro color". Diseño propio, hecho a mano en OpenSCAD
// (no es un archivo importado ni una imagen trazada) — una
// interpretación estilizada del icono, no una réplica exacta.
//
// Se imprime en relieve (sobresale steam_logo_depth de la cara
// frontal) para poder pintarlo de otro color en el laminador con la
// herramienta de "pintado por geometría/cara" (no por rango de
// altura, como se hizo con la franja LED — ahí el color cambiaba
// por planos horizontales; aquí es una forma 2D en un mismo plano,
// necesita seleccionarse por superficie).
//=============================================================================

// Escala recalculada para la nueva geometría (ancho:alto ≈ 2,25:1,
// más ancho que la versión anterior) — aquí el ANCHO es el límite,
// no el alto (antes 4,0, calculado para la versión anterior con
// otra proporción). Ancho natural del diseño: 1273px * steam_logo_px
// ≈ 84,9 unidades a s=1. Con 134mm de ancho útil disponible (142mm
// menos margen), escala ≈ 134/84,9 ≈ 1,58.
// PEDIDO POR EL USUARIO (2026-08-03): "el logo lo reduciría a la
// mitad centrando este en el espacio disponible" — antes 1,58
// (ocupaba casi toda la anchura). El texto se queda fijo (tamaño y
// posición) según pidió el usuario ("las letras tal y como están").
steam_logo_scale = 0.79;
steam_logo_depth = 0.6;   // ESTIMADO — profundidad del relieve, típica para un emblema/insignia
steam_logo_height = 565 * (1/15) * steam_logo_scale;  // alto real del icono (565px medidos, convertidos con steam_logo_px) — verificado por geometría exportada: 59,5mm a escala 1,58

// PEDIDO POR EL USUARIO (2026-08-03): "no podríamos hacer algo así"
// (aportó la imagen oficial del icono). Medidas tomadas directamente
// sobre esa imagen (recorte a escala, coordenadas leídas con una
// cuadrícula de referencia superpuesta) — sigue siendo un diseño
// propio hecho a mano en OpenSCAD, no un archivo importado ni un
// trazado automático de la imagen, pero ahora con proporciones mucho
// más fieles: anillo pequeño arriba-izquierda CON hueco, anillo
// grande arriba-derecha CERRADO, eje pequeño abajo-centro CON hueco,
// unidos por un brazo acodado en dos tramos.
steam_logo_px = 1/15;  // conversión de las coordenadas medidas (en píxeles del recorte) a unidades del modelo

module steamLogo2D(s=1)
{

    scale(s*steam_logo_px)
    {

        // Anillo superior izquierdo (con hueco hacia la derecha)
        translate([155,-205])
            difference()
            {
                difference()
                {
                    circle(r=118);
                    circle(r=72);
                }
                rotate([0,0,15])
                    translate([118*0.6,0,0])
                        square([118*1.4, 140], center=true);
            }

        // Anillo superior derecho (cerrado, sin hueco)
        translate([1150,-195])
            difference()
            {
                circle(r=160);
                circle(r=80);
            }

        // Eje inferior (con hueco hacia arriba-izquierda)
        translate([890,-500])
            difference()
            {
                difference()
                {
                    circle(r=100);
                    circle(r=63);
                }
                rotate([0,0,-155])
                    translate([100*0.6,0,0])
                        square([100*1.4, 100], center=true);
            }

        // Brazo 1: anillo izquierdo -> eje
        hull()
        {
            translate([230,-280]) circle(r=58);
            translate([790,-410]) circle(r=58);
        }

        // Brazo 2: eje -> anillo derecho
        hull()
        {
            translate([980,-400]) circle(r=58);
            translate([1075,-300]) circle(r=58);
        }

    }

}

module steamLogoEmboss()
{

    // El contorno del logo no es simétrico respecto a su propio
    // origen — se compensa con logoCenterX/Z (calculados sobre la
    // caja delimitadora real de la nueva geometría) para que el
    // conjunto quede centrado de verdad en el panel.
    //
    // PEDIDO POR EL USUARIO (2026-08-03): "el logo lo reduciría a la
    // mitad centrando este en el espacio disponible" — ahora el
    // icono se centra en el hueco libre entre el texto (posición
    // fija, ver steamOsText()) y el marco superior, en vez de
    // anclarse arriba.
    logoCenterX = 44.9  * steam_logo_scale;
    logoCenterZ = -21.17 * steam_logo_scale;

    iconH = steam_logo_height * steam_logo_scale;

    availTop    = nfc_panel_z_high - front_bezel_border - 2;
    availBottom = steam_text_top_z + steam_text_gap;
    iconCenterZTarget = (availTop + availBottom) / 2;

    translate([
        -logoCenterX,
        -case_depth/2,
        iconCenterZTarget - logoCenterZ
    ])

        rotate([90,0,0])

            linear_extrude(steam_logo_depth)

                steamLogo2D(steam_logo_scale);

}


//=============================================================================
// TEXTO "STEAM OS" (relieve decorativo, debajo del emblema)
//=============================================================================

steam_text_height = 12;  // ESTIMADO — alto de letra
steam_text_gap    = 4.5;   // ESTIMADO — separación entre el icono y el texto
steam_text_bottom_margin = 2;  // margen sobre el borde inferior del panel

// PEDIDO POR EL USUARIO (2026-08-03): "las letras tal y como están"
// — posición del texto FIJA (anclada cerca del borde inferior),
// independiente del icono (antes se calculaba a partir de la
// posición del icono). steam_text_top_z se usa desde
// steamLogoEmboss() para saber dónde empieza el hueco libre.
steam_text_top_z = nfc_panel_z_low + steam_text_bottom_margin + steam_text_height;

module steamOsText()
{

    textCenterZ = nfc_panel_z_low + steam_text_bottom_margin + steam_text_height/2;

    translate([
        0,
        -case_depth/2,
        textCenterZ
    ])

        rotate([90,0,0])

            linear_extrude(steam_logo_depth)

                text(
                    "STEAM  OS",
                    size = steam_text_height * 1.15,
                    font = "Liberation Sans:style=Bold",
                    spacing = 1.05,
                    halign = "center",
                    valign = "center"
                );

}



//
// Hueco trasero (no pasante) para pegar el tag — FALLO CORREGIDO
// (2026-08-03, pregunta del usuario: "¿sigue alineado con su
// lector?"): antes centrado en nfc_panel_z_mid, que se desplazó al
// ampliar la altura del panel. El lector (rc522_bracket.scad) YA
// ESTÁ IMPRESO con la posición antigua (Z=93,75) — este hueco se fija
// al mismo valor absoluto (ver rc522_pos, assembly_positions.scad),
// no a nfc_panel_z_mid.
//=============================================================================

// PEDIDO POR EL USUARIO (2026-08-03): "la etiqueta NFC es de tipo
// llavero con forma parecida a una pera... consideras mejor
// modificarlo" — medidas reales dadas por el usuario (40 x 32mm) y
// foto de referencia. Antes era un rectángulo genérico (60x40mm,
// mucho más grande que el llavero real), lo que dejaba holgura de
// sobra para que el tag se desplazase antes de fraguar el pegamento.
// Ahora: círculo principal (32mm, el ancho del llavero) + una cola
// más estrecha que añade el resto hasta los 40mm de largo — un
// alojamiento ajustado, con 0,75mm de holgura para que entre bien
// pero sin apenas margen para moverse.
nfc_tag_head_diameter = 32.0;
nfc_tag_length        = 40.0;
nfc_tag_pocket_clearance = 0.75;  // ESTIMADO — holgura para que el tag entre sin apretar
nfc_tag_pocket_z = 93.75;  // fijo — debe coincidir con rc522_pos[2] (assembly_positions.scad)

module nfcTagPocket()
{

    headR = nfc_tag_head_diameter/2 + nfc_tag_pocket_clearance;
    tailR = nfc_tag_head_diameter/2 * 0.45 + nfc_tag_pocket_clearance;  // ESTIMADO — la cola es más estrecha que el cuerpo circular, según la foto
    tailExtra = nfc_tag_length - nfc_tag_head_diameter;

    // Distancia del centro del circulo principal a la punta de la
    // cola (ver más allá del propio circulo, hasta el largo total)
    tailCenterDist = nfc_tag_head_diameter/2 + tailExtra - tailR;

    translate([
        0,
        -case_depth/2 + front_panel_thickness - nfc_tag_pocket_depth,
        nfc_tag_pocket_z
    ])

        rotate([-90,0,0])

            linear_extrude(nfc_tag_pocket_depth + 0.1)

                hull()
                {
                    circle(r = headR);

                    // la cola apunta hacia abajo (Z-) — orientación
                    // razonable por defecto, fácilmente ajustable
                    translate([0, tailCenterDist])
                        circle(r = tailR);
                }

}


//=============================================================================
// IMANES — ALOJAMIENTO CIEGO, SIN SOBRESALIR
//
// FALLO CORREGIDO (2026-08-03, tres rondas de aviso del usuario):
// primero una muesca cuadrada visible, luego un saliente redondo
// hacia el exterior (bulto), luego sin ningún alojamiento en
// absoluto ("no tiene encajes para los imanes") — ninguna de las
// tres era aceptable.
//
// El alojamiento del imán en la pared (walls.scad, frontMagnetCuts())
// se reculó 3 mm y se abre justo en la cara INTERIOR del panel
// (Y=-78,2), creciendo desde ahí hacia el interior de la pared. Si el
// alojamiento del panel TAMBIÉN creciera desde ese mismo punto hacia
// el interior, invadiría el mismo hueco que ya ocupa el imán de la
// pared — no pueden compartir el mismo espacio. Por eso el
// alojamiento del panel tiene que quedarse DENTRO de su propio
// grosor (Y -81,2 a -78,2), sin sobresalir por detrás.
//
// Con eso, un imán del grosor estándar del proyecto (magnet_height =
// 3 mm, igual que el grosor del panel) no cabe con piel delante — el
// alojamiento aquí es más fino (nfc_magnet_pocket_depth = 1,5 mm),
// pensado para una arandela de acero o un imán delgado, no el imán
// de 3 mm usado en la pared. Deja 1,5 mm de piel sólida por delante,
// oculta desde fuera.
//
// PENDIENTE DE CONFIRMAR: el grosor real de la arandela/imán que se
// vaya a usar aquí — 1,5 mm es una estimación con margen razonable,
// no una medida real confirmada.
//=============================================================================

// FALLO CORREGIDO (2026-08-03, pregunta del usuario: "¿has tenido en
// cuenta la ubicación de los imanes?"): se calculaban a partir de
// nfc_panel_z_low/z_high — al ampliar la altura del panel 12mm, el
// imán superior se desplazó de Z=121 a Z=133, un desajuste de 12mm
// frente al imán de la pared REAL ya impresa (fijo en Z=121).
// Fijados a los mismos valores absolutos que front_magnet_z_low/high
// en walls.scad — DEBEN coincidir siempre entre ambos archivos.
nfc_magnet_z_low  = 66.5;
nfc_magnet_z_high = 121.0;

nfc_magnet_pocket_depth    = 1.5;  // ESTIMADO — pendiente de confirmar el grosor real de la arandela/imán
nfc_magnet_pocket_diameter = magnet_diameter + magnet_clearance;

// FALLO CORREGIDO (2026-08-03, captura del usuario): la X se copiaba
// directamente de sideMountGlobalX(), la misma fórmula que usa la
// pared — válida ahí porque la pared llega hasta X=78, pero el panel
// NFC solo llega hasta X=nfc_panel_width/2=75. Con esa X (72,925) el
// alojamiento se salía 2 mm por el borde del panel. Ahora se calcula
// con margen respecto al borde REAL del panel, no respecto al de la
// pared — coincide de forma aproximada, no exacta, con el imán de la
// pared, inevitable si el alojamiento tiene que caber entero dentro
// del panel.
//
// AJUSTADO (2026-08-16, petición del usuario tras reducir el ancho
// del panel a 149mm): "pon los encastres de los imanes lo más
// cercanos posible a los extremos, entre 1 y 1,5mm del borde" — al
// estrechar el panel, el desajuste frente al imán de la pared subía
// a 4mm (39% de solape entre los dos imanes, de 8mm de diámetro).
// Reducido al extremo más ajustado del rango pedido (1mm en vez de
// 1,5mm) para acercar el imán todo lo posible — sube el solape a
// ~46%.
nfc_magnet_edge_margin = 1.0;  // antes 1.5

module nfcMagnetPockets()
{

    magnetX = nfc_panel_width/2 - nfc_magnet_edge_margin - nfc_magnet_pocket_diameter/2;

    for(ix=[-1,1])
    for(z=[nfc_magnet_z_low, nfc_magnet_z_high])

        translate([
            ix*magnetX,
            -case_depth/2 + front_panel_thickness - nfc_magnet_pocket_depth,
            z
        ])

            rotate([-90,0,0])
                cylinder(d = nfc_magnet_pocket_diameter, h = nfc_magnet_pocket_depth + 0.1);

}


//=============================================================================
// PANEL NFC COMPLETO
//=============================================================================

// REORGANIZADO (2026-08-03, petición del usuario: "vamos a hacer
// diferentes paneles con diferentes temas, con cada etiqueta NFC el
// sistema arrancará un sistema u otro") — se separa la base
// compartida (nfcPanelBase(), sin marca) de la parte de la marca
// (steamLogoEmboss()/steamOsText() en este archivo), para poder
// reutilizar la base en otros archivos de tema (p. ej.
// nfc_panel_retrobat.scad) sin repetir código.
module nfcPanelBase()
{

    union()
    {

        difference()
        {

            nfcPanelSolid();

            nfcTagPocket();

            nfcMagnetPockets();

        }

        nfcPanelBezel();

    }

}

module nfcPanel()
{

    union()
    {

        nfcPanelBase();

        steamLogoEmboss();

        steamOsText();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color([0.1,0.1,0.1,1])
    nfcPanel();
