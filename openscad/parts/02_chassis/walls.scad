//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : walls.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Paredes laterales (izquierda/derecha) del chasis principal fijo.
//
// NO incluye pared frontal (panel magnético, ver
// docs/DESIGN_RULES.md: "El panel frontal será completamente
// desmontable") ni pared trasera (va unida a la bandeja, ver
// docs/DESIGN_RULES.md: "El panel trasero irá unido a la bandeja").
//
// Incluye:
//   - Alojamientos de imanes en el borde frontal, para la fijación
//     del panel frontal intercambiable.
//   - Postes de anclaje M3 para los brazos del soporte del RC522
//     (rc522Bracket() en openscad/reference/components/rc522.scad),
//     a la altura ya validada en el ensamblaje virtual.
//
// Sistema de coordenadas: igual que
// openscad/reference/components/assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del chasis.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <../../lib/magnets.scad>;
use <../../lib/shapes.scad>;

$fn = 32;

part_version = "1.0";


//=============================================================================
// PARÁMETROS DE ESTA PIEZA
//=============================================================================

// Imanes de sujeción del panel NFC — SOLO dentro de la franja del
// panel NFC (docs/02_Mechanical_Layout.md, sección 6: "Panel NFC:
// Imanes." / "Panel inferior: No imanes. Se fijará mediante tornillos
// M2 sobre insertos térmicos."). Corregido: la primera versión de
// esta pieza ponía un imán en Z=25, dentro de la zona del panel
// inferior (0-39,5 mm), que NO lleva imanes.
//
// FALLO CORREGIDO (2026-08-03, pregunta del usuario: "¿has tenido en
// cuenta la ubicación de los imanes?"): estas dos posiciones se
// calculaban a partir de nfc_panel_z_low/z_high — al ampliar la
// altura del panel NFC 12mm (0.9.0 y rondas posteriores),
// front_magnet_z_high se desplazó automáticamente de Z=121 a Z=133,
// un desajuste de 12mm frente a la pared REAL ya impresa (que tiene
// el imán fijo en Z=121, posición inmutable). Fijados ahora a
// valores absolutos, independientes de la altura del panel — deben
// coincidir exactamente con nfc_magnet_z_low/high en nfc_panel.scad.
front_magnet_z_low  = 66.5;
front_magnet_z_high = 121.0;
front_magnet_inset  = magnet_height + 0.6;  // profundidad del alojamiento, con margen de pared

// Insertos térmicos M2 del panel inferior atornillado (no magnético).
// lower_panel_screw_diameter/depth/z_low/z_high: ver
// assembly_positions.scad (compartidos también con
// openscad/parts/03_panels/lower_panel.scad)

// RELLENO LOCAL para los imanes y tornillos M2 — FALLO ENCONTRADO
// (2026-08-03, captura del usuario): el imán (magnet_diameter +
// magnet_clearance = 8,15 mm) es más ANCHO que la propia pared
// (wall_thickness = 3 mm): asomaba 5,15 mm por la cara exterior,
// visible desde fuera. Se añade un relleno local (más grosor de
// pared, solo en esos puntos) por el lado NO visto, y el alojamiento
// se recentra dentro de ese grosor extra para quedar completamente
// oculto una vez puesto el panel frontal.
//
// side_boss_margin y side_boss_depth y side_boss_size están en
// assembly_positions.scad (fuente única, compartida con los paneles
// frontales — ver sideMountGlobalX() y wallPadRelief() ahí).

// Poste de anclaje M3 para el brazo del soporte del RC522.
// rc522_mount_diameter/depth: ver assembly_positions.scad
// (compartidos también con openscad/parts/03_panels/rc522_bracket.scad)

// Postes de anclaje M3 para el ESP32 y el HUB, montados en vertical
// contra la pared (ver assembly_instances.scad: esp32InstanceBody,
// hubInstanceBody, giro rotate([0,0,90]) rotate([90,0,0]) y
// rotate([0,-90,0]) respectivamente).
//
// La profundidad del poste usa side_wall_standoff (ya definido en
// assembly_positions.scad) en vez de un valor propio: si no coincide
// exactamente con la separación real entre la pared y la placa, el
// poste sobresale y atraviesa la propia placa (fallo encontrado y
// corregido en esta verificación).
side_mount_diameter = 8.0;
side_mount_depth    = side_wall_standoff;


