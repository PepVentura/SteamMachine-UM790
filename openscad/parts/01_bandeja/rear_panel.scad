//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : rear_panel.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel trasero — va UNIDO A LA BANDEJA, no al chasis fijo
// (docs/DESIGN_RULES.md: "El panel trasero irá unido a la bandeja.
// Al extraer la bandeja saldrá también el panel trasero.").
//
// Incluye el recorte de acceso a la IO trasera del UM790
// (conectores: RJ45/USB/alimentación), en la posición ya validada en
// el ensamblaje virtual (um790_pos, um790_rearIO_*, ver
// openscad/reference/components/assembly_positions.scad y um790.scad).
//
// Sistema de coordenadas: igual que
// openscad/reference/components/assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del chasis.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// MARGEN DE RECORTE DE LA IO TRASERA
//=============================================================================

rear_io_cut_margin = 0.5;  // holgura alrededor de cada conector — reducido de 1mm: con la disposición real del plano, el hueco natural más ajustado (RJ45-USB, 1,75mm) se fusionaba incluso con 1mm de margen. Con 0,5mm queda un separador real de ~0,75mm en el punto más justo.


//=============================================================================
// PLACA MACIZA
//=============================================================================

// AJUSTADO (2026-08-16, mismo criterio que nfc_panel_width y
// lower_panel_width_oversize, confirmado con probeta real): el
// hueco interior real del chasis mide 149mm, no 150mm — mismo
// ajuste aplicado aquí para que los tres paneles frontales/trasero
// coincidan. rear_panel_width definido en 00_parametros.scad (no
// aquí) para que probeta_panel_trasero.scad pueda reutilizar el
// mismo valor sin depender de un `use` a este archivo (las
// variables no se exponen con `use`, solo los módulos).

module rearPanelSolid()
{

    // FALLO CORREGIDO (2026-08-03): el panel arrancaba en Z=0, el
    // mismo espacio que ya ocupa el suelo del chasis fijo (floor.scad)
    // en su borde trasero — colisión real entre dos piezas distintas.
    // Ahora arranca en bottom_thickness, apoyado ENCIMA del suelo, no
    // dentro de él.
    //
    // FALLO CORREGIDO (2026-08-03): el ancho (case_width = 156 mm)
    // solapaba el propio grosor de las paredes laterales (que ocupan
    // X desde ±75 hasta ±78) — colisión real de volumen, no un simple
    // contacto. El panel debe encajar ENTRE las paredes, no
    // solaparlas: ancho corregido a case_width - 2*wall_thickness
    // (150 mm), igual que la bandeja (tray_width) y el panel NFC
    // (nfc_panel_width).
    translate([
        -rear_panel_width/2,
        case_depth/2 - wall_thickness,
        bottom_thickness
    ])

        cube([rear_panel_width, wall_thickness, shell_height-bottom_thickness]);

}


//=============================================================================
// RECORTE DE LA IO TRASERA DEL UM790
//
// Posición derivada de um790_pos (assembly_positions.scad) y de las
// dimensiones del bloque de IO trasera definidas en um790.scad
// (um790_rearIO_width/height, 00_parametros.scad), con un margen para
// que los conectores sean accesibles sin rozar el borde impreso.
//=============================================================================

