//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo    : pcb_um790.scad
// Versión    : 1.0
//
// Modelo de referencia de la placa base Minisforum UM790 Pro.
//
// NO ES UNA PIEZA IMPRIMIBLE.
//
// Se utiliza para:
//
//  • Verificar interferencias.
//  • Posicionar los postes.
//  • Diseñar la bandeja.
//  • Diseñar el panel trasero.
//  • Diseñar la tapa.
//
// ============================================================================

$fn = 64;


//=============================================================================
// PARÁMETROS
//=============================================================================

PCB_WIDTH      = 120.0;
PCB_DEPTH      = 120.0;
PCB_THICKNESS  = 1.60;

MOUNT_X = 113.0;
MOUNT_Y = 99.0;

HOLE_D = 4.0;


//=============================================================================
// COLORES
//=============================================================================

PCB_COLOR       = [0.10,0.45,0.12];
CONNECTOR_COLOR = [0.72,0.72,0.72];
HOLE_COLOR      = [1.00,0.00,0.00];


//=============================================================================
// CUERPO PCB
//=============================================================================

module pcb_body()
{

    color(PCB_COLOR)

    difference()
    {

        cube(
            [
                PCB_WIDTH,
                PCB_DEPTH,
                PCB_THICKNESS
            ]);

        translate(
        [
            (PCB_WIDTH-MOUNT_X)/2,
            (PCB_DEPTH-MOUNT_Y)/2,
            -0.2
        ])

        for(ix=[0:1])
        for(iy=[0:1])

            translate(
            [
                ix*MOUNT_X,
                iy*MOUNT_Y,
                0
            ])

            cylinder(
                d = HOLE_D,
                h = PCB_THICKNESS+0.4);

    }

}


//=============================================================================
// CENTROS DE MONTAJE
//=============================================================================

module mounting_points()
{

    color(HOLE_COLOR)

    translate(
    [
        (PCB_WIDTH-MOUNT_X)/2,
        (PCB_DEPTH-MOUNT_Y)/2,
        PCB_THICKNESS
    ])

    for(ix=[0:1])
    for(iy=[0:1])

        translate(
        [
            ix*MOUNT_X,
            iy*MOUNT_Y,
            0
        ])

        cylinder(
            d = 4,
            h = 5);

}


//=============================================================================
// BLOQUES DE CONECTORES
//=============================================================================

module connectors()
{

    color(CONNECTOR_COLOR)
    {

        //
        // Lateral izquierdo
        //

        translate([-9,12,PCB_THICKNESS])
            cube([9,92,15]);

        //
        // RJ45
        //

        translate([PCB_WIDTH,18,PCB_THICKNESS])
            cube([18,18,15]);

        //
        // USB
        //

        translate([PCB_WIDTH,40,PCB_THICKNESS])
            cube([15,38,15]);

        //
        // Alimentación
        //

        translate([PCB_WIDTH,98,PCB_THICKNESS])
            cube([12,12,12]);

    }

}


//=============================================================================
// VOLUMEN APROXIMADO DEL DISIPADOR
//=============================================================================

module cooler_volume()
{

    color([0.25,0.25,0.25,0.35])

    translate([16,16,PCB_THICKNESS])

        cube(
        [
            88,
            88,
            26
        ]);

}


//=============================================================================
// REFERENCIA DE EJES
//=============================================================================

module axes(length=20)
{

    color("red")
        cube([length,1,1]);

    color("green")
        cube([1,length,1]);

    color("blue")
        cube([1,1,length]);

}


//=============================================================================
// ENSAMBLAJE
//=============================================================================

module pcb_um790()
{

    pcb_body();

    connectors();

    cooler_volume();

    mounting_points();

    axes();

}


//=============================================================================
// PREVIEW
//=============================================================================

pcb_um790();