//=============================================================================
// UNA PARED (genérica, se usa para izquierda y derecha)
//=============================================================================

module sideWallSolid()
{

    cube([wall_thickness, case_depth, shell_height]);

}


//=============================================================================
// RELLENO LOCAL (por el lado no visto) EN LOS PUNTOS DE IMÁN/TORNILLO
//
// dir: +1 = pared izquierda (cara vista en X local=0, el relleno
// crece hacia +X); -1 = pared derecha (cara vista en X local=
// wall_thickness, el relleno crece hacia -X).
//=============================================================================

module sideBossPad(dir, z)
{

    extra = side_boss_depth - wall_thickness;
    xStart = (dir>0) ? wall_thickness : -extra;

    // CORREGIDO (2026-08-03, a petición del usuario): antes empezaba
    // en Y=0 (el borde exterior de la pared, coincidiendo exactamente
    // con la cara EXTERIOR de los paneles frontales) — dejaba
    // imposible que el panel tuviera ningún material sólido ahí sin
    // sobresalir hacia fuera o invadir el relleno. Ahora empieza en
    // Y=front_panel_thickness (la cara INTERIOR del panel), dejando
    // el panel completamente libre en esa zona.
    translate([xStart, front_panel_thickness, z - side_boss_size/2])
        cube([extra, side_boss_size, side_boss_size]);

}

// Centro X (local) del alojamiento, ya recentrado dentro del relleno,
// para un radio de corte dado.
function sideBossCutX(dir, radius) =
    (dir>0)
        ? (side_boss_margin + radius)
        : (wall_thickness - side_boss_margin - radius);


//=============================================================================
// FIJACIÓN PARED-PANEL TRASERO — RETIRADA (2026-08-03)
//
// Colisionaba: el relleno (side_boss_size = 14 mm de lado) es mucho
// más ancho que el grosor del panel trasero (wall_thickness = 3 mm),
// y el material del panel alrededor del taladro de paso invadía el
// relleno. Requiere una muesca de alivio en el panel para resolverse
// bien; pendiente de una futura revisión. El panel trasero se
// sujetaba también a la bandeja mediante unas lengüetas
// (rearBridgeTabs(), openscad/parts/03_panels/rear_panel.scad) —
// ELIMINADAS (2026-08-17, petición del usuario). Se sujeta ahora
// solo con los tornillos a las paredes laterales
// (rearWallScrewHoles(), ya verificados sin colisión).
//=============================================================================


//=============================================================================
// ALOJAMIENTOS DE IMANES DEL PANEL FRONTAL
//
// CORREGIDO (2026-08-03, a petición del usuario): antes se abría
// justo en Y=-case_depth/2 (el borde exterior de la carcasa,
// coincidiendo con la cara EXTERIOR del panel) — el panel no podía
// tener ningún material sólido en esa zona sin sobresalir hacia
// fuera o invadir el relleno. Ahora se abre en
// Y = -case_depth/2 + front_panel_thickness (la cara INTERIOR del
// panel) — el panel queda libre, plano, sin agujero ni bulto; el
// imán toca directamente su cara trasera al montarlo.
//=============================================================================

module frontMagnetCuts(dir)
{

    cutX = sideBossCutX(dir, (magnet_diameter+magnet_clearance)/2);

    for(z=[front_magnet_z_low, front_magnet_z_high])

        translate([cutX, front_panel_thickness, z])

            rotate([-90,0,0])

                magnetSocket(
                    diameter  = magnet_diameter,
                    height    = front_magnet_inset,
                    clearance = magnet_clearance
                );

}


