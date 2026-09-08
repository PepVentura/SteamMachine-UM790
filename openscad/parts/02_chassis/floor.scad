//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : floor.scad
// Versión  : 1.0
// Fecha    : 2026-08-03
// Autor    : Pep Ventura (asistido por Claude)
//
// Suelo del chasis principal fijo. Llevaba una rejilla de
// ventilación de entrada de aire (refrigeración vertical: entrada
// inferior, salida superior — docs/DESIGN_RULES.md); retirada de
// chassisFloor() el 2026-09-08 a petición del usuario (debilitaba la
// pieza y chocaba con el injerto suelo-pared). Ver floorVentCut()
// más abajo — el módulo sigue definido, solo no se llama.
//
// Sistema de coordenadas: igual que
// openscad/reference/components/assembly_positions.scad — origen
// centrado en X/Y, Z=0 en la cara inferior exterior del chasis.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <../../lib/ventilation.scad>;

$fn = 64;

part_version = "1.0";


//=============================================================================
// PLACA MACIZA DEL SUELO
//=============================================================================

module floorPlate()
{

    translate([-case_width/2, -case_depth/2, 0])

        cube([case_width, case_depth, bottom_thickness]);

}


//=============================================================================
// REJILLA DE VENTILACIÓN — RETIRADA de chassisFloor() (2026-09-08,
// petición del usuario: "mejor dejamos la base sin los rombos de
// ventilación ya que debilitan mucho la pieza" + uno de los taladros
// del injerto M3 suelo-pared coincidía con un rombo). El módulo se
// conserva por si se retoma más adelante con otra distribución, pero
// ya no se llama desde chassisFloor() — el suelo queda macizo salvo
// los rebajes/taladros funcionales (clúster frontal, patas, injerto
// suelo-pared, postes de la bandeja).
//
// Patrón tipo Valve (valvePattern, ya presente en ventilation.scad),
// con el margen ya definido en 00_parametros.scad
// (bottom_grill_margin). Se sitúa bajo la huella del disipador,
// centrada en X/Y, para maximizar el flujo de aire justo debajo del
// UM790.
//=============================================================================

module floorVentCut()
{

    ventWidth  = case_width  - 2*bottom_grill_margin;
    ventDepth  = case_depth  - 2*bottom_grill_margin;
    ventDepthCut = bottom_thickness + 2;

    // FALLO CORREGIDO (2026-09-08, pregunta del usuario: "si son para
    // ventilación, ¿por qué no atraviesan la pieza?"): valvePattern()
    // (openscad/lib/ventilation.scad) usa cube(..., center=true) —
    // centra el corte TAMBIÉN en Z, no solo en X/Y. Con
    // translate(Z=-1), el corte real quedaba entre Z=-3,5 y Z=1,5,
    // mientras el suelo ocupa Z=0 a bottom_thickness=3 — solo se
    // cortaba la mitad inferior, dejando 1,5mm de piel maciza sin
    // cortar en la cara superior de TODO el suelo (verificado con los
    // números exactos, no solo por el aspecto en el visor). El
    // corte, al estar centrado, debe colocarse en el CENTRO real del
    // grosor de la placa (bottom_thickness/2), no en -1.
    translate([
        -ventWidth/2,
        -ventDepth/2,
        bottom_thickness/2
    ])

        valvePattern(
            width   = ventWidth,
            height  = ventDepth,
            hole    = vent_slot_width*2.5,
            spacing = vent_spacing,
            depth   = ventDepthCut
        );

}


//=============================================================================
// REBAJE BAJO EL CLÚSTER FRONTAL
//
// Hallazgo de la comprobación de colisiones: el OLED y el USB
// frontal, en su posición ya validada (front_cluster_z = 19, ver
// assembly_positions.scad), bajan hasta Z=1,5 mm — por debajo de la
// cara superior del suelo (bottom_thickness = 3 mm). Sin este rebaje,
// el suelo invade el bloque de pines del OLED y el cuerpo del USB.
//
// Se recorta el suelo por completo (Z 0 a bottom_thickness) en la
// franja frontal donde vive el clúster, con margen.
//=============================================================================

module frontClusterRelief()
{

    reliefXmin = pushbutton_pos[0] - pushbutton_cap_diameter/2 - 3;
    reliefXmax = usb_front_pos[0]  + usb_front_flange_diameter/2 + 3;
    reliefYmax = usb_front_pos[1] + usb_front_flange_diameter/2 + usb_front_body_length + 3;

    translate([
        reliefXmin,
        -case_depth/2 - 1,
        -1
    ])

        cube([
            reliefXmax - reliefXmin,
            (reliefYmax - (-case_depth/2 - 1)),
            bottom_thickness + 2
        ]);

}


