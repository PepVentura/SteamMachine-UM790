//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : shapes.scad
// Versión : 1.0
//
// Librería de formas geométricas reutilizables.
//
// Todas las piezas del proyecto deberán construirse utilizando estos
// módulos siempre que sea posible.
//
// ============================================================================

include <../00_parametros.scad>;

$fn = 64;


//=============================================================================
// PLACA RECTANGULAR
//=============================================================================

module plate(
    width,
    depth,
    thickness,
    center = false)
{
    cube(
        [width, depth, thickness],
        center = center);
}


//=============================================================================
// PLACA CON CHAFLANES
//=============================================================================

module chamferedPlate(
    width,
    depth,
    thickness,
    chamfer = 2,
    center = false)
{

    module profile()
    {
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

    if(center)
    {
        translate([-width/2,-depth/2,0])
            linear_extrude(thickness)
                profile();
    }
    else
    {
        linear_extrude(thickness)
            profile();
    }

}


//=============================================================================
// TUBO
//=============================================================================

module tube(
    outerDiameter,
    innerDiameter,
    height,
    center = false)
{

    difference()
    {

        cylinder(
            d = outerDiameter,
            h = height,
            center = center);

        cylinder(
            d = innerDiameter,
            h = height + 0.20,
            center = center);

    }

}


//=============================================================================
// POSTE CILÍNDRICO
//=============================================================================

module boss(
    diameter,
    height,
    center = false)
{

    cylinder(
        d = diameter,
        h = height,
        center = center);

}


//=============================================================================
// RANURA RECTANGULAR
//=============================================================================

module slot(
    length,
    width,
    height,
    center = true)
{

    cube(
        [length,width,height],
        center = center);

}


//=============================================================================
// RANURA REDONDEADA
//=============================================================================

module roundedSlot(
    length,
    diameter,
    height,
    center = true)
{

    z = center ? -height/2 : 0;

    hull()
    {

        translate([-length/2,0,z])

            cylinder(
                d = diameter,
                h = height);

        translate([ length/2,0,z])

            cylinder(
                d = diameter,
                h = height);

    }

}


//=============================================================================
// MARCO RECTANGULAR
//=============================================================================

module frame(
    width,
    depth,
    border,
    thickness,
    center = false)
{

    if(center)
    {

        difference()
        {

            cube(
                [width,depth,thickness],
                center=true);

            translate([0,0,-0.1])

                cube(
                [
                    width-2*border,
                    depth-2*border,
                    thickness+0.2
                ],
                center=true);

        }

    }
    else
    {

        difference()
        {

            cube([width,depth,thickness]);

            translate([border,border,-0.1])

                cube(
                [
                    width-2*border,
                    depth-2*border,
                    thickness+0.2
                ]);

        }

    }

}


//=============================================================================
// NERVIO
//=============================================================================

module rib(
    length,
    width,
    height,
    center = false)
{

    cube(
        [length,width,height],
        center = center);

}


//=============================================================================
// NERVIO EN CRUZ
//=============================================================================

module crossRib(
    length,
    width,
    height,
    center = true)
{

    rib(
        length,
        width,
        height,
        center);

    rotate([0,0,90])

        rib(
            length,
            width,
            height,
            center);

}
