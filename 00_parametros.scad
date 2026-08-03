//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : 00_parametros.scad
// Versión : 3.0
//
// ÚNICA fuente de parámetros del proyecto.
//
// ============================================================================

$fn = 64;

//=============================================================================
// INFORMACIÓN
//=============================================================================

project_name    = "SteamMachine UM790";
project_version = "3.0";

//=============================================================================
// CARCASA EXTERIOR (Steam Machine original)
//=============================================================================

case_width  = 156.0;
case_depth  = 162.4;
case_height = 152.0;

wall_thickness = 3.0;

bottom_thickness = 3.0;
top_thickness    = 3.0;

//=============================================================================
// CÁMARA INFERIOR
//=============================================================================

lower_air_chamber = 12.0;

//=============================================================================
// BANDEJA
//=============================================================================

tray_width     = 150.0;
tray_depth     = 150.0;
tray_thickness = 3.0;

base_frame_width   = 10.0;
base_outer_chamfer = 4.0;
base_inner_chamfer = 4.0;

//=============================================================================
// PCB UM790
//=============================================================================

pcb_width     = 122.0;
pcb_depth     = 119.5;
pcb_thickness = 1.60;

um790_mount_spacing_x = 113.0;
um790_mount_spacing_y = 99.0;

//=============================================================================
// POSTES
//=============================================================================

um790_post_height   = 6.0;
um790_post_diameter = 7.0;

insert_diameter = 4.10;
insert_depth    = 5.00;

//=============================================================================
// DERIVADOS
//=============================================================================

off_x = um790_mount_spacing_x/2;
off_y = um790_mount_spacing_y/2;

//=============================================================================
// NERVIOS
//=============================================================================

rib_width  = 3.0;
rib_height = 5.0;

//=============================================================================
// VENTILACIÓN
//=============================================================================

bottom_grill_margin = 12.0;

vent_slot_width  = 4.0;
vent_slot_length = 40.0;
vent_spacing     = 8.0;

//=============================================================================
// VENTILADOR SUPERIOR
//=============================================================================

fan_size       = 120.0;
fan_thickness  = 15.0;
fan_hole_pitch = 105.0;

//=============================================================================
// PANEL FRONTAL
//=============================================================================

front_panel_thickness = 3.0;

power_button_diameter = 8.0;

//=============================================================================
// BARRA LED
//=============================================================================

led_bar_width  = 110.0;
led_bar_strip_width = 10.0;              // Dato real proporcionado por el usuario (tira LED)
led_bar_margin       = 1.0;              // Estimado, holgura del canal/difusor impreso a cada lado — "no mucho más margen"
led_bar_height = led_bar_strip_width + 2*led_bar_margin;  // Antes: 8.0 (estimado). Actualizado con dato real.
led_bar_depth  = 3.0;

//=============================================================================
// PANEL NFC
//=============================================================================

nfc_panel_width  = 70.0;

// nfc_panel_height — MAXIMIZADA a costa de dejar el panel inferior
// fijo en su tamaño mínimo imprescindible (petición del usuario).
// Antes: 70.0 (valor original, sin relación con el resto de zonas).
//
// Derivación (ver openscad/reference/components/assembly_positions.scad
// para el cálculo completo, y docs/03_Virtual_Assembly_Report.md):
//   1. Envolvente del clúster inferior (pulsador + OLED + USB doble),
//      con front_cluster_z = 19 mm: Z 1,5 - 36,5 mm.
//   2. Panel inferior fijo mínimo = envolvente + 3 mm de margen = 0-39,5 mm.
//   3. Barra LED (led_bar_height, dato real) justo encima: 39,5-51,5 mm.
//   4. Todo lo que queda hasta nfc_panel_margin_top, para el panel NFC:
//      152 - 51,5 - 12 = 88,5 mm.
//
// IMPORTANTE — depende de decisiones aún NO confirmadas por el
// usuario: la altura de separadores del UM790 elevada a 20 mm (para
// esquivar la PCB y los postes de anclaje) y el reposicionamiento en
// X del pulsador/USB. Si cualquiera de esas dos cambia, este valor
// debe recalcularse.
nfc_panel_height = 88.5;

