//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : chassis_layout.scad
// Versión : 3.0
//
// Layout general del chasis.
// NO genera geometría.
// Solo contiene posiciones de todos los módulos.
//
// ============================================================================

include <../../00_parametros.scad>;


//=============================================================================
// DIMENSIONES DEL CHASIS
//=============================================================================

chassis_width  = case_width;
chassis_depth  = case_depth;
chassis_height = case_height;


//=============================================================================
// CÁMARA INFERIOR
//=============================================================================

// Espacio libre entre el fondo y la bandeja.

bottom_air_gap = 12;


//=============================================================================
// BANDEJA
//=============================================================================

tray_pos_x = (chassis_width - tray_width)/2;
tray_pos_y = (chassis_depth - tray_depth)/2;
tray_pos_z = bottom_air_gap;


//=============================================================================
// UM790
//=============================================================================

um790_pos_x = tray_pos_x + (tray_width - pcb_width)/2;
um790_pos_y = tray_pos_y + (tray_depth - pcb_depth)/2;
um790_pos_z = tray_pos_z + tray_thickness;


//=============================================================================
// PANEL FRONTAL
//=============================================================================

// Zona inferior

front_usb_height = 18;
front_power_height = 18;

// Barra LED

front_led_height = 32;
front_led_width  = 120;

// Panel NFC

front_nfc_width  = 120;
front_nfc_height = 70;


//=============================================================================
// LECTOR NFC
//=============================================================================

nfc_reader_width  = 60;
nfc_reader_height = 40;

nfc_reader_pos_x = chassis_width/2;
nfc_reader_pos_y = 8;
nfc_reader_pos_z = chassis_height-42;


//=============================================================================
// ESP32
//=============================================================================

esp32_width = 55;
esp32_depth = 28;

esp32_pos_x = chassis_width/2;
esp32_pos_y = chassis_depth/2;
esp32_pos_z = chassis_height-30;


//=============================================================================
// PLACA DE EXPANSIÓN ESP32
//=============================================================================

esp_board_width = 76;
esp_board_depth = 76;

esp_board_pos_x = chassis_width/2;
esp_board_pos_y = chassis_depth/2;
esp_board_pos_z = chassis_height-25;


//=============================================================================
// VENTILADOR SUPERIOR
//=============================================================================

fan_size = 120;
fan_depth = 15;

fan_pos_x = chassis_width/2;
fan_pos_y = chassis_depth/2;
fan_pos_z = chassis_height-top_thickness;


//=============================================================================
// PANEL TRASERO
//=============================================================================

rear_panel_thickness = 3;


//=============================================================================
// CONECTORES
//=============================================================================

// Todos en el panel trasero desmontable.

power_connector = true;
hdmi_connector  = true;
usb_connector   = true;
rj45_connector  = true;


//=============================================================================
// MÓDULOS DESMONTABLES
//=============================================================================

top_panel_removable  = true;
rear_panel_removable = true;

left_panel_removable  = false;
right_panel_removable = false;
front_panel_removable = false;


//=============================================================================
// COMPONENTES EN LA TAPA SUPERIOR
//=============================================================================

top_panel_contains_fan      = true;
top_panel_contains_esp32    = true;
top_panel_contains_expansion= true;


//=============================================================================
// COMPONENTES EN EL FRONTAL
//=============================================================================

front_contains_usb       = true;
front_contains_power     = true;
front_contains_statusled = true;
front_contains_rgb       = true;
front_contains_nfc       = true;
