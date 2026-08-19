//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : assembly_positions.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// ÚNICA fuente de posiciones del ensamblaje virtual v1.
//
// Este archivo NO dibuja geometría. Solo calcula, a partir de
// 00_parametros.scad, dónde va cada componente dentro del chasis.
//
// Lo incluyen tanto virtual_assembly_v1.scad (para dibujar el
// ensamblaje) como los scripts de openscad/reference/checks/ (para
// comprobar colisiones), de forma que ambos usen exactamente los
// mismos números.
//
// SISTEMA DE COORDENADAS GLOBAL DE ESTE ENSAMBLAJE:
//   Origen (0,0,0) = centro de la huella del chasis en X/Y,
//                     cara inferior exterior en Z.
//   X: anchura  (case_width  = 156.0 mm) → -case_width/2 .. +case_width/2
//   Y: profundidad (case_depth = 162.4 mm) → -case_depth/2 (frontal,
//      donde va el panel intercambiable) .. +case_depth/2 (trasera,
//      donde va la IO del UM790)
//   Z: altura del CASCARÓN (shell_height = 148,0 mm; las patas son
//      externas, 4 mm, añadidas por DEBAJO de Z=0 — ver leg_height en
//      00_parametros.scad) → 0 (base del cascarón) .. shell_height (techo)
//
// NOTA: parts/02_chassis y parts/01_bandeja usan convenciones de
// origen distintas entre sí (esquina vs. centro). Este archivo define
// la convención propia del ensamblaje virtual de referencia; el
// chasis definitivo podrá adoptar la que convenga en su propio
// sistema de coordenadas.
//
// ============================================================================

include <../../../00_parametros.scad>;


//=============================================================================
// PLANOS DE REFERENCIA VERTICALES (Z)
//=============================================================================

// Cara superior del suelo exterior
z_bottom_skin_top = bottom_thickness;

// Cara superior de la cámara de aire inferior (= cara inferior de la bandeja)
z_chamber_top = z_bottom_skin_top + lower_air_chamber;

// Cara superior de la bandeja (donde apoyan los separadores del UM790)
z_tray_top = z_chamber_top + tray_thickness;

// Cara inferior de la PCB del UM790 (encima de los separadores)
z_pcb_bottom = z_tray_top + um790_standoff_height;

// Cara superior de la PCB
z_pcb_top = z_pcb_bottom + pcb_thickness;

// Cara superior del disipador
z_cooler_top = z_pcb_top + um790_cooler_height;

// Cara inferior de la tapa
z_top_skin_bottom = shell_height - top_thickness;

// Cara inferior / superior del ventilador (pegado a la tapa, empuja el aire hacia arriba)
z_fan_bottom = z_top_skin_bottom - fan_thickness;
z_fan_top    = z_top_skin_bottom;


//=============================================================================
// PANEL FRONTAL — CARA INTERIOR
//=============================================================================

// Cara del panel frontal intercambiable que da al interior del chasis.
// Todos los componentes que se apoyan en el panel (RC522, OLED,
// pulsador, USB frontales) parten de aquí.
front_inner_face_y = -case_depth/2 + front_panel_thickness;

// Franja vertical del panel NFC (panel frontal superior intercambiable),
// igual que en openscad/parts/03_panels/front_layout.scad.
// PEDIDO POR EL USUARIO (2026-08-03): "El panel superior no llega
// hasta el borde superior, le faltan unos 12mm" — quitado el margen,
// el panel ahora crece 12mm hacia arriba (nfc_panel_height ajustada
// en 00_parametros.scad) manteniendo fijo el borde inferior, que
// conecta con lower_panel.
//
// FALLO CORREGIDO (2026-08-17, medidas reales del usuario): al
// reducir nfc_panel_height 2mm (96,5 → 94,5) para no superar la
// altura interior real del chasis, dejar margin_top=0 hacía que la
// fórmula recortara por ABAJO (subía nfc_panel_z_low), abriendo un
// hueco de 2mm entre este panel y el panel inferior — justo la unión
// que debía quedarse fija. Corregido: margin_top=2 (igual al recorte
// de altura), para que el hueco salga por ARRIBA (nfc_panel_z_high
// baja a 146, dejando margen frente al techo del chasis) y
// nfc_panel_z_low se mantenga en 51,5, sin cambios.
nfc_panel_margin_top = 2;
nfc_panel_z_low  = shell_height - nfc_panel_margin_top - nfc_panel_height;
nfc_panel_z_high = nfc_panel_z_low + nfc_panel_height;
nfc_panel_z_mid  = (nfc_panel_z_low + nfc_panel_z_high) / 2;