nfc_panel_depth  = 3.0;

//=============================================================================
// LECTOR NFC
//=============================================================================

nfc_reader_width  = 60.0;
nfc_reader_height = 40.0;
nfc_reader_depth  = 10.0;

//=============================================================================
// HUB USB (CJMCU-204)
//=============================================================================

usb_hub_width  = 44.1;
usb_hub_depth  = 44.1;
usb_hub_height = 12.0;

usb_hub_mount_hole = 3.0;

// Mediremos estas distancias directamente del STL
usb_port_pitch_x = 0;
usb_port_pitch_y = 0;

//=============================================================================
// ESP32
//=============================================================================

esp32_width  = 51.0;
esp32_depth  = 28.0;
esp32_height = 13.0;

//=============================================================================
// PLACA ADAPTADORA ESP32
//=============================================================================

esp32_board_width  = 76.0;
esp32_board_depth  = 76.0;
esp32_board_height = 15.0;

//=============================================================================
// IMANES
//=============================================================================

magnet_diameter = 8.0;
magnet_height   = 3.0;

//=============================================================================
// TORNILLERÍA
//=============================================================================

mount_hole = 3.4;

//=============================================================================
// COMPATIBILIDAD CON VERSIONES ANTERIORES
//=============================================================================

pcb_x = pcb_width;
pcb_y = pcb_depth;

hole_dist_x = um790_mount_spacing_x;
hole_dist_y = um790_mount_spacing_y;

standoff_height = um790_post_height;
standoff_dia    = um790_post_diameter;

insert_dia = insert_diameter;

base_thickness = tray_thickness;

//=============================================================================
// ENSAMBLAJE VIRTUAL V1 — PARÁMETROS ADICIONALES
//=============================================================================
//
// Sección añadida para openscad/reference/virtual_assembly_v1.scad
// y sus módulos en openscad/reference/components/.
//
// Regla: SOLO se añaden parámetros nuevos. No se modifica ni se
// elimina ningún valor ya existente en este archivo, para no
// alterar piezas ya construidas (bandeja, chasis, paneles).
//
// Los valores marcados "Estimado" no proceden de una medición
// directa del componente físico y deberán verificarse antes de
// diseñar piezas imprimibles definitivas.
//
//=============================================================================

//-----------------------------------------------------------------------
// UM790 Pro — disipador, IO trasera, separadores
//-----------------------------------------------------------------------

// Altura de separadores — CONFIRMADA por el usuario para el
// ensamblaje virtual v1 (2026-08-03).
//
// NOTA — sigue habiendo otros dos valores en el proyecto que deben
// reconciliarse antes del diseño definitivo del chasis (fuera del
// alcance de este ensamblaje virtual, que solo verifica; no modifica
// piezas ya construidas ni el DIM aprobado):
//   - openscad/parts/01_bandeja/posts.scad (bandeja física ya construida): 6 mm
//   - docs/02_Mechanical_Layout.md (DIM v1.0, Approved):                   8 mm
//
// A 20 mm, combinado con el reposicionamiento en X del pulsador y el
// USB frontal (también confirmado, ver assembly_positions.scad), la
// PCB, el disipador y los 4 postes de anclaje quedan libres del
// pulsador y del USB frontal: 28/28 pares sin colisión.
// Ver docs/03_Virtual_Assembly_Report.md.
um790_standoff_height = 20.0;

um790_cooler_width  = 88.0;   // Estimado (openscad/reference/um790_reference.scad)
um790_cooler_depth  = 88.0;   // Estimado
um790_cooler_height = 26.0;   // Estimado

um790_rearIO_width  = 90.0;   // Estimado, ancho del bloque de conectores traseros
um790_rearIO_height = 20.0;   // Estimado, altura del conjunto de puertos traseros
um790_rearIO_depth  =
    case_depth/2 - wall_thickness - pcb_depth/2;   // Calculado: hueco hasta el panel trasero

