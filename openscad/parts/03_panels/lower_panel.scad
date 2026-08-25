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
// (docs/Virtual_Assembly_Report.md): pulsador, OLED y USB doble en
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

// PEDIDO POR EL USUARIO (2026-08-03, tras probar la impresión real):
// "el panel no llega a los extremos del chasis" — hueco pequeño y
// simétrico en ambos lados. La geometría modelada coincide
// exactamente con el hueco entre paredes (150mm), así que esto
// parece merma típica de la impresión FDM (las piezas grandes en
// plano suelen salir ligeramente más pequeñas), no un error de
// posición. Se sobredimensiona el ancho para compensar — IMPORTANTE:
// esto NO mueve los taladros de tornillo (siguen calculados con
// panelMountX(), sin cambios, para seguir coincidiendo con los
// insertos de la pared ya impresa) — solo ensancha el borde exterior
// del panel y el marco, repartido igual a cada lado.
//
// AJUSTADO (2026-08-16, confirmado con probeta impresa real): a
// 151mm (oversize=+1), el panel real medía 150mm — pero el hueco
// interior real del chasis medía solo 149mm, así que el panel real
// quedaba MÁS ANCHO que el hueco (no debería encajar bien). Una
// segunda probeta a 149mm de diseño salió en 149mm real (0mm de
// merma esta vez — la merma no es constante entre impresiones).
// Ajustado a -1.0 (149mm total), confirmado por el usuario tras la
// prueba física — incluido el ancho del panel NFC (nfc_panel_width,
// 00_parametros.scad), para que ambos sigan coincidiendo.
lower_panel_width_oversize = -1.0;  // antes +1.0 (151mm total) — confirmado con probeta real, ahora 149mm total

module lowerPanelSolid()
{

    translate([
        -(case_width - 2*wall_thickness + lower_panel_width_oversize)/2,
        -case_depth/2,
        0
    ])

        cube([
            case_width - 2*wall_thickness + lower_panel_width_oversize,
            front_panel_thickness,
            front_panel_led_z_high
        ]);

}


//=============================================================================
// MARCO ELEVADO (bisel) — puramente añadido hacia fuera, ver nota en
// 00_parametros.scad (front_bezel_depth/front_bezel_border). No toca
// front_panel_thickness ni la cara que mira a la pared.
//=============================================================================

module lowerPanelBezel()
{

    // PEDIDO POR EL USUARIO (2026-08-03): el marco debe ser continuo
    // entre el panel inferior y el NFC — sin marco en el borde donde
    // se juntan (el superior de este panel), para no romper la
    // continuidad visual. Se mantiene en los otros tres lados
    // (izquierdo, derecho, inferior).
    panelWidth = case_width - 2*wall_thickness + lower_panel_width_oversize;

    translate([
        -panelWidth/2,
        -case_depth/2 - front_bezel_depth,
        0
    ])

        difference()
        {

            cube([panelWidth, front_bezel_depth, front_panel_led_z_high]);

            translate([front_bezel_border, -0.1, front_bezel_border])
                cube([
                    panelWidth - 2*front_bezel_border,
                    front_bezel_depth + 0.2,
                    front_panel_led_z_high - front_bezel_border + 0.1
                ]);

        }

}


//=============================================================================
// HUECO DEL PULSADOR
//=============================================================================

module pushbuttonCut()
{

    // CORREGIDO (2026-08-03): extendido hacia fuera front_bezel_depth
    // para atravesar también el marco elevado, no solo el grosor base
    // del panel — si no, el marco taparía el hueco allí donde caiga
    // dentro de su franja.
    translate([pushbutton_pos[0], -case_depth/2-front_bezel_depth-1, pushbutton_pos[2]])
        rotate([-90,0,0])
            cylinder(d = pushbutton_thread_diameter, h = front_panel_thickness+front_bezel_depth+2);

}


//=============================================================================
// VENTANA DEL OLED
//=============================================================================

// ACTUALIZADO (2026-08-03, aviso del usuario tras probar la
// impresión real): "la medida que te di fue de toda la placa no de
// la pantalla" — el hueco usaba 27x27mm (la placa completa), cuando
// la pantalla real (la parte visible) mide 27,0 x 20,0mm. Además, por
// encima de la pantalla, en un margen de 3mm, hay unos pines que
// sobresalen — necesitan hueco por dentro, pero SIN llegar a
// atravesar hacia el exterior (rebaje ciego, no un segundo agujero
// visible).
//
// MOVIDO a assembly_positions.scad (2026-08-22): oled_bracket.scad
// (la nueva brida de sujeción) también necesita estas medidas, y con
// "use<>" no se comparten variables entre ficheros — solo módulos —
// así que deben vivir en el include común a ambos.

