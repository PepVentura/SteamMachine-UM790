//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : lower_panel.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Panel inferior FIJO — sustituye a front_panel.scad/front_layout.scad
// (obsoletos, ver notas al final de ambos archivos). Diseño definitivo
// tras la verificación completa del ensamblaje virtual v1
// (docs/03_Virtual_Assembly_Report.md): pulsador, OLED y USB doble en
// fila única, más la barra LED justo encima, impresos en la MISMA
// pieza con la Anycubic Kobra X en dos filamentos independientes.
//
// NO lleva imanes (docs/02_Mechanical_Layout.md, sección 6: "Panel
// inferior: No imanes. Se fijará mediante tornillos M2 sobre
// insertos térmicos."). Los insertos correspondientes van en
// openscad/parts/02_chassis/walls.scad (lowerPanelScrewCuts()).
//
// Todas las posiciones vienen de
// openscad/reference/components/assembly_positions.scad — fuente
// única, no se recalculan aquí.
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
// PLACA MACIZA (incluye la franja de la barra LED, misma pieza)
//=============================================================================

module lowerPanelSolid()
{

    // FALLO CORREGIDO (2026-08-03): igual que le pasaba a
    // rear_panel.scad, el ancho (case_width = 156 mm) solapaba el
    // propio grosor de las paredes laterales (X desde ±75 hasta ±78)
    // — colisión real de volumen. Corregido a
    // case_width - 2*wall_thickness (150 mm), para que encaje ENTRE
    // las paredes, igual que la bandeja y el panel NFC.
    translate([
        -(case_width - 2*wall_thickness)/2,
        -case_depth/2,
        0
    ])

        cube([
            case_width - 2*wall_thickness,
            front_panel_thickness,
            front_panel_led_z_high
        ]);

}


//=============================================================================
// HUECO DEL PULSADOR
//=============================================================================

module pushbuttonCut()
{

    translate([pushbutton_pos[0], -case_depth/2-1, pushbutton_pos[2]])
        rotate([-90,0,0])
            cylinder(d = pushbutton_thread_diameter, h = front_panel_thickness+2);

}


//=============================================================================
// VENTANA DEL OLED
//=============================================================================

module oledCut()
{

    translate([
        oled_pos[0] - oled_module_width/2,
        -case_depth/2-1,
        oled_pos[2] - oled_module_height/2
    ])
        cube([oled_module_width, front_panel_thickness+2, oled_module_height]);

}


//=============================================================================
// HUECO DEL USB DOBLE (un solo orificio — unidad de doble puerto)
//=============================================================================

module usbFrontCut()
{

    translate([usb_front_pos[0], -case_depth/2-1, usb_front_pos[2]])
        rotate([-90,0,0])
            cylinder(d = usb_front_hole_diameter, h = front_panel_thickness+2);

}


//=============================================================================
// TORNILLOS M2 — AGUJERO AVELLANADO, DENTRO DEL GROSOR NORMAL DEL PANEL
//
// Deben coincidir en X/Z con lowerPanelScrewCuts() en
// openscad/parts/02_chassis/walls.scad.
//
// FALLO CORREGIDO (2026-08-03, dos rondas de aviso del usuario): la
// primera versión dejaba una muesca cuadrada visible; la segunda
// intentaba taparla con un saliente redondo, pero el usuario avisó
// de que un bulto hacia fuera tampoco vale. Solución acordada: el
// inserto de la pared se reculó 3 mm hacia dentro (walls.scad,
// lowerPanelScrewCuts()) — con eso, el taladro de paso y el
// avellanado caben DENTRO del grosor normal del panel (3 mm), sin
// ningún saliente ni muesca. El panel queda liso salvo por el propio
// avellanado (visible, como corresponde a un tornillo avellanado
// real — no oculto, a diferencia del imán).
//=============================================================================

lower_panel_csk_diameter = lower_panel_csk_radius*2;  // 4.5mm, diámetro del avellanado M2 (radio compartido con walls.scad)
lower_panel_csk_depth    = 1.4;   // dentro de los 3mm del panel, deja 1,6mm de canal recto

module lowerPanelScrewHoles()
{

    // FALLO CORREGIDO (2026-08-03, opción 3 elegida por el usuario):
    // sideMountGlobalX() posicionaba el agujero con margen respecto
    // a la cara EXTERIOR de la pared (X=78) — el avellanado se salía
    // por el borde real del panel (X=75). Ahora panelMountX(), con
    // margen respecto al borde REAL del panel — misma fórmula que
    // walls.scad (lowerPanelScrewCuts()), para que coincidan.
    screwX = panelMountX(lower_panel_csk_radius);

