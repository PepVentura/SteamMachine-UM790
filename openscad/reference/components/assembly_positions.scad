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
//   Z: altura (case_height = 152.0 mm, con patas) → 0 (base) .. case_height (techo)
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
z_top_skin_bottom = case_height - top_thickness;

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
nfc_panel_margin_top = 12;
nfc_panel_z_low  = case_height - nfc_panel_margin_top - nfc_panel_height;
nfc_panel_z_high = nfc_panel_z_low + nfc_panel_height;
nfc_panel_z_mid  = (nfc_panel_z_low + nfc_panel_z_high) / 2;


//=============================================================================
// UM790 (PCB + disipador + IO trasera)
//=============================================================================

// Centrado en X/Y sobre la bandeja.
um790_pos = [0, 0, z_pcb_bottom];


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

rc522_pos = [0, front_inner_face_y + rc522_panel_gap, nfc_panel_z_mid];

rc522_rear_edge_y = rc522_pos[1] + nfc_reader_depth;


//=============================================================================
// ESP32 TERMINAL ADAPTER — lateral IZQUIERDO (docs/02_Mechanical_Layout.md,
// sección ESP32: "Situado en el lateral izquierdo", cerca del RC522, el
// OLED y la barra LED). Montado en una repisa por encima del disipador
// y por debajo del ventilador, igual que el resto de electrónica
// suspendida en la cámara intermedia.
//=============================================================================

shelf_clearance = 7.0;  // margen de todas las repisas sobre la cara superior del disipador
side_margin     = 3.0;  // margen de todos los componentes laterales respecto a la pared interior
front_margin    = 6.0;  // margen respecto al borde trasero del RC522

esp32_pos = [
    -(case_width/2 - wall_thickness - esp32_adapter_width/2 - side_margin),
    rc522_rear_edge_y + front_margin + esp32_adapter_depth/2,
    z_cooler_top + shelf_clearance
];


//=============================================================================
// HUB USB — lateral DERECHO, no alineado con el frontal
// (docs/02_Mechanical_Layout.md, sección HUB USB: "Situado en el
// lateral derecho. No alineado con el frontal."). Se mantiene en el
// mismo lado que los USB frontales para que el cableado sea corto,
// pero desplazado hacia el centro de la profundidad del chasis.
//=============================================================================

hub_rear_offset = 20.0;  // desplazamiento respecto al centro de profundidad (no alineado con el frontal)

hub_pos = [
    +(case_width/2 - wall_thickness - usb_hub_width/2 - side_margin),
    hub_rear_offset,
    z_cooler_top + shelf_clearance
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

usb_front_pos = [
    usb_front_x,
    front_inner_face_y,
    front_cluster_z
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

front_panel_led_z_low  = front_panel_lower_top;
front_panel_led_z_high = front_panel_led_z_low + led_bar_height;

front_panel_nfc_z_low_check = front_panel_led_z_high;

front_panel_zones_consistent = (abs(front_panel_nfc_z_low_check - nfc_panel_z_low) < 0.01);