//=============================================================================
// APOYOS DE LA BANDEJA
//
// La bandeja (tray_width = 150 mm) encaja EXACTAMENTE con el ancho
// interior del chasis (case_width - 2*wall_thickness = 150 mm): sin
// holgura, un ajuste a presión poco realista para impresión 3D. Por
// eso no se guía por las paredes (invadiría ese hueco inexistente),
// sino que se apoya en 4 postes que suben desde el suelo hasta la
// cámara de aire inferior (lower_air_chamber = 12 mm), dentro de la
// huella de la bandeja, sin tocar las paredes.
//
// PENDIENTE: valorar reducir tray_width/tray_depth ligeramente
// (0,4-0,6 mm) en una futura revisión para dar holgura de impresión
// real; no se ha hecho aquí porque tray_width ya se usa en la
// bandeja construida (openscad/parts/01_bandeja) y cambiarlo se sale
// del alcance de esta sesión.
//=============================================================================

// tray_support_diameter / tray_support_inset: ver 00_parametros.scad
// (compartidos con openscad/parts/01_bandeja/base.scad)

module traySupportPosts()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*(tray_width/2  - tray_support_inset_x),
            iy*(tray_depth/2  - tray_support_inset_y),
            bottom_thickness
        ])

            difference()
            {

                cylinder(d = tray_support_diameter, h = lower_air_chamber);

                // FALLO CORREGIDO (2026-08-03, aviso del usuario): el
                // poste estaba completamente macizo, sin alojamiento
                // para el inserto M3 que fija la bandeja.
                translate([0,0,lower_air_chamber-insert_depth])
                    cylinder(d = insert_diameter, h = insert_depth+0.1);

            }

}


//=============================================================================
// PATAS EXTERNAS — RETIRADAS COMO PIEZA INTEGRADA (2026-09-08,
// petición del usuario)
//
// CONFIRMADO por el usuario (2026-08-03): externas, 4 mm, por debajo
// del cascarón (leg_height, 00_parametros.scad). Mismo criterio de
// posición que openscad/reference/virtual_assembly_v1.scad
// (externalLegs()) — 4 patas cuadradas en las esquinas.
//
// SUSTITUIDAS (2026-09-08) por un pie desmontable, atornillado
// (openscad/parts/02_chassis/foot.scad /
// openscad/parts/04_soportes/foot.scad): al tumbar el suelo para
// imprimirlo plano, estas patas quedaban colgando en voladizo bajo
// la placa y necesitaban soporte de impresión (el patrón de
// "cuadrados o rombos" que describía el usuario). Las mismas 4
// posiciones (leg_center_offset_x/y) se conservan — ahora llevan un
// inserto M3 ciego en vez de una pata maciza (floorLegMountInserts()
// más abajo); el pie se atornilla desde fuera una vez impreso.
//
// leg_footprint se conserva como referencia de tamaño en planta —
// mismo diámetro que el pie (foot.scad, foot_diameter), para no
// dejar hueco visible en el borde.
//=============================================================================

leg_footprint = 10.0;  // estimado, lado de cada pata cuadrada / diámetro del pie desmontable

leg_edge_margin = 2.0;  // margen entre el borde exterior del punto de anclaje y el borde de la carcasa
leg_center_offset_x = case_width/2 - leg_footprint/2 - leg_edge_margin;

// FALLO CORREGIDO (2026-09-08, aviso del usuario con captura: "creo
// que tocarían con los insertos de los paneles laterales"):
// confirmado con las cotas exactas — a la Y de la esquina real
// (case_depth/2 - leg_footprint/2 - leg_edge_margin = 74,2), el
// poste de la pata SÍ invade el relleno del tornillo del panel
// inferior en la pared (lower_panel_screw_z_low=10, side_boss_size
// centrado ahí: Z 3-17) — solape real de 8×9×7mm, no solo aparente
// en el visor. El poste de la esquina trasera, a la misma Y en
// positivo, coincide igual de lleno con el relleno del tornillo del
// panel TRASERO en X/Y, pero se libra porque ese relleno vive a otra
// Z (20-34 y 123-137, lejos de los 3-10mm del poste de la pata) —
// solo por eso no chocaba también.
//
// Reubicadas las 4 patas a Y=±32 (ya no la esquina exacta): lejos de
// ambos rellenos (front/rear, Y hasta ±64,2 — más de 27mm de margen)
// y lejos del injerto suelo-pared (floor_wall_graft_y=±50 — 7mm de
// margen). Sigue dando una base de apoyo razonablemente ancha
// (64mm de separación delante-detrás, combinado con los ±71mm en X).
leg_center_offset_y = 32.0;


//=============================================================================
// INSERTOS M3 DEL PIE DESMONTABLE
//
// Un poste corto que sube desde la cara INTERIOR del suelo
// (Z=bottom_thickness), con un inserto M3 ciego abierto hacia ABAJO
// (mismo lado por el que se atornilla el pie, desde fuera) — mismo
// patrón que traySupportPosts(), pero accesible desde fuera en vez
// de desde dentro.
//
// ALTURA DEL PIE: foot_height (openscad/parts/02_chassis/foot.scad)
// = 4mm, IGUAL que leg_height — así la altura total del chasis
// montado (shell_height + foot_height = 148+4 = 152mm) sigue siendo
// exactamente case_height, sin superar la altura ya establecida.
//=============================================================================

