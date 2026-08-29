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
// la pantalla real (la parte visible) mide 27,0 x 20,0mm.
//
// CORREGIDO (2026-08-19, el usuario consultó a Gemini sobre el mal
// ajuste del OLED): la medida de 27x20mm seguía siendo demasiado
// grande — es aproximadamente toda la cara frontal de la placa, no
// el cristal activo. La ventana real del cristal es mucho más
// pequeña (23,0 x 12,0mm, dato de Gemini como estimación de
// partida, sin verificar con calibre — el usuario no tenía la
// placa a mano).
//
// SEGUNDA RONDA (2026-08-19, mismo día): "la pantalla OLED queda muy
// separada del borde del panel y no será fácil visualizarla... ¿Y si
// preparamos la ventana... pero con bisel y añadimos cuatro agujeros
// para fijarla con tornillos pasantes y tuercas...?" — el hueco era
// pasante recto, de borde a borde (3mm de panel + 2mm de bisel = 5mm
// de "túnel" antes de llegar al cristal, que además va aún más atrás
// dentro del grosor de la propia placa) — corregido con un bisel
// cónico (más ancho por fuera, estrechándose hasta el tamaño real
// del cristal) para mejorar la visibilidad en ángulo.
// MEDIDA REAL CONFIRMADA (2026-08-19, el usuario midió con calibre):
// el cristal mide 26,0 x 14,5mm — sustituye la estimación anterior
// de Gemini (23,0 x 12,0mm, sin verificar).
oled_screen_width  = 26.0;  // Real, medido por el usuario con calibre — antes 23.0 (estimado, Gemini)
oled_screen_height = 14.5;  // Real, medido por el usuario con calibre — antes 12.0 (estimado, Gemini)
oled_pcb_width     = 27.4;  // ESTIMADO (Gemini)
oled_pcb_height    = 27.4;  // ESTIMADO (Gemini)
oled_mount_spacing = 23.0;  // ESTIMADO (Gemini) — separación entre los 4 taladros
oled_pcb_clearance_depth = oled_module_thickness + oled_module_pin_height + 2.0;  // ESTIMADO — profundidad del hueco de paso para el cuerpo de la placa, hasta detrás de los pines, con margen

// CORREGIDO (2026-08-19, el usuario aclaró que me había explicado
// mal): "el recorte para la ventana del oled no está biselado, me
// interesaría un bisel de 45 grados" — el bisel anterior (hull()
// entre dos rectángulos) tenía una pendiente de ~50° (margen 3mm en
// una profundidad de 2,5mm), no 45° exactos, y probablemente no se
// apreciaba bien. Corregido para que sea un 45° real: margen =
// profundidad del bisel (oled_bevel_depth), condición exacta para
// que la pendiente sea de 45°.
oled_bevel_depth  = front_bezel_depth;  // el bisel ocupa toda la profundidad añadida por el bisel del panel (2mm)
oled_bevel_margin = oled_bevel_depth;   // igual a la profundidad -> pendiente exacta de 45°

oled_pin_clearance_height       = 3.0;  // ESTIMADO — cuánto sobresalen hacia arriba los pines de soldadura, sobre el borde superior de la pantalla
oled_pin_clearance_pocket_depth = 1.5;  // ESTIMADO — profundidad del rebaje ciego, dentro del grosor del panel (deja 1,5mm de piel sólida delante)

module oledCut()
{

    // Bisel real de 45°: boca ancha en la cara exterior del bisel
    // del panel, estrechándose hasta el tamaño real del cristal
    // justo al llegar a la cara frontal del propio panel — mejora la
    // visibilidad en ángulo, en vez de mirar por un túnel recto.
    hull()
    {

        translate([oled_pos[0], -case_depth/2-oled_bevel_depth, oled_pos[2]])
            cube([
                oled_screen_width + 2*oled_bevel_margin,
                0.1,
                oled_screen_height + 2*oled_bevel_margin
            ], center=true);

        translate([oled_pos[0], -case_depth/2, oled_pos[2]])
            cube([oled_screen_width, 0.1, oled_screen_height], center=true);

    }

    // Resto del hueco, a partir de donde termina el bisel (cara
    // frontal del panel, detrás del bisel) — recto, tamaño real del
    // cristal, hasta la cara trasera del panel.
    translate([
        oled_pos[0] - oled_screen_width/2,
        -case_depth/2,
        oled_pos[2] - oled_screen_height/2
    ])
        cube([oled_screen_width, front_panel_thickness+0.1, oled_screen_height]);