//=============================================================================
// POSTE DE ANCLAJE DEL SOPORTE RC522
//
// Se sitúa en la cara interior de la pared, a la altura del centro
// del soporte (rc522_pos[2], ver assembly_positions.scad), cerca del
// borde frontal (mismo Y que el soporte).
//
// wallInnerX: cara interior de la pared donde se ancla el poste
// (coordenada GLOBAL, no relativa a la pared) — distinta para la
// pared izquierda y la derecha, por eso se recibe como parámetro.
//
// dir: sentido de crecimiento del poste, HACIA EL INTERIOR del
// chasis (+1 = pared izquierda, crece hacia +X; -1 = pared derecha,
// crece hacia -X). FALLO CORREGIDO (2026-08-03): con un único sentido
// fijo, el poste de la pared derecha crecía hacia +X (hacia fuera),
// saliendo 3 mm por la cara exterior de la pared — visible por fuera,
// detectado en una captura del usuario.
//=============================================================================

module rc522MountBoss(wallInnerX, dir)
{

    translate([
        wallInnerX,
        rc522_pos[1] + nfc_reader_depth/2,
        rc522_pos[2]
    ])

        rotate([0,dir*90,0])

            tube(
                outerDiameter = rc522_mount_diameter,
                innerDiameter = insert_diameter,
                height        = rc522_mount_depth
            );

}


//=============================================================================
// POSTES DE ANCLAJE DEL ESP32 (4x M3)
//
// Placa montada en vertical (ver assembly_instances.scad). Con el
// giro aplicado allí, el ancho de la placa (taladros separados
// esp32_adapter_hole_spacing_x) queda en el eje Y, y la profundidad
// (esp32_adapter_hole_spacing_y) en el eje Z.
//=============================================================================

module esp32MountBosses(wallInnerX)
{

    for(iy=[-1,1])
    for(iz=[-1,1])

        translate([
            wallInnerX,
            esp32_pos[1] + iy*esp32_adapter_hole_spacing_x/2,
            esp32_pos[2] + iz*esp32_adapter_hole_spacing_y/2
        ])

            rotate([0,90,0])

                tube(
                    outerDiameter = side_mount_diameter,
                    innerDiameter = esp32_adapter_hole_diameter,
                    height        = side_mount_depth
                );

}


//=============================================================================
// POSTES DE ANCLAJE DEL HUB USB (4x, huella cuadrada)
//
// Con el giro aplicado en assembly_instances.scad
// (rotate([0,-90,0])), los taladros (a usb_hub_mount_hole de cada
// borde, con 4 mm de margen — ver hubUsbMountHoles() en
// hub_usb.scad) quedan en el plano Y/Z.
//
// Se llama solo desde la pared DERECHA (rightWall()): debe crecer
// hacia -X (hacia el interior). FALLO CORREGIDO (2026-08-03): usaba
// el mismo rotate([0,90,0]) que el poste del ESP32 (pared izquierda),
// así que crecía hacia fuera — mismo fallo que rc522MountBoss(),
// detectado en una captura del usuario.
//=============================================================================

module hubMountBosses(wallInnerX)
{

    h = usb_hub_width/2  - usb_hub_mount_inset_z;
    d = usb_hub_depth/2  - usb_hub_mount_inset_y;

    for(iy=[-1,1])
    for(iz=[-1,1])

        translate([
            wallInnerX,
            hub_pos[1] + iy*d,
            hub_pos[2] + iz*h
        ])

            rotate([0,-90,0])

                tube(
                    outerDiameter = side_mount_diameter,
                    innerDiameter = usb_hub_mount_hole,
                    height        = side_mount_depth
                );

}


//=============================================================================
// INSERTOS M3 DEL PANEL INFERIOR (atornillado, no magnético)
//
// FALLO CORREGIDO (2026-08-14, aviso del usuario): estaban
// dimensionados para M2 — corregido a M3. Las paredes YA IMPRESAS
// quedan con el alojamiento M2 antiguo (desactualizadas); este
// cambio es para futuras impresiones propias o de otros usuarios.
//
// Reutiliza magnetSocket() como recorte cilíndrico genérico (no
// porque el panel inferior lleve imanes — no los lleva, ver DIM
// sección 6 — sino porque el módulo ya hace exactamente el corte
// cilíndrico recesado que necesita un inserto térmico M3).
//=============================================================================

module lowerPanelScrewCuts(dir)
{