//=============================================================================
// RECORTES INDIVIDUALES DE CADA CONECTOR DE LA IO TRASERA DEL UM790
//
// PEDIDO POR EL USUARIO (2026-08-03): cada conector con su propio
// recorte, delimitado a su tamaño real (no un hueco genérico).
//
// ACTUALIZADO (2026-08-03, foto real con regla aportada por el
// usuario: "el panel trasero no se adapta a la realidad") — el
// "plano de distribución" de texto usado antes tenía un orden y
// agrupación que NO coinciden con la placa real. Sustituido por la
// disposición que se ve directamente en la foto:
//
//   Orden real, de izquierda a derecha (vista desde atrás, mirando
//   los conectores de frente): USB×2 (apilados verticalmente) |
//   USB×2 (apilados verticalmente) | RJ45 | HDMI | HDMI (uno junto
//   al otro, NO apilados) | conector de alimentación DC.
//
// Esto corrige dos fallos de la versión anterior (basada en el plano
// de texto, que resultó no coincidir): el orden estaba invertido
// (DC-HDMI-RJ45-USB en vez de USB-RJ45-HDMI-DC) y los HDMI estaban
// apilados verticalmente en vez de uno al lado del otro.
//
// Ancho total: estimado con la regla visible en la foto (~108mm) —
// coincide razonablemente con la suma de los tamaños estándar de
// cada conector más separaciones (~102mm), así que la escala es
// creíble. La posición exacta de cada uno dentro de esa fila es una
// distribución uniforme según lo que se aprecia en la foto, no una
// medida milimétrica exacta — pendiente de confirmar si hay forma de
// medirlo con más precisión.
//=============================================================================

// PEDIDO POR EL USUARIO (2026-08-16): "te adjunto el fichero que ya
// he convertido en DXF" — dibujo real a escala en AutoCAD (unidades
// del archivo: centímetros, INSUNITS=5, confirmado antes de usar los
// datos) con las medidas exactas de cada conector trasero. Sustituye
// por completo las estimaciones anteriores basadas en la foto (orden
// USB-USB-RJ45-HDMI-HDMI-DC, y la orientación vertical del HDMI, ya
// acertadas — ahora con medidas precisas en vez de estimadas).
//
// Cada USB apilado es UN ÚNICO recorte rectangular (15x16mm) que
// cubre los dos puertos como una sola abertura — así viene dibujado
// en el CAD, no como dos huecos individuales con separación estimada
// (rear_usb_stack_pitch, ya no se usa).
//
// Referencia Y del CAD verificada contra el proyecto: coincide con
// z_pcb_bottom + Z, casi exacta (0,36mm de diferencia) con el valor
// que ya se usaba antes por estimación — se usan los valores medidos
// directamente, sin necesidad de reajustar el origen.

rear_dc_jack_diameter = 10.0;   // Medido en CAD — 10x10mm CUADRADO (ver nota de corrección abajo)
rear_hdmi_width  = 6.25; rear_hdmi_height = 16.0;  // Medido en CAD (promedio de los dos HDMI: 6,5 y 6,0mm de ancho; antes 6x15, estimado)
rear_rj45_width  = 16.5; rear_rj45_height = 13.0;  // Medido en CAD (antes 16x13.5, estimado — casi igual)
rear_usb_width   = 15.0; rear_usb_height  = 16.0;  // Medido en CAD — recorte único por pareja apilada, no un puerto individual (antes 13x6, estimado, para un solo puerto)
rear_io_center_z = 11.14;  // Medido en CAD (Z = z_pcb_bottom + esto = 49,14, la Z real de USB/HDMI; antes 11.5, estimado)

module rearIOCut()
{

    // [x relativo al centro del grupo (medido en CAD, ya con el
    // espejo trasero->delantero aplicado), ancho, alto, Z propia
    // (si difiere de la Z común), es_redondo]
    connectors = [
        [-41.50, rear_usb_width,       rear_usb_height,       z_pcb_bottom+rear_io_center_z, false],  // USB pareja 1 (recorte único)
        [-20.50, rear_usb_width,       rear_usb_height,       z_pcb_bottom+rear_io_center_z, false],  // USB pareja 2 (recorte único)
        [  1.75, rear_rj45_width,      rear_rj45_height,      z_pcb_bottom+9.64,             false],  // RJ45 — Z propia, medida 1,5mm más baja que USB/HDMI
        [ 19.25, rear_hdmi_width,      rear_hdmi_height,      z_pcb_bottom+rear_io_center_z, false],  // HDMI 1
        [ 31.00, rear_hdmi_width,      rear_hdmi_height,      z_pcb_bottom+rear_io_center_z, false],  // HDMI 2
        // FALLO CORREGIDO (2026-08-16, aviso del usuario): "el
        // conector de alimentación te lo he dibujado cuadrado en el
        // fichero DXF y tú lo has hecho redondo" — el DXF ya lo decía
        // (4 puntos, igual que todos los rectángulos, no una
        // aproximación poligonal de un círculo como las letras) pero
        // lo interpreté mal, asumiendo "conector DC = redondo" por
        // costumbre en vez de fiarme del dato real. Corregido a
        // cuadrado (es_redondo=false).
        [ 44.00, rear_dc_jack_diameter,rear_dc_jack_diameter, z_pcb_bottom+8.14,             false],   // DC — CUADRADO, no redondo — Z propia, medida 3mm más baja que USB/HDMI
    ];

