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

rear_io_cut_margin = 2.0;  // holgura alrededor del bloque de IO real


//=============================================================================
// PLACA MACIZA
//=============================================================================

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
        -(case_width - 2*wall_thickness)/2,
        case_depth/2 - wall_thickness,
        bottom_thickness
    ])

        cube([case_width - 2*wall_thickness, wall_thickness, shell_height-bottom_thickness]);

}


//=============================================================================
// RECORTE DE LA IO TRASERA DEL UM790
//
// Posición derivada de um790_pos (assembly_positions.scad) y de las
// dimensiones del bloque de IO trasera definidas en um790.scad
// (um790_rearIO_width/height, 00_parametros.scad), con un margen para
// que los conectores sean accesibles sin rozar el borde impreso.
//=============================================================================

module rearIOCut()
{

    cutWidth  = um790_rearIO_width  + 2*rear_io_cut_margin;
    cutHeight = um790_rearIO_height + 2*rear_io_cut_margin;

    ioZlow = um790_pos[2] + pcb_thickness - rear_io_cut_margin;

    translate([
        -cutWidth/2,
        case_depth/2 - wall_thickness - 1,
        ioZlow
    ])

        cube([
            cutWidth,
            wall_thickness + 2,
            cutHeight
        ]);

}


//=============================================================================
// LENGÜETA DE UNIÓN CON LA BANDEJA
//
// docs/02_Mechanical_Layout.md, sección 7: "M3 - panel trasero".
// Resuelve el hueco entre el borde trasero de la bandeja
// (tray_depth/2 = 75 mm) y la cara frontal de este panel
// (case_depth/2 - wall_thickness = 78,2 mm): 3,2 mm — ver
// docs/03_Virtual_Assembly_Report.md.
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