    for(ix=[-1,1])
    for(z=[lower_panel_screw_z_low, lower_panel_screw_z_high])
    {

        // Taladro de paso, todo el grosor del panel
        translate([
            ix*screwX,
            -case_depth/2-1,
            z
        ])
            rotate([-90,0,0])
                cylinder(d = 2.2, h = front_panel_thickness+2);

        // Avellanado cónico, recesado en la cara exterior (no
        // atraviesa el panel: cabe en 1,4 de los 3 mm de grosor)
        translate([
            ix*screwX,
            -case_depth/2-0.1,
            z
        ])
            rotate([-90,0,0])
                cylinder(d1 = lower_panel_csk_diameter, d2 = 2.2, h = lower_panel_csk_depth+0.1);

    }

}


//=============================================================================
// CANAL DE LA BARRA LED (2º filamento, misma pieza)
//
// Volumen de referencia — en la impresión real es donde el segundo
// filamento (translúcido) sustituye al primero, no un hueco pasante.
// Aquí se representa como cuerpo aparte para poder colorearlo
// distinto en la vista previa; ver ledDiffuserZone() en el ensamblado
// final (impresión con cambio de filamento, no pieza montada aparte).
//=============================================================================

module ledDiffuserZone()
{

    translate([
        -case_width/2 + 8,
        -case_depth/2,
        front_panel_led_z_low
    ])

        cube([
            case_width - 16,
            front_panel_thickness,
            front_panel_led_z_high - front_panel_led_z_low
        ]);

}


//=============================================================================
// SEGUNDA PARED DEL CANAL DE LA TIRA LED
//
// PEDIDO POR EL USUARIO (2026-08-03, con foto de referencia): la
// "pared existente" es el propio grosor del panel (front_panel_thickness,
// su cara frontal, que ya forma una pared al verla de canto). Esta es
// la SEGUNDA pared, paralela a esa, separada hacia el interior (+Y)
// una distancia igual al ancho de la tira LED real
// (led_bar_strip_width) — el hueco entre ambas paredes es donde se
// pega la tira, con su longitud a lo largo de X y su anchura
// encajada entre las dos paredes.
//
// MEDIDAS ESTIMADAS, pendientes de confirmar con la tira LED real:
// led_channel_wall_height (cuánto sobresale cada pared en Z) y
// led_channel_wall_thickness (grosor de la pared nueva).
//=============================================================================

led_channel_wall_height    = 3.0;  // ESTIMADO — altura de cada pared del canal, en Z
led_channel_wall_thickness = 1.5;  // ESTIMADO — grosor de la pared nueva
led_channel_x_margin       = 8.0;  // igual que ledDiffuserZone(), mismo ancho de zona

module ledChannelWalls()
{

    channelWidth = case_width - 2*led_channel_x_margin;
    channelZ     = (front_panel_led_z_low + front_panel_led_z_high)/2 - led_channel_wall_height/2;

    // Pared nueva, paralela a la cara frontal del panel (la "pared
    // existente"), separada hacia el interior el ancho real de la
    // tira LED.
    translate([
        -channelWidth/2,
        -case_depth/2 + front_panel_thickness + led_bar_strip_width,
        channelZ
    ])

        cube([
            channelWidth,
            led_channel_wall_thickness,
            led_channel_wall_height
        ]);

}


//=============================================================================
// PANEL INFERIOR COMPLETO (solo el cuerpo estructural — la zona LED
// se imprime en el mismo volumen con el 2º filamento, ver
// ledDiffuserZone() para la vista previa con color distinto)
//=============================================================================

module lowerPanel()
{

    union()
    {

        difference()
        {

            lowerPanelSolid();

            pushbuttonCut();

            oledCut();

            usbFrontCut();

            lowerPanelScrewHoles();

        }

        ledChannelWalls();

    }

}


//=============================================================================
// PREVIEW (cuerpo principal + zona LED en color distinto, tal como
// saldría de la impresión con doble filamento)
//=============================================================================

difference()
{
    color([0.1,0.1,0.1,1]) lowerPanel();
    ledDiffuserZone();
}

color([1,1,1,0.85])
    intersection()
    {
        ledDiffuserZone();
        lowerPanel();
    }