module oledCut()
{

    // Hueco pasante — solo la pantalla real, no toda la placa.
    translate([
        oled_pos[0] - oled_screen_width/2,
        -case_depth/2-front_bezel_depth-1,
        oled_pos[2] - oled_screen_height/2
    ])
        cube([oled_screen_width, front_panel_thickness+front_bezel_depth+2, oled_screen_height]);

    // Rebaje ciego para los pines, por encima de la pantalla — solo
    // por dentro (desde la cara trasera), sin llegar a la exterior.
    translate([
        oled_pos[0] - oled_screen_width/2,
        -case_depth/2 + front_panel_thickness - oled_pin_clearance_pocket_depth,
        oled_pos[2] + oled_screen_height/2
    ])
        cube([oled_screen_width, oled_pin_clearance_pocket_depth+0.1, oled_pin_clearance_height]);

}


//=============================================================================
// BOSSES DE INSERTO PARA LA SUJECIÓN DE LA OLED
//
// Ver nota completa junto a oled_bracket_screw_positions en
// assembly_positions.scad. Dos bosses cilíndricos en las esquinas
// inferiores del hueco de la OLED, con un rebaje ciego para el
// inserto térmico M2 — la brida (oled_bracket.scad) se atornilla
// aquí, sujetando el módulo por detrás contra la cara interior del
// panel.
//=============================================================================

module oledInsertBosses()
{

    for (p = oled_bracket_screw_positions)
    {

        translate([p[0], -case_depth/2 + front_panel_thickness, p[1]])
            rotate([-90,0,0])
                cylinder(d = oled_bracket_boss_diameter, h = oled_bracket_boss_length);

    }

}

module oledInsertHoles()
{

    for (p = oled_bracket_screw_positions)
    {

        translate([
            p[0],
            -case_depth/2 + front_panel_thickness + oled_bracket_boss_length - oled_bracket_insert_depth,
            p[1]
        ])
            rotate([-90,0,0])
                cylinder(d = oled_bracket_insert_diameter, h = oled_bracket_insert_depth+0.1);

    }

}


//=============================================================================
// HUECO DEL USB DOBLE (un solo orificio — unidad de doble puerto)
//=============================================================================

module usbFrontCut()
{