//=============================================================================
// ANCLAJES LATERALES (imanes del panel NFC, tornillos M2 del panel
// inferior) — posición GLOBAL en X, fuente única.
//
// Los imanes/tornillos (Ø hasta 8,15 mm) son más anchos que la propia
// pared (wall_thickness = 3 mm) — hallazgo del usuario, ver
// docs/03_Virtual_Assembly_Report.md. openscad/parts/02_chassis/walls.scad
// añade un relleno local (side_boss_depth) por el lado NO visto y
// recentra el alojamiento dentro de ese grosor extra.
//
// Esta misma fórmula la deben usar TAMBIÉN los paneles
// (openscad/parts/03_panels/nfc_panel.scad, lower_panel.scad) para
// que sus imanes/taladros coincidan exactamente en X con los de la
// pared — si cada archivo calculase su propia posición por separado,
// se desincronizarían (ya ocurrió: el imán del panel NFC y el de la
// pared llevaban desalineados desde que se creó ese archivo).
//=============================================================================

side_boss_margin = 1.0;   // margen entre el borde del alojamiento y la cara vista de la pared
side_boss_depth  = 10.0;  // grosor local total en los puntos de imán/tornillo
side_boss_size   = 14.0;  // lado del relleno cuadrado, en Y/Z (compartido con los paneles frontales, para la muesca de alivio)

// Posición X GLOBAL del anclaje del lado DERECHO, para un radio de
// corte dado (diámetro del imán o del tornillo, entre 2). El lado
// izquierdo es el mismo valor en negativo (simetría).
function sideMountGlobalX(radius) = case_width/2 - side_boss_margin - radius;

// FALLO CORREGIDO (2026-08-03, captura del usuario): sideMountGlobalX()
// posiciona cosas con margen respecto a la cara EXTERIOR de la pared
// (que llega hasta X=case_width/2=78) — válido para insertos dentro
// de la propia pared, pero los paneles frontal/inferior/trasero solo
// llegan hasta X=(case_width-2*wall_thickness)/2=75. Con
// sideMountGlobalX(), el agujero/avellanado se salía por el borde
// real del panel. panelMountX() calcula la posición con margen
// respecto al borde REAL del panel — para usar en cualquier corte
// que deba caber entero dentro de un panel de anchura
// (case_width-2*wall_thickness), tanto en la pared (el inserto) como
// en el panel (el agujero), para que coincidan exactamente.
function panelMountX(radius, margin=1.5) = (case_width-2*wall_thickness)/2 - margin - radius;

// Radios de los avellanados — compartidos entre walls.scad (para
// calcular la X del inserto con panelMountX()) y los paneles (para
// el propio avellanado) — deben ser el mismo valor en los dos sitios.
// FALLO CORREGIDO (2026-08-14, aviso del usuario): este avellanado
// estaba dimensionado para M2 — el panel inferior necesita M3 (las
// paredes ya impresas con el alojamiento M2 antiguo quedan
// desactualizadas; este cambio es para futuras impresiones propias
// o de otros usuarios). Ahora usa el mismo valor ya establecido para
// M3 en el panel trasero (rear_csk_radius), para que sea consistente
// en todo el proyecto.
lower_panel_csk_radius = 6.0/2;  // M3 (antes 4.5/2, M2)
rear_csk_radius        = 6.0/2;  // M3