um790_cable_margin = 15.0;    // Margen del volumen de seguridad de cableado alrededor de la PCB

//-----------------------------------------------------------------------
// Ventilador Noctua NF-A12x15 (fan_size / fan_thickness / fan_hole_pitch ya existían)
//-----------------------------------------------------------------------

fan_frame_corner_r = 12.0;   // Estimado, radio de esquina del marco del ventilador
fan_hub_diameter    = 40.0;  // Estimado, solo visual

//-----------------------------------------------------------------------
// ESP32 Terminal Adapter (dimensiones reales de la placa adaptadora)
//-----------------------------------------------------------------------

esp32_adapter_width          = 78.0;
esp32_adapter_depth          = 63.0;
esp32_adapter_thickness      = 1.6;
esp32_adapter_hole_spacing_x = 73.0;
esp32_adapter_hole_spacing_y = 58.0;
esp32_adapter_hole_diameter  = 3.2;   // Holgura para M3

esp32_adapter_component_height = 18.0; // Estimado: ESP32 + regletas + cableado por encima de la placa

//-----------------------------------------------------------------------
// RC522 (nfc_reader_* ya existían) — soporte
//-----------------------------------------------------------------------

rc522_bracket_thickness = 3.0;   // Estimado, brazos de soporte a los laterales del chasis
rc522_bracket_width     = 10.0;  // Estimado, ancho de cada brazo

//-----------------------------------------------------------------------
// Hub USB CJMCU-204 (usb_hub_* ya existían) — sin parámetros nuevos
//-----------------------------------------------------------------------

//-----------------------------------------------------------------------
// OLED 27x27 mm
//-----------------------------------------------------------------------

oled_module_width      = 27.0;
oled_module_height     = 27.0;
oled_module_thickness  = 1.5;   // Estimado, cristal + PCB
oled_module_pin_height = 6.0;   // Estimado, pines/soldadura por detrás del módulo

//-----------------------------------------------------------------------
// Pulsador M16 x 55 mm
//-----------------------------------------------------------------------

pushbutton_thread_diameter = 16.0;
pushbutton_cap_diameter    = 19.5;  // Estimado, diámetro del embellecedor visible en el panel
pushbutton_total_length    = 55.0;  // Dato real proporcionado (rosca + cuerpo del mecanismo)

//-----------------------------------------------------------------------
// USB empotrable frontal — unidad DOBLE de un solo cuerpo (2 puertos
// USB-A en una sola brida/rosca, conectada al HUB mediante dos cables
// flexibles con conector USB-A macho), según el componente real
// localizado por el usuario. Sustituye al diseño anterior de dos
// unidades independientes (usb_front_pair_spacing, obsoleto).
//-----------------------------------------------------------------------

usb_front_hole_diameter   = 29.0;  // Estimado, orificio de paso en el panel
usb_front_flange_diameter = 35.0;  // Estimado, brida/rosca (algo mayor que la versión de un puerto, aloja 2 USB-A)
usb_front_body_length     = 22.0;  // Estimado, tramo RÍGIDO: rosca + fuelle corrugado, antes del cable
usb_front_cable_diameter  = 5.0;   // Estimado, cada uno de los 2 cables flexibles
usb_front_cable_length    = 120.0; // Estimado, longitud de cable disponible hasta el conector USB-A macho

// Parámetro obsoleto (diseño anterior, 2 unidades independientes).
// Se mantiene documentado por si se recupera esa opción más adelante.
// usb_front_pair_spacing = 34.0;

//=============================================================================
// FILOSOFÍA DEL PROYECTO
//=============================================================================
//
// - Chasis principal fijo.
// - Panel trasero desmontable.
// - Panel superior desmontable.
// - Panel NFC intercambiable.
// - Módulo USB + pulsador independiente y sustituible.
// - Soporte ESP32 desmontable.
// - Toda pieza deberá obtener sus dimensiones EXCLUSIVAMENTE
//   desde este archivo.
//
