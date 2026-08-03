//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : assembly_instances.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
//
// Envuelve cada módulo de componente (openscad/reference/components/*.scad)
// con su posición y rotación definitiva dentro del ensamblaje, usando
// las posiciones calculadas en assembly_positions.scad.
//
// Para cada componente se exponen, cuando aplica:
//   <nombre>InstanceBody()    → solo el volumen mecánico rígido
//                                 (para la comprobación de colisiones "duras")
//   <nombre>InstanceKeepout() → solo el volumen de seguridad / cableado
//   <nombre>InstanceFull()    → cuerpo + volumen de seguridad (visualización)
//
// Los componentes montados en el panel frontal (pulsador, USB
// empotrables) se giran -90º sobre X para que su eje de protrusión
// local (+Z) coincida con el eje +Y global (hacia el interior del
// chasis). El resto de componentes ya están modelados con el eje
// vertical local (+Z) coincidiendo con el vertical global.
//
// ============================================================================

include <assembly_positions.scad>;

use <um790.scad>;
use <noctua.scad>;
use <rc522.scad>;
use <esp32.scad>;
use <hub_usb.scad>;
use <oled.scad>;
use <usb_front.scad>;
use <pushbutton.scad>;


//=============================================================================
// UM790
//=============================================================================

module um790InstanceBody()
{
    translate(um790_pos) um790Body();
}

module um790InstanceKeepout()
{
    translate(um790_pos) um790CableKeepout();
}

module um790InstanceFull()
{
    translate(um790_pos) um790();
}


//=============================================================================
// VENTILADOR NOCTUA
//=============================================================================

module noctuaInstanceBody()
{
    translate(fan_pos) noctuaBody();
}

module noctuaInstanceKeepout()
{
    translate(fan_pos) noctuaAirflowKeepout();
}

module noctuaInstanceFull()
{
    translate(fan_pos) noctua();
}


//=============================================================================
// RC522
//=============================================================================

module rc522InstanceBody()
{
    translate(rc522_pos) rc522Body();
}

module rc522InstanceKeepout()
{
    translate(rc522_pos) rc522CableKeepout();
}

module rc522InstanceFull()
{
    translate(rc522_pos) rc522();
}


//=============================================================================
// ESP32 TERMINAL ADAPTER
//=============================================================================

module esp32InstanceBody()
{
    translate(esp32_pos) esp32Body();
}

module esp32InstanceKeepout()
{
    translate(esp32_pos) esp32CableKeepout();
}

module esp32InstanceFull()
{
    translate(esp32_pos) esp32();
}


//=============================================================================
// HUB USB
//=============================================================================

module hubInstanceBody()
{
    translate(hub_pos) hubUsbBodyFull();
}

module hubInstanceKeepout()
{
    translate(hub_pos) hubUsbCableKeepout();
}

module hubInstanceFull()
{
    translate(hub_pos) hubUsb();
}


//=============================================================================
// OLED
//=============================================================================

module oledInstanceBody()
{
    translate(oled_pos) oledBody();
}

module oledInstanceFull()
{
    translate(oled_pos) oled();
}


//=============================================================================
// PULSADOR (girado: protrusión local +Z → +Y global)
//=============================================================================

module pushbuttonInstanceBody()
{
    translate(pushbutton_pos) rotate([-90,0,0]) pushbuttonFull();
}

module pushbuttonInstanceFull()
{
    pushbuttonInstanceBody();
}


//=============================================================================
// USB FRONTALES (girado: protrusión local +Z → +Y global)
//=============================================================================

module usbFrontInstanceBody()
{
    translate(usb_front_pos) rotate([-90,0,0]) usbFrontBody();
}

module usbFrontInstanceKeepout()
{
    translate(usb_front_pos) rotate([-90,0,0]) usbFrontCableKeepout();
}

module usbFrontInstanceFull()
{
    translate(usb_front_pos) rotate([-90,0,0]) usbFront();
}


//=============================================================================
// TODOS LOS CUERPOS RÍGIDOS (para la comprobación global de colisiones)
//=============================================================================

module allBodies()
{
    um790InstanceBody();
    noctuaInstanceBody();
    rc522InstanceBody();
    esp32InstanceBody();
    hubInstanceBody();
    oledInstanceBody();
    pushbuttonInstanceBody();
    usbFrontInstanceBody();
}


//=============================================================================
// TODOS LOS COMPONENTES COMPLETOS (para la visualización del ensamblaje)
//=============================================================================

module allComponents()
{
    um790InstanceFull();
    noctuaInstanceFull();
    rc522InstanceFull();
    esp32InstanceFull();
    hubInstanceFull();
    oledInstanceFull();
    pushbuttonInstanceFull();
    usbFrontInstanceFull();
}