// Fijación del panel trasero a la pared — compartido entre
// openscad/parts/02_chassis/walls.scad (rearBossPad/rearWallScrewCuts)
// y openscad/parts/03_panels/rear_panel.scad (rearWallScrewHoles).
//
// rear_wall_screw_z_low — CORREGIDO (2026-08-03): a Z=15 colisionaba
// con la lengüeta de unión bandeja-panel trasero (a Z=15-18 en su
// momento) — confirmado con el modelo real, no solo contacto de
// borde. Subido a 27: lejos de la lengüeta (15-18) y del recorte de
// la IO trasera (37,6-61,6).
//
// NOTA (2026-08-17): esa lengüeta de unión (rearBridgeTabs()) se ha
// eliminado del todo (petición del usuario, ver rear_panel.scad,
// openscad/parts/03_panels/ tras el traslado) — el panel trasero
// ahora se sujeta solo con estos tornillos a la pared. El valor de
// rear_wall_screw_z_low (27) se mantiene sin cambios; ya no hace
// falta evitar la lengüeta, pero sigue siendo una posición válida.
rear_wall_screw_diameter = insert_diameter;
rear_wall_screw_z_low    = 27.0;
rear_wall_screw_z_high   = 130.0;

// Muesca de alivio del relleno de la pared (openscad/parts/02_chassis/walls.scad,
// sideBossPad()) — CORREGIDO (2026-08-03): el relleno (14x14 mm) es
// mucho más ancho que un simple taladro de paso; el material del
// panel alrededor del taladro invadía el relleno (colisión real,
// confirmada exportando a STL). Cualquier panel que se atornille o
// imante a la pared en un punto con relleno debe restar esta muesca
// (misma X que ocupa el relleno en la pared), no solo el taladro.
// Se usa con front_panel_thickness como grosor del corte: los paneles
// que la llaman deben estar a wall_thickness o front_panel_thickness
// de grosor (ambos 3 mm, mismo valor).
module wallPadRelief(z, panelY, panelThickness)
{

    reliefXwidth = side_boss_depth - wall_thickness;

    for(ix=[-1,1])

        translate([
            ix>0 ? (case_width/2 - side_boss_depth) : -(case_width/2 - wall_thickness),
            panelY,
            z - side_boss_size/2
        ])
            cube([reliefXwidth, panelThickness, side_boss_size]);

}


//=============================================================================
// FIJACIÓN DEL PANEL TRASERO A LAS PAREDES LATERALES — RETIRADA (2026-08-03)
//
// Se intentó (docs/03_Virtual_Assembly_Report.md), pero colisionaba
// con el relleno local de la pared.
//
// El panel trasero se sujetaba también a la bandeja mediante unas
// lengüetas (rearBridgeTabs(), openscad/parts/03_panels/rear_panel.scad)
// — ELIMINADAS (2026-08-17, petición del usuario: "sobran estos
// soportes, no son necesarios"). El panel trasero se sujeta ahora
// SOLO con los tornillos a las paredes laterales
// (rear_wall_screw_z_low/high, arriba).
//=============================================================================


//=============================================================================
// UM790 (PCB + disipador + IO trasera)
//=============================================================================

// Centrado en X/Y sobre la bandeja.
um790_pos = [0, um790_post_y_offset, z_pcb_bottom];  // Y desplazado hacia atrás (ver um790_post_y_offset en 00_parametros.scad) para que coincida con los postes reales


//=============================================================================
// VENTILADOR — centrado respecto al disipador (mismo eje X/Y que el UM790)
//=============================================================================

fan_pos = [um790_pos[0], um790_pos[1], z_fan_bottom];


//=============================================================================
// RC522 — centrado horizontalmente, a media altura del panel NFC,
// separado 3 mm de la cara interior del panel frontal (según
// docs/02_Mechanical_Layout.md, sección RC522: "Separación al
// panel: 3 mm").
//=============================================================================