    // FALLO CORREGIDO (2026-08-03, opción 3 elegida por el usuario):
    // sideBossCutX() posicionaba el inserto con margen respecto a la
    // cara EXTERIOR de la pared (X=78) — el avellanado del panel
    // (más ancho que el simple taladro) se salía por el borde real
    // del panel inferior (X=75). Ahora se usa panelMountX(), con
    // margen respecto al borde REAL del panel — coincide exactamente
    // con lowerPanelScrewHoles() en lower_panel.scad (misma fuente).
    cutX = (dir>0)
        ? (case_width/2 - panelMountX(lower_panel_csk_radius))
        : (panelMountX(lower_panel_csk_radius) - (case_width/2-wall_thickness));

    // CORREGIDO (2026-08-03): mismo criterio que frontMagnetCuts() —
    // recesado 3mm hacia dentro para dejar el panel libre y plano.
    for(z=[lower_panel_screw_z_low, lower_panel_screw_z_high])

        translate([cutX, front_panel_thickness, z])

            rotate([-90,0,0])

                magnetSocket(
                    diameter  = lower_panel_screw_diameter,
                    height    = lower_panel_screw_depth,
                    clearance = 0
                );

}


//=============================================================================
// FIJACIÓN DEL PANEL TRASERO A LA PARED
//
// Además de la unión con la bandeja que tenía originalmente (unas
// lengüetas, rearBridgeTabs() — ELIMINADAS 2026-08-17, petición del
// usuario), el panel trasero se atornilla también a ambas paredes
// (aviso del usuario: un panel de 148 mm de alto solo sujeto por la
// bandeja quedaba poco firme). Mismo patrón de relleno + recorte ya
// usado para los imanes/tornillos frontales — el inserto
// (insert_diameter = 4,10 mm) también es más ancho que la pared.
//
// Tras la eliminación de las lengüetas, estos tornillos a la pared
// son ahora la ÚNICA fijación del panel trasero.
//
// NOTA: un primer intento de esto (mismo día) se retiró por no
// resolverse a tiempo, y quedó documentado como "retirado" en el
// changelog — ese registro estaba desactualizado; esta es la
// implementación real, con la muesca de alivio correspondiente ya
// añadida también en rear_panel.scad.
//=============================================================================

// rear_wall_screw_diameter/z_low/z_high: ver assembly_positions.scad
// (compartidos también con openscad/parts/03_panels/rear_panel.scad)

module rearBossPad(dir, z)
{

    extra = side_boss_depth - wall_thickness;
    xStart = (dir>0) ? wall_thickness : -extra;

    // CORREGIDO (2026-08-03): mismo criterio que sideBossPad() —
    // recesado wall_thickness (grosor del panel trasero) hacia
    // dentro, para dejar el panel trasero libre y plano en esa zona.
    translate([xStart, case_depth-side_boss_size-wall_thickness, z - side_boss_size/2])
        cube([extra, side_boss_size, side_boss_size]);

}

module rearWallScrewCuts(dir)
{

    // FALLO CORREGIDO (2026-08-03, opción 3 elegida por el usuario):
    // mismo criterio que lowerPanelScrewCuts() — panelMountX() en vez
    // de sideBossCutX(), para que el avellanado quepa dentro del
    // borde real del panel trasero.
    cutX = (dir>0)
        ? (case_width/2 - panelMountX(rear_csk_radius))
        : (panelMountX(rear_csk_radius) - (case_width/2-wall_thickness));

    for(z=[rear_wall_screw_z_low, rear_wall_screw_z_high])

        translate([cutX, case_depth-wall_thickness, z])

            rotate([90,0,0])

                magnetSocket(
                    diameter  = rear_wall_screw_diameter,
                    height    = insert_depth,
                    clearance = 0
                );

}


//=============================================================================
// INSERTOS M3 DE LA TAPA (borde superior de la pared)
//
// Deben coincidir en X/Y con topScrewHoles() en
// openscad/parts/02_chassis/top.scad.
//
// FALLO CORREGIDO (2026-08-03): igual que los imanes/tornillos
// laterales, el inserto (insert_diameter = 4,10 mm) es más ancho que
// la pared (wall_thickness = 3 mm) — asomaba 0,55 mm por cada cara.
// Se añade un pequeño relleno local (topInsertPad()) por el lado NO
// visto, igual que sideBossPad() pero para este inserto vertical.
//=============================================================================