    translate([usb_front_pos[0], -case_depth/2-front_bezel_depth-1, usb_front_pos[2]])
        rotate([-90,0,0])
            cylinder(d = usb_front_hole_diameter, h = front_panel_thickness+front_bezel_depth+2);

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

lower_panel_csk_diameter = lower_panel_csk_radius*2;  // 6.0mm, diámetro del avellanado M3 (radio compartido con walls.scad) — antes 4.5mm, M2
lower_panel_csk_depth    = 1.6;   // ESTIMADO — ligeramente mayor que antes (1.4mm) por la cabeza M3, algo más gruesa que la M2; dentro de los 3mm del panel, deja 1,4mm de canal recto

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
    for(z=[lower_panel_hole_z_low, lower_panel_hole_z_high])
    {

        // Taladro de paso, todo el grosor del panel + el marco (el
        // tornillo cae dentro de la franja del marco, a 3,75mm del
        // borde, menos que su anchura de 4mm — CORREGIDO 2026-08-03)
        //
        // FALLO CORREGIDO (2026-08-14, aviso del usuario): estaba a
        // 2,2mm (M2) — ahora 3,4mm, holgura estándar para M3.
        translate([
            ix*screwX,
            -case_depth/2-front_bezel_depth-1,
            z
        ])
            rotate([-90,0,0])
                cylinder(d = 3.4, h = front_panel_thickness+front_bezel_depth+2);

        // Avellanado cónico, recesado en la cara exterior DEL MARCO
        // (que ahora es la cara exterior real en esta zona)
        translate([
            ix*screwX,
            -case_depth/2-front_bezel_depth-0.1,
            z
        ])
            rotate([-90,0,0])
                cylinder(d1 = lower_panel_csk_diameter, d2 = 3.4, h = lower_panel_csk_depth+0.1);

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

// REDISEÑADO (2026-08-03, aviso del usuario tras probar la impresión
// real: "preferiría que el translúcido fuese menos ancho" + "el marco
// en relieve... sino queda raro"): antes cubría toda la franja de
// 12mm (39,5-51,5) incluyendo el trozo donde se solapa con el marco
// (47,5-51,5) — el usuario prefiere el marco entero en el filamento
// base, y la franja translúcida más estrecha. Ahora: 6mm, centrada
// en el hueco que queda libre de marco (39,5-47,5), con margen a
// ambos lados.
led_diffuser_width = 6.0;  // antes 12mm (la franja completa) — ESTIMADO, a falta de una medida exacta preferida

module ledDiffuserZone()
{

    bezelTopZLow = front_panel_led_z_high - front_bezel_border;
    zoneCenter   = (front_panel_led_z_low + bezelTopZLow) / 2;

    translate([
        -case_width/2 + 8,
        -case_depth/2,
        zoneCenter - led_diffuser_width/2
    ])

        cube([
            case_width - 16,
            front_panel_thickness,
            led_diffuser_width
        ]);

}


//=============================================================================
// ADELGAZAMIENTO REAL DE LA FRANJA DEL DIFUSOR
//
// PEDIDO POR EL USUARIO (2026-08-17): "debido al grosor de la capa
// de la franja translúcida... la luz no puede traspasar tal tamaño
// de pared, deberíamos reducir su grosor a 1mm en esa franja, pero
// manteniendo el grosor del marco perimetral" — hasta ahora
// ledDiffuserZone() solo definía la zona para la vista previa de
// color (el panel impreso tenía grosor uniforme en toda su
// superficie, 3mm, el mismo que el resto). Este módulo SÍ recorta
// material de verdad: se quita la mitad trasera de la franja
// (dejando el mismo margen de 8mm respecto al borde que
// ledDiffuserZone(), sin invadir el marco de 4mm de ancho), dejando
// solo 1mm de "piel" en la cara frontal, por donde pasa la luz.
//=============================================================================

led_diffuser_skin_thickness = 1.0;  // ESTIMADO — grosor que queda en la cara frontal de la franja, a falta de confirmar cuánto necesita realmente la luz para pasar bien

module ledDiffuserThinCut()
{

    bezelTopZLow = front_panel_led_z_high - front_bezel_border;
    zoneCenter   = (front_panel_led_z_low + bezelTopZLow) / 2;

    // FALLO CORREGIDO: sin este pequeño margen extra (thin_cut_eps),
    // el recorte dejaba la pieza no watertight — confirmado
    // comparando con/sin el recorte (con él, aristas problemáticas;
    // sin él, watertight). Coincidencia geométrica exacta con algo
    // más (probablemente las paredes del canal LED, que arrancan en
    // la misma cara trasera del panel) — mismo tipo de problema ya
    // visto antes en este proyecto (islas de la bandeja, marco
    // delantero). Se amplía ligeramente el recorte en Z para que
    // solape con claridad, sin llegar a invadir el marco.
    thin_cut_eps = 0.1;

    translate([
        -case_width/2 + 8,
        -case_depth/2 + led_diffuser_skin_thickness,
        zoneCenter - led_diffuser_width/2 - thin_cut_eps
    ])

        cube([
            case_width - 16,
            front_panel_thickness - led_diffuser_skin_thickness + 0.1,
            led_diffuser_width + 2*thin_cut_eps
        ]);

}


//=============================================================================
// PARED DEL CANAL DE LA TIRA LED (REDISEÑADO 2026-08-22)
//
// PEDIDO POR EL USUARIO: "su soportación con el panel es muy débil...
// toca con los conectores USB-C que van al UM790... desplazar hasta
// tocar con el propio panel... retirar la pieza horizontal para pegar
// la tira que incorporamos recientemente, para evitar contacto con
// los USB mencionados."
//
// Diseño anterior (2026-08-03/18): una repisa horizontal de 10mm de
// grosor (led_channel_wall_thickness) se proyectaba hacia fuera desde
// el ancho real de la tira, y de su borde más alejado colgaba la
// pared donde se pegaba la tira — protrusión total desde el panel:
// led_bar_strip_width + led_channel_wall_thickness ≈ 20mm. Esa repisa
// (justo la parte que más sobresalía) es la que chocaba con los
// conectores USB-C, y aportaba poco a la robustez (sujeta solo por
// dos patas de 4mm en los extremos, con ~140mm de vano sin apoyo
// entre medias).
//
// Rediseño: se elimina la repisa por completo. La pared donde se pega
// la tira (antes ledChannelBackWall()) pasa a estar exactamente a
// led_bar_strip_width del panel — el hueco justo para el ancho real
// de la tira, sin ningún sobrante — reduciendo la protrusión total a
// la mitad (~10mm en vez de ~20mm). La conexión al panel deja de ser
// dos patas sueltas: ahora es una serie de costillas cortas y anchas,
// repartidas a lo largo de TODO el ancho del canal (no solo en los
// extremos), fusionadas con solape real tanto en el panel como en la
// pared — igual de robusto que una unión continua, pero sin tapar la
// mayor parte del hueco por donde debe pasar la luz hacia el difusor.
//=============================================================================

led_channel_wall_height    = 3.0;  // ESTIMADO — altura de la pared del canal, en Z
led_channel_backwall_thickness = 2.0;  // ESTIMADO — grosor de la pared donde se pega la tira
led_channel_backwall_margin    = 2.0;  // ESTIMADO — margen por debajo de la franja del difusor (40,5mm), para cubrirla entera con holgura
led_channel_x_margin       = 8.0;  // igual que ledDiffuserZone(), mismo ancho de zona

// Costillas de conexión: anchas (más superficie de pegado que las
// antiguas patas de 4mm) y repartidas a lo largo de todo el canal, no
// solo en los extremos — resuelve la queja de soportación débil.
led_channel_rib_count     = 6;    // nº de costillas repartidas a lo largo del canal
led_channel_rib_width     = 8.0;  // ancho de cada costilla, en X
led_channel_rib_overlap   = 0.4;  // pequeño solape con el panel y con la pared, para fusion real (no solo contacto) y evitar geometria no-manifold

module ledChannelWalls()
{

    channelWidth = case_width - 2*led_channel_x_margin;
    channelZ     = (front_panel_led_z_low + front_panel_led_z_high)/2 - led_channel_wall_height/2;

    panelBackY  = -case_depth/2 + front_panel_thickness;
    wallY       = panelBackY + led_bar_strip_width;   // a tocar con el ancho real de la tira, sin sobrante
    wallBottomZ = front_panel_led_z_low - led_channel_backwall_margin;
    wallTopZ    = channelZ + led_channel_wall_height;

    // Pared donde se pega la tira, con su cara ancha mirando hacia el
    // panel (-Y) — los LEDs enfrentados directamente a la franja del
    // difusor, igual que antes.
    translate([
        -channelWidth/2,
        wallY,
        wallBottomZ
    ])

        cube([
            channelWidth,
            led_channel_backwall_thickness,
            wallTopZ - wallBottomZ
        ]);

    // Costillas de conexión al panel, repartidas a lo largo de X.
    for (i = [0:led_channel_rib_count-1])
    {
        ribX = -channelWidth/2 + led_channel_rib_width/2
             + i*(channelWidth - led_channel_rib_width) / (led_channel_rib_count-1);

        translate([
            ribX - led_channel_rib_width/2,
            panelBackY - led_channel_rib_overlap,
            channelZ
        ])

            cube([
                led_channel_rib_width,
                (wallY + led_channel_backwall_thickness + led_channel_rib_overlap) - (panelBackY - led_channel_rib_overlap),
                led_channel_wall_height
            ]);
    }

}


//=============================================================================
// PANEL INFERIOR COMPLETO
//
// La zona LED se imprime en el mismo volumen con el 2º filamento
// (ver ledDiffuserZone() para la vista previa con color distinto) —
// pero desde 2026-08-17 también lleva un recorte real
// (ledDiffuserThinCut()) que adelgaza esa franja a 1mm de grosor,
// para que la luz de la tira LED la atraviese mejor (antes tenía el
// mismo grosor que el resto del panel, 3mm — el usuario confirmó
// tras imprimirlo que era demasiado grueso).
//=============================================================================

module lowerPanel()
{

    union()
    {

        difference()
        {

            union()
            {
                lowerPanelSolid();
                lowerPanelBezel();
                oledInsertBosses();
            }

            pushbuttonCut();

            oledCut();

            usbFrontCut();

            lowerPanelScrewHoles();

            ledDiffuserThinCut();

            oledInsertHoles();

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