    cutY = case_depth/2 - wall_thickness - 1;
    cutDepth = wall_thickness + 2;

    module cutOne(cX, cZ, cWidth, cHeight, cRound)
    {
        translate([cX, cutY, cZ])
        {
            if (cRound)
            {
                rotate([-90,0,0])
                    cylinder(d = cWidth + 2*rear_io_cut_margin, h = cutDepth, center=false);
            }
            else
            {
                translate([-(cWidth+2*rear_io_cut_margin)/2, 0, -(cHeight+2*rear_io_cut_margin)/2])
                    cube([cWidth+2*rear_io_cut_margin, cutDepth, cHeight+2*rear_io_cut_margin]);
            }
        }
    }

    for(i = [0:len(connectors)-1])
    {

        // Espejo: el CAD muestra la vista desde ATRÁS (mirando los
        // conectores de frente) — este proyecto usa la vista desde
        // DELANTE, así que X se invierte.
        cX      = -connectors[i][0];
        cWidth  = connectors[i][1];
        cHeight = connectors[i][2];
        cZ      = connectors[i][3];
        cRound  = connectors[i][4];

        cutOne(cX, cZ, cWidth, cHeight, cRound);

    }

}


//=============================================================================
// LENGÜETA DE UNIÓN CON LA BANDEJA
//
// docs/02_Mechanical_Layout.md, sección 7: "M3 - panel trasero".
// Resuelve el hueco entre el borde trasero de la bandeja
// (tray_depth/2 = 75 mm) y la cara frontal de este panel
// (case_depth/2 - wall_thickness = 78,2 mm): 3,2 mm — ver
// docs/Virtual_Assembly_Report.md.
//
// El inserto M3 va en la bandeja (openscad/parts/01_bandeja/base.scad,
// trayRearBridgeInserts()); aquí solo el taladro de paso.
//
// FALLO CORREGIDO (2026-08-03): la lengüeta estaba a Z≈0-6, la misma
// altura que el suelo del chasis (floor.scad) en su borde trasero —
// colisión real entre dos piezas distintas. La bandeja debe quedar
// ELEVADA sobre los pilares de apoyo del suelo (z_chamber_top=15 a
// z_tray_top=18, ya usado en todo el ensamblaje validado), no a ras
// de suelo — la lengüeta ahora se centra en esa franja real.
//=============================================================================

rear_bridge_width     = 16.0;
rear_bridge_thickness = tray_thickness;  // = grosor real de la bandeja en su posición elevada
rear_screw_clearance  = 3.4;  // holgura de paso para M3
rear_bridge_x_inset   = 15.0; // igual que rear_insert_x_inset, para que coincidan en X
rear_insert_z         = (z_chamber_top + z_tray_top) / 2;  // centrado en el grosor real de la bandeja elevada

module rearBridgeTab(x)
{

    gapY = (case_depth/2 - wall_thickness) - tray_depth/2;

    translate([
        x - rear_bridge_width/2,
        tray_depth/2,
        rear_insert_z - rear_bridge_thickness/2
    ])