    // RESTAURADO (2026-08-19, aviso del usuario: "se te ha olvidado
    // el rebaje que teníamos para los pines de soldadura que tiene
    // la pantalla en su parte superior") — se había perdido al
    // rediseñar el hueco a partir de los datos de Gemini. Rebaje
    // CIEGO (no llega a la cara trasera del panel, a diferencia del
    // hueco de la pantalla) por encima de la ventana, para los pines
    // de soldadura que sobresalen ahí — sin este rebaje, el material
    // sólido del panel (fuera del propio hueco de la pantalla)
    // chocaría con ellos.
    translate([
        oled_pos[0] - oled_screen_width/2,
        -case_depth/2,
        oled_pos[2] + oled_screen_height/2
    ])
        cube([oled_screen_width, oled_pin_clearance_pocket_depth+0.1, oled_pin_clearance_height]);

    // Hueco de paso para el cuerpo de la placa (27,4x27,4mm) por
    // detrás del panel — la placa no se recesa dentro del propio
    // panel, se sujeta con los 4 tornillos del usuario a través de
    // oledMountHoles(), con su cara frontal apoyada contra la cara
    // trasera del panel alrededor de la ventana.
    translate([
        oled_pos[0] - oled_pcb_width/2,
        -case_depth/2 + front_panel_thickness - 0.1,
        oled_pos[2] - oled_pcb_height/2
    ])
        cube([oled_pcb_width, oled_pcb_clearance_depth+0.2, oled_pcb_height]);

}


//=============================================================================
// 4 AGUJEROS DE FIJACIÓN DEL OLED — sin soportes
//
// CORREGIDO (2026-08-19, el usuario aclaró que me había explicado
// mal): "sigue quedando muy separada del panel, deja únicamente
// cuatro orificios en el panel y yo pondré los tornillos y las
// tuercas, no necesito soportes solo los agujeros" — eliminadas las
// 4 torres con bolsillo hexagonal (ronda anterior); ahora son 4
// simples agujeros pasantes, atravesando solo el grosor del propio
// panel, sin ningún material añadido. El usuario pone sus propios
// tornillos y tuercas.
//=============================================================================

oled_m2_clearance_diameter = 2.2;   // holgura de paso para M2

module oledMountHoles()
{

    for(ix=[-1,1])
    for(iz=[-1,1])

        translate([
            oled_pos[0] + ix*oled_mount_spacing/2,
            -case_depth/2-1,
            oled_pos[2] + iz*oled_mount_spacing/2
        ])

            rotate([-90,0,0])
                cylinder(d = oled_m2_clearance_diameter, h = front_panel_thickness+2);

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
// PARED DEL CANAL DE LA TIRA LED
//
// PEDIDO POR EL USUARIO (2026-08-03, con foto de referencia): la
// "pared existente" es el propio grosor del panel (front_panel_thickness,
// su cara frontal, que ya forma una pared al verla de canto).
//
// CORREGIDO (2026-08-19, el usuario aclaró que me había explicado
// mal): "no quiero el soporte de la tira de leds en L, lo quiero
// perpendicular al panel, como en el diseño original, pero pegado
// directamente al panel sin soportes y de paso que tenga un ancho de
// 15mm en lugar de los 10 actuales" — se elimina la segunda pared en
// L (ledChannelBackWall(), ronda anterior) y las patas de conexión
// (ledChannelSupports(), ya no hacen falta al tocar la pared
// directamente el panel, sin hueco de por medio). La pared vuelve a
// ser una única pieza, perpendicular al panel (igual que el diseño
// original), pero ahora arranca directamente en la cara trasera del
// panel (sin el hueco de led_bar_strip_width) y con
// led_channel_wall_thickness ampliado a 15mm (antes 10mm).
//=============================================================================

led_channel_wall_height    = 3.0;  // ESTIMADO — altura de cada pared del canal, en Z
led_channel_wall_thickness = 15.0;  // antes 10.0 — petición del usuario (2026-08-19)
led_channel_x_margin       = 8.0;  // igual que ledDiffuserZone(), mismo ancho de zona

module ledChannelWalls()
{

    channelWidth = case_width - 2*led_channel_x_margin;
    channelZ     = (front_panel_led_z_low + front_panel_led_z_high)/2 - led_channel_wall_height/2;

    // FALLO CORREGIDO: pegada exactamente a la cara trasera del
    // panel (sin margen) dejaba la pieza no watertight —
    // coincidencia geométrica exacta entre la cara de la pared y la
    // cara del panel, mismo tipo de problema ya visto varias veces
    // en este proyecto (islas de la bandeja, marco delantero).
    // Solapada 0,2mm hacia dentro del propio panel para que las
    // caras no coincidan exactamente.
    wall_overlap = 0.2;

    translate([
        -channelWidth/2,
        -case_depth/2 + front_panel_thickness - wall_overlap,
        channelZ
    ])

        cube([
            channelWidth,
            led_channel_wall_thickness + wall_overlap,
            led_channel_wall_height
        ]);

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
            }

            pushbuttonCut();

            oledCut();

            oledMountHoles();

            usbFrontCut();

            lowerPanelScrewHoles();

            ledDiffuserThinCut();

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