// top_insert_pad_depth: ver 00_parametros.scad (compartido con
// openscad/parts/02_chassis/top.scad, topInsertRelief())

module topInsertPad(dir, y)
{

    // CORREGIDO (2026-08-03, aviso del usuario: "perforaciones
    // rectangulares en vez de agujeros avellanados"): el relleno
    // llegaba hasta Z=shell_height+1, pasando la cara EXTERIOR de la
    // tapa (Z=shell_height) — la tapa no tenía sitio para su propio
    // material sin invadirlo, de ahí la gran muesca rectangular de
    // alivio. Igual que con los imanes/tornillos frontales y
    // traseros: el relleno ahora PARA en la cara INTERIOR de la tapa
    // (Z=shell_height-top_thickness), no llega a la exterior.
    extra = top_insert_pad_depth - wall_thickness;
    xStart = (dir>0) ? wall_thickness : -extra;

    translate([xStart, y - side_boss_size/2, shell_height - top_thickness - side_boss_size])
        cube([extra, side_boss_size, side_boss_size]);

}

module topScrewInsertCuts(dir)
{

    // CORREGIDO (2026-08-03): mismo criterio — el inserto abre ahora
    // en la cara interior de la tapa (Z=shell_height-top_thickness),
    // no más allá.
    cutX = sideBossCutX(dir, insert_diameter/2);

    for(z=[wall_thickness + top_screw_y_inset, case_depth - wall_thickness - top_screw_y_inset])

        translate([
            cutX,
            z,
            shell_height - top_thickness - insert_depth
        ])

            cylinder(d = insert_diameter, h = insert_depth + 0.1);

}


//=============================================================================
// PARED IZQUIERDA
//=============================================================================

module leftWall()
{

    translate([-case_width/2, -case_depth/2, 0])

        difference()
        {

            union()
            {
                sideWallSolid();
                sideBossPad(+1, front_magnet_z_low);
                sideBossPad(+1, front_magnet_z_high);
                sideBossPad(+1, lower_panel_screw_z_low);
                sideBossPad(+1, lower_panel_screw_z_high);
                topInsertPad(+1, wall_thickness + top_screw_y_inset);
                topInsertPad(+1, case_depth - wall_thickness - top_screw_y_inset);
                rearBossPad(+1, rear_wall_screw_z_low);
                rearBossPad(+1, rear_wall_screw_z_high);
            }

            frontMagnetCuts(+1);

            lowerPanelScrewCuts(+1);

            topScrewInsertCuts(+1);

            rearWallScrewCuts(+1);

        }

    rc522MountBoss(-case_width/2 + wall_thickness, +1);

    esp32MountBosses(-case_width/2 + wall_thickness);

}


//=============================================================================
// PARED DERECHA
//=============================================================================

module rightWall()
{

    translate([case_width/2-wall_thickness, -case_depth/2, 0])

        difference()
        {

            union()
            {
                sideWallSolid();
                sideBossPad(-1, front_magnet_z_low);
                sideBossPad(-1, front_magnet_z_high);
                sideBossPad(-1, lower_panel_screw_z_low);
                sideBossPad(-1, lower_panel_screw_z_high);
                topInsertPad(-1, wall_thickness + top_screw_y_inset);
                topInsertPad(-1, case_depth - wall_thickness - top_screw_y_inset);
                rearBossPad(-1, rear_wall_screw_z_low);
                rearBossPad(-1, rear_wall_screw_z_high);
            }

            frontMagnetCuts(-1);

            lowerPanelScrewCuts(-1);

            topScrewInsertCuts(-1);

            rearWallScrewCuts(-1);

        }

    rc522MountBoss(case_width/2 - wall_thickness, -1);

    hubMountBosses(case_width/2 - wall_thickness);

}


//=============================================================================
// LAS DOS PAREDES
//=============================================================================

module chassisSideWalls()
{

    leftWall();

    rightWall();

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    chassisSideWalls();