rc522_panel_gap = 3.0;

// FALLO CORREGIDO (2026-08-03, pregunta del usuario: "¿el hueco para
// el llavero NFC sigue estando alineado con su lector?"): la Z de
// esta posición usaba nfc_panel_z_mid — al ampliar la altura del
// panel NFC 12mm, ese valor se desplazó de 93,75 a 99,75 (6mm). El
// soporte del lector (openscad/parts/04_soportes/rc522_bracket.scad)
// YA ESTÁ IMPRESO con la posición antigua — fijado a 93,75 (valor
// absoluto, no recalculado) para que coincida. DEBE coincidir
// siempre con la Z del hueco del tag en nfc_panel.scad
// (nfcTagPocket()).
rc522_pos = [0, front_inner_face_y + rc522_panel_gap, 93.75];

rc522_rear_edge_y = rc522_pos[1] + nfc_reader_depth;

// Poste de anclaje M3 del RC522 a la pared — compartido entre
// openscad/parts/02_chassis/walls.scad (rc522MountBoss()) y
// openscad/parts/03_panels/rc522_bracket.scad (taladro de paso).
rc522_mount_diameter = 10.0;  // mínimo 10mm de diámetro para M3, según docs/DESIGN_RULES.md
rc522_mount_depth    = 6.0;


//=============================================================================
// ESP32 TERMINAL ADAPTER — lateral IZQUIERDO (docs/02_Mechanical_Layout.md,
// sección ESP32: "Situado en el lateral izquierdo"), alojado en el
// panel lateral: montado en VERTICAL contra la cara interior de la
// pared izquierda (no flotando en horizontal, como en un primer
// intento de este ensamblaje).
//
// El ancho de la placa (78 mm) no cabe en el hueco vertical entre el
// disipador y el ventilador (68,4 mm); la profundidad (63 mm) sí. La
// rotación aplicada en assembly_instances.scad pone por tanto el
// ancho de la placa en el eje Y y la profundidad en el eje Z.
//=============================================================================

side_wall_standoff = 2.0;  // separación entre la pared y la cara de montaje de la placa
side_margin        = 3.0;  // (heredado) margen de componentes laterales respecto a la pared interior

// Centro de la franja vertical seguro entre el disipador y el ventilador.
side_mount_z = (z_cooler_top + z_fan_bottom) / 2;

esp32_pos = [
    -(case_width/2 - wall_thickness) + side_wall_standoff,
    0,
    side_mount_z
];


//=============================================================================
// HUB USB — lateral DERECHO (docs/02_Mechanical_Layout.md, sección
// HUB USB: "Situado en el lateral derecho. No alineado con el
// frontal."), alojado en el panel lateral: montado en VERTICAL contra
// la cara interior de la pared derecha. Huella cuadrada
// (44,1 x 44,1 mm), cabe sin problema en la misma franja vertical que
// el ESP32.
//=============================================================================

hub_pos = [
    +(case_width/2 - wall_thickness) - side_wall_standoff,
    0,
    side_mount_z
];


//=============================================================================
// CLÚSTER DEL PANEL FRONTAL: pulsador, OLED, USB empotrable (fila única)
//
// CONFIRMADO por el usuario (2026-08-03): altura de separadores del
// UM790 a 20 mm y estas posiciones en X del pulsador y el USB.
//
// v2 — el usuario ha localizado el componente USB real: una única
// unidad de DOBLE puerto (un solo cuerpo/brida/orificio), conectada
// al HUB mediante dos cables FLEXIBLES, no dos unidades rígidas
// independientes. Esto reduce mucho el ancho necesario en el panel y
// permite reintentar una fila única con el pulsador y el OLED.
//
// Los tres componentes comparten front_cluster_z, elegida para que
// el mayor de los tres en Z (el USB, brida Ø35 mm) quede por debajo
// de la cara inferior de la PCB elevada (z_pcb_bottom, ver más
// arriba) — así ninguno de los tres necesita atravesar la PCB.
//
// Ver docs/03_Virtual_Assembly_Report.md, sección "Fila única con
// USB de doble puerto".
//=============================================================================