        cube([rear_bridge_width, gapY, rear_bridge_thickness]);

}

module rearBridgeTabs()
{

    for(ix=[-1,1])
        rearBridgeTab(ix*(case_width/2 - rear_bridge_x_inset));

}

module rearBridgeScrewHoles()
{

    for(ix=[-1,1])

        translate([
            ix*(case_width/2 - rear_bridge_x_inset),
            tray_depth/2 - 1,
            rear_insert_z
        ])

            rotate([-90,0,0])
                cylinder(d = rear_screw_clearance, h = (case_depth/2 - wall_thickness - tray_depth/2) + 2);

}


//=============================================================================
// TALADROS DE PASO PARA LA FIJACIÓN A LAS PAREDES LATERALES
//
// RETIRADO (2026-08-03): esta fijación adicional (pared ↔ panel
// trasero) colisionaba con el relleno local de la pared
// (side_boss_size = 14 mm de lado, mucho más ancho que el grosor del
// propio panel) — el material del panel alrededor del taladro de
// paso invadía el relleno. Requiere una muesca de alivio en el panel
// para resolverse bien; se deja pendiente para una futura revisión.
// El panel trasero sigue fijado a la bandeja (rearBridgeTabs/
// rearBridgeScrewHoles), ya verificado sin colisión.
//=============================================================================


//=============================================================================
// PANEL TRASERO COMPLETO
//=============================================================================

module rearPanel()
{

    difference()
    {

        union()
        {
            rearPanelSolid();
            rearBridgeTabs();
        }

        rearIOCut();

        rearBridgeScrewHoles();

        rearWallScrewHoles();

    }

}


//=============================================================================
// TORNILLOS DE FIJACIÓN A LAS PAREDES LATERALES — AGUJERO AVELLANADO
//
// Deben coincidir en X con sideMountGlobalX() y en Z con
// rear_wall_screw_z_low/high (openscad/parts/02_chassis/walls.scad,
// rearWallScrewCuts() — misma fuente, assembly_positions.scad).
//
// FALLO CORREGIDO (2026-08-03, dos rondas de aviso del usuario): la
// primera versión dejaba una muesca cuadrada visible; la segunda
// intentaba taparla con un saliente redondo hacia fuera, pero el
// usuario avisó de que un bulto tampoco vale. Solución acordada: el
// inserto de la pared se reculó 3 mm hacia dentro (walls.scad,
// rearWallScrewCuts()) — con eso, el avellanado cabe DENTRO del
// grosor normal del panel, sin ningún saliente.
//=============================================================================

rear_csk_diameter = rear_csk_radius*2;  // 6.0mm, avellanado M3 (radio compartido con walls.scad)
rear_csk_depth    = 1.8;  // dentro de los 3mm del panel

module rearWallScrewHoles()
{

    // FALLO CORREGIDO (2026-08-03, opción 3 elegida por el usuario):
    // mismo criterio que lowerPanelScrewHoles() — panelMountX() en
    // vez de sideMountGlobalX(), misma fórmula que walls.scad
    // (rearWallScrewCuts()), para que coincidan.
    screwX = panelMountX(rear_csk_radius);

    for(ix=[-1,1])
    for(z=[rear_wall_screw_z_low, rear_wall_screw_z_high])
    {

        // Taladro de paso, todo el grosor del panel
        translate([
            ix*screwX,
            case_depth/2 - wall_thickness - 1,
            z
        ])
            rotate([-90,0,0])
                cylinder(d = 3.4, h = wall_thickness+2);

        // Avellanado cónico, recesado en la cara exterior (no
        // atraviesa el panel: cabe en 1,8 de los 3 mm de grosor)
        translate([
            ix*screwX,
            case_depth/2 - rear_csk_depth - 0.1,
            z
        ])
            rotate([-90,0,0])
                cylinder(d1 = 3.4, d2 = rear_csk_diameter, h = rear_csk_depth+0.1);

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    rearPanel();