floor_leg_mount_diameter = leg_footprint;      // mismo tamaño en planta que las patas antiguas
floor_leg_mount_height   = insert_depth + 2.0;  // sube desde la cara interior del suelo lo justo para alojar el inserto M3 con margen de agarre
floor_leg_screw_clearance_diameter = 3.4;       // holgura de paso para M3

module floorLegMountInserts()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*leg_center_offset_x,
            iy*leg_center_offset_y,
            bottom_thickness
        ])

            difference()
            {

                cylinder(d = floor_leg_mount_diameter, h = floor_leg_mount_height);

                translate([0, 0, -0.1])
                    cylinder(d = insert_diameter, h = insert_depth + 0.1);

            }

}

// FALLO CORREGIDO (2026-09-08, aviso del usuario: "los cilindros...
// no se ven perforados, se ven macizos" visto desde abajo): el
// taladro del inserto, dentro de floorLegMountInserts(), solo abría
// DENTRO del propio poste (desde Z=bottom_thickness-0,1=2,9 hacia
// arriba) — nunca atravesaba los bottom_thickness=3mm de la placa
// del suelo. Visto desde la cara exterior real (Z=0), esos 2,9mm de
// piel maciza tapaban el inserto por completo. Falta este taladro de
// paso, más estrecho (solo holgura M3, no el diámetro del inserto),
// que sí atraviesa la placa entera — se resta a nivel de
// chassisFloor(), junto con floorWallGraftClearanceHoles().
module floorLegScrewClearanceHoles()
{

    for(ix=[-1,1])
    for(iy=[-1,1])

        translate([
            ix*leg_center_offset_x,
            iy*leg_center_offset_y,
            -0.1
        ])
            cylinder(d = floor_leg_screw_clearance_diameter, h = bottom_thickness + 0.2);

}


//=============================================================================
// TALADROS DE PASO DEL INJERTO M3 SUELO-PARED
//
// PEDIDO POR EL USUARIO (2026-09-08): unir el suelo a las paredes
// (impresas planas por separado) con injertos M3. El inserto ciego
// vive en la pared (openscad/parts/02_chassis/walls.scad,
// floorWallGraftInsertCuts()) — aquí solo el taladro de paso, mismas
// coordenadas X/Y (floorWallGraftX()/floor_wall_graft_y,
// assembly_positions.scad), para que el tornillo entre desde fuera,
// por debajo del suelo.
//=============================================================================

// FALLO CORREGIDO (2026-09-08, aviso del usuario: "parecen muy
// grandes y sin avellanado"): confirmado — Ø3,4mm es la holgura de
// paso M3 estándar ya usada en el resto del proyecto (igual que
// top_screw_diameter, el taladro del RC522...), no es un tamaño
// fuera de lo normal, pero le faltaba el avellanado cónico que SÍ
// llevan el resto de tornillos que entran desde una cara exterior
// (tapa, panel trasero, panel inferior — top_screw_csk_diameter,
// rear_csk_radius, lower_panel_csk_radius, todos Ø6mm) — sin él, la
// cabeza del tornillo se queda sobresaliendo en vez de asentar a
// ras, y visualmente es un simple taladro recto sin ningún bisel que
// lo suavice.
floor_wall_graft_csk_diameter = 6.0;  // mismo criterio que el resto de avellanados M3 del proyecto
floor_wall_graft_csk_depth    = 1.8;  // dentro de los 3mm del suelo, mismo valor que top_screw_csk_depth

module floorWallGraftClearanceHoles()
{

    for(side = [-1, 1])

        for(y = floor_wall_graft_y)
        {

            // Taladro de paso, todo el grosor del suelo
            translate([floorWallGraftX(side), y, -0.1])
                cylinder(d = 3.4, h = bottom_thickness + 0.2);

            // Avellanado cónico, en la cara EXTERIOR (Z=0 — por donde
            // entra el tornillo, desde fuera y por debajo)
            translate([floorWallGraftX(side), y, -0.1])
                cylinder(d1 = floor_wall_graft_csk_diameter, d2 = 3.4, h = floor_wall_graft_csk_depth + 0.1);

        }

}


//=============================================================================
// SUELO COMPLETO
//=============================================================================

module chassisFloor()
{

    difference()
    {

        union()
        {

            difference()
            {

                floorPlate();

                frontClusterRelief();

            }

            floorLegMountInserts();

            traySupportPosts();

        }

        floorWallGraftClearanceHoles();

        floorLegScrewClearanceHoles();

    }

}


//=============================================================================
// PREVIEW
//=============================================================================

color("Gainsboro")
    chassisFloor();