front_cluster_margin_to_pcb = 1.5;  // margen entre el punto más alto del clúster y la PCB elevada
front_cluster_z = z_pcb_bottom - front_cluster_margin_to_pcb - usb_front_flange_diameter/2;

// Pulsador — lado IZQUIERDO (docs/02_Mechanical_Layout.md, sección
// Pulsador: "Situado a la izquierda"). Desplazado respecto a
// front_layout.scad (button_x = 24, es decir X global = -54) para
// librar el poste de anclaje izquierdo de la PCB del UM790
// (X = -off_x = -56.5, Ø7 mm): a X=-54 el eje del pulsador pasaba a
// solo 2,5 mm del poste.
pushbutton_post_clearance = 3.0;  // margen adicional respecto a la superficie del poste
pushbutton_min_dx = pushbutton_thread_diameter/2 + um790_post_diameter/2 + pushbutton_post_clearance;

pushbutton_x = -off_x + pushbutton_min_dx;

pushbutton_pos = [
    pushbutton_x,
    front_inner_face_y,
    front_cluster_z
];

// USB empotrable — lado DERECHO, unidad única. Desplazado hacia el
// centro para librar el poste de anclaje derecho de la PCB
// (X = +off_x = 56.5, Ø7 mm).
usb_front_post_clearance = 3.0;
usb_front_min_dx = usb_front_flange_diameter/2 + um790_post_diameter/2 + usb_front_post_clearance;

usb_front_x = off_x - usb_front_min_dx;

// PEDIDO POR EL USUARIO (2026-08-03): subir el USB 2mm respecto al
// resto del cluster (pulsador/OLED, que se quedan igual) — verificado
// que deja margen de sobra respecto al techo del cluster
// (front_panel_led_z_low) y al resto de elementos.
usb_front_z_offset = 2.0;

usb_front_pos = [
    usb_front_x,
    front_inner_face_y,
    front_cluster_z + usb_front_z_offset
];

// OLED — en el hueco que queda entre el pulsador y el USB. Ya no
// puede ir "centrado" en sentido estricto (docs/02_Mechanical_Layout.md
// dice "aproximadamente centrado"): con el pulsador y el USB ya fijados
// para librar los postes de la PCB, el punto medio entre ambos es la
// única posición que deja margen simétrico a los dos lados.
oled_left_neighbour_edge  = pushbutton_x + pushbutton_cap_diameter/2;
oled_right_neighbour_edge = usb_front_x  - usb_front_flange_diameter/2;

oled_pos = [
    (oled_left_neighbour_edge + oled_right_neighbour_edge) / 2,
    front_inner_face_y,
    front_cluster_z
];


//=============================================================================
// LAS TRES ZONAS DEL PANEL FRONTAL — panel inferior mínimo, barra LED
// (dato real) y panel NFC máximo.
//
// Petición del usuario: panel inferior fijo con el tamaño MÍNIMO
// imprescindible, y el resto del hueco disponible para el panel NFC
// (MÁXIMO posible). Cálculo de abajo hacia arriba:
//
//   1. Envolvente vertical del clúster (pulsador + OLED + USB doble).
//   2. Panel inferior fijo = envolvente + front_panel_edge_margin.
//   3. Barra LED (led_bar_height, dato real) justo encima, sin hueco.
//   4. Panel NFC: lo que queda hasta nfc_panel_margin_top.
//
// El resultado de este cálculo (paso 4) es el que se ha aplicado a
// nfc_panel_height en 00_parametros.scad. Aquí se recalcula de forma
// independiente como comprobación cruzada: si nfc_panel_z_low
// (calculado arriba, de arriba hacia abajo, a partir de
// nfc_panel_height) no coincide con front_panel_nfc_z_low_check
// (calculado aquí, de abajo hacia arriba), es que 00_parametros.scad
// se ha quedado desactualizado respecto a alguna de las piezas del
// clúster y hay que revisar docs/03_Virtual_Assembly_Report.md.
//=============================================================================

