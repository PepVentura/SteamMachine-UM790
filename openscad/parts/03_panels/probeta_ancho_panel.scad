//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : probeta_ancho_panel.scad
// Versión  : 1.0
// Fecha    : 2026-08-16
// Autor    : Pep Ventura (asistido por Claude)
//
// PROBETA DE PRUEBA — no es una pieza del chasis. Sirve solo para
// validar la merma real de impresión antes de aplicar el cambio de
// ancho a los paneles definitivos (lower_panel.scad, nfc_panel.scad).
//
// CONTEXTO (2026-08-16): el usuario midió con regla el hueco interior
// real del chasis ya impreso (149mm) y el panel ya impreso (150mm,
// diseñado a 151mm) — el panel real queda MÁS ANCHO que el hueco
// real, no debería encajar bien. Propuesta: bajar el ancho de diseño
// a 149mm (con la misma merma de ~1mm ya observada, debería salir en
// ~148mm real, dejando 1mm de holgura total frente al hueco real de
// 149mm). Esta probeta sirve para confirmarlo ANTES de tocar los
// archivos definitivos.
//
// CÓMO USARLA: imprime esta pieza tal cual, luego:
//   1. Mide su ancho real con calibre — compáralo con los 149mm de
//      diseño para confirmar la merma real de esta impresión/material.
//   2. Pruébala directamente en el hueco del chasis (el rebaje
//      central, más estrecho, es del tamaño del marco lateral — deja
//      encajar la probeta igual que encajaría el borde de un panel
//      real). Si entra con una holgura razonable, el ancho de 149mm
//      es un buen valor para aplicar a los paneles de verdad.
//
// ============================================================================

test_width  = 149.0;  // el valor propuesto a validar
test_height = 20.0;   // ESTIMADO — alto suficiente para manejarla y medirla cómodamente
test_thickness = 3.0; // mismo grosor que los paneles reales (front_panel_thickness)

module probetaAnchoPanel()
{

    difference()
    {

        // Barra principal, al ancho a validar
        translate([-test_width/2, -test_height/2, 0])
            cube([test_width, test_height, test_thickness]);

        // Marcas de referencia grabadas en los dos extremos (0 y
        // 149mm), para poder verificar la medida real con calibre
        // sin ambigüedad sobre dónde empieza/acaba la pieza
        for(x=[-test_width/2, test_width/2])
            translate([x, 0, test_thickness-0.4])
                cylinder(r=1.5, h=0.5, $fn=24);

    }

}

probetaAnchoPanel();
