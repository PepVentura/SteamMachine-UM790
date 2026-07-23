//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : shapes.scad
// Versión : 1.0
//
// Formas geométricas reutilizables
//
// ============================================================================

include <../00_parametros.scad>;

$fn = 64;

//----------------------------------------------------------
// Placa rectangular
//----------------------------------------------------------

module plate(width, depth, thickness)
{
    cube([width, depth, thickness]);
}

//----------------------------------------------------------
// Placa con chaflanes de 45°
//----------------------------------------------------------

module chamferedPlate(width,
                      depth,
                      thickness,
                      chamfer = 2)
{
    linear_extrude(height = thickness)
    polygon([
        [chamfer,0],
        [width-chamfer,0],
        [width,chamfer],
        [width,depth-chamfer],
        [width-chamfer,depth],
        [chamfer,depth],
        [0,depth-chamfer],
        [0,chamfer]
    ]);
}

//----------------------------------------------------------
// Tubo
//----------------------------------------------------------

module tube(outer_d,
            inner_d,
            height)
{
    difference()
    {
        cylinder(d=outer_d,h=height);

        translate([0,0,-0.1])
            cylinder(d=inner_d,h=height+0.2);
    }
}

//----------------------------------------------------------
// Poste macizo
//----------------------------------------------------------

module boss(diameter,
            height)
{
    cylinder(
        d=diameter,
        h=height);
}

//----------------------------------------------------------
// Ranura rectangular
//----------------------------------------------------------

module slot(length,
            width,
            height)
{
    translate([-length/2,-width/2,0])

        cube([
            length,
            width,
            height
        ]);
}

//----------------------------------------------------------
// Ranura con extremos redondeados
//----------------------------------------------------------

module roundedSlot(length,
                   diameter,
                   height)
{

    hull()
    {

        translate([-length/2,0,0])

            cylinder(
                d=diameter,
                h=height);

        translate([ length/2,0,0])

            cylinder(
                d=diameter,
                h=height);

    }

}

//----------------------------------------------------------
// Marco rectangular
//----------------------------------------------------------

module frame(width,
             depth,
             border,
             thickness)
{

    difference()
    {

        cube([
            width,
            depth,
            thickness
        ]);

        translate([
            border,
            border,
            -0.1
        ])

        cube([
            width-2*border,
            depth-2*border,
            thickness+0.2
        ]);

    }

}

//----------------------------------------------------------
// Nervio longitudinal
//----------------------------------------------------------

module rib(length,
           width,
           height)
{

    cube([
        length,
        width,
        height
    ]);

}

//----------------------------------------------------------
// Nervio en cruz
//----------------------------------------------------------

module crossRib(length,
                width,
                height)
{

    rib(length,width,height);

    rotate([0,0,90])

        rib(length,width,height);

}