front_panel_edge_margin = 3.0;  // margen entre el clúster y el borde del panel inferior

front_panel_cluster_z_low = min(
    front_cluster_z - pushbutton_cap_diameter/2,
    front_cluster_z - oled_module_height/2 - 4,       // 4 mm: bloque de pines de oled.scad (oledPins)
    front_cluster_z - usb_front_flange_diameter/2
);

front_panel_cluster_z_high = max(
    front_cluster_z + pushbutton_cap_diameter/2,
    front_cluster_z + oled_module_height/2,
    front_cluster_z + usb_front_flange_diameter/2
);

front_panel_lower_top = front_panel_cluster_z_high + front_panel_edge_margin;

// Tornillos M3 del panel inferior (sin imanes, ver
// openscad/parts/02_chassis/walls.scad y
// openscad/parts/03_panels/lower_panel.scad — comparten estas Z, el
// diámetro y la profundidad para no desincronizarse).
//
// FALLO CORREGIDO (2026-08-14, aviso del usuario): "las diseñaste
// como si fuesen para imanes... configúralas para insertos de
// métrica 3" — estaban dimensionadas para M2. Las paredes YA
// IMPRESAS quedan con el alojamiento M2 antiguo (desactualizadas);
// este cambio es para futuras impresiones propias o de otros
// usuarios, no para las paredes actuales.
//
// SEGUNDO FALLO CORREGIDO (2026-08-15, aviso del usuario: "los
// encajes para los insertos no parecen ser para métrica 3"): el
// primer arreglo usaba un valor ESTIMADO propio (6,5mm) en vez de
// reutilizar insert_diameter/insert_depth (00_parametros.scad),
// que YA es el valor establecido y usado en todo el resto del
// proyecto para insertos M3 (panel trasero, tapa superior) — ahora
// coincide exactamente con esos, en vez de tener un tercer valor
// distinto e inventado.
lower_panel_screw_z_low    = 10.0;
lower_panel_screw_z_high   = front_panel_lower_top - 10.0;
lower_panel_screw_diameter = insert_diameter;   // antes 6.5 (estimado propio) — ahora el mismo valor M3 (4,10mm) que usan el panel trasero y la tapa

// FALLO CORREGIDO (2026-08-18, aviso del usuario con foto del
// montaje real): "Los agujeros de fijación en el panel interior
// están altos. Hay que bajarlos 3mm" — la foto muestra el agujero
// del panel claramente por encima del inserto real de la pared (ya
// impresa, fija). lower_panel_screw_z_low/high (arriba) las
// comparten TANTO la pared (el inserto, sideBossPad() en
// walls.scad) COMO el panel (el taladro de paso, lower_panel.scad)
// — no se pueden bajar directamente sin mover también la pared, que
// no puede cambiar. Se añaden aquí unas Z específicas solo para el
// panel, desplazadas -3mm respecto a las de la pared (que se dejan
// intactas, coinciden con el inserto real).
lower_panel_hole_z_low    = lower_panel_screw_z_low  - 3.0;
lower_panel_hole_z_high   = lower_panel_screw_z_high - 3.0;
lower_panel_screw_depth    = insert_depth;   // antes 5.0 (estimado propio, coincidía por casualidad) — ahora referenciado al mismo valor compartido (5,00mm), para que no se puedan desincronizar

front_panel_led_z_low  = front_panel_lower_top;
front_panel_led_z_high = front_panel_led_z_low + led_bar_height;

front_panel_nfc_z_low_check = front_panel_led_z_high;

front_panel_zones_consistent = (abs(front_panel_nfc_z_low_check - nfc_panel_z_low) < 0.01);
