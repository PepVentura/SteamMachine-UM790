//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
// Archivo : magnets.scad
// Versión : 1.0
//
// Librería de imanes
// ============================================================================

include <../00_parametros.scad>;

$fn = 64;

//----------------------------------------------------------
// Imán (modelo sólido)
//----------------------------------------------------------

module magnet(
    diameter = magnet_diameter,
    height = magnet_height)
{
    color("silver")
        cylinder(
            d = diameter,
            h = height);
}

//----------------------------------------------------------
// Alojamiento para imán
//----------------------------------------------------------

module magnetSocket(
    diameter = magnet_diameter,
    height = magnet_height,
    clearance = 0.15)
{
    translate([0,0,-0.01])
        cylinder(
            d = diameter + clearance,
            h = height + clearance + 0.02);
}

//----------------------------------------------------------
// Imán empotrado
//----------------------------------------------------------

module embeddedMagnet(
    diameter = magnet_diameter,
    height = magnet_height,
    clearance = 0.15)
{
    difference()
    {
        children();

        magnetSocket(
            diameter = diameter,
            height = height,
            clearance = clearance);
    }
}

//----------------------------------------------------------
// Pareja de imanes
//----------------------------------------------------------

module magnetPair(
    spacing,
    diameter = magnet_diameter,
    height = magnet_height)
{
    translate([-spacing/2,0,0])
        magnet(diameter,height);

    translate([ spacing/2,0,0])
        magnet(diameter,height);
}

//----------------------------------------------------------
// Cuatro imanes
//----------------------------------------------------------

module magnetCorners(
    dx,
    dy,
    diameter = magnet_diameter,
    height = magnet_height)
{
    translate([-dx/2,-dy/2,0])
        magnet(diameter,height);

    translate([ dx/2,-dy/2,0])
        magnet(diameter,height);

    translate([-dx/2, dy/2,0])
        magnet(diameter,height);

    translate([ dx/2, dy/2,0])
        magnet(diameter,height);
}

//----------------------------------------------------------
// Cuatro alojamientos
//----------------------------------------------------------

module magnetCornerSockets(
    dx,
    dy,
    diameter = magnet_diameter,
    height = magnet_height,
    clearance = 0.15)
{
    translate([-dx/2,-dy/2,0])
        magnetSocket(diameter,height,clearance);

    translate([ dx/2,-dy/2,0])
        magnetSocket(diameter,height,clearance);

    translate([-dx/2, dy/2,0])
        magnetSocket(diameter,height,clearance);

    translate([ dx/2, dy/2,0])
        magnetSocket(diameter,height,clearance);
}

//----------------------------------------------------------
// Imán de 6x2
//----------------------------------------------------------

module magnet6x2()
{
    magnet(6,2);
}

//----------------------------------------------------------
// Imán de 8x3
//----------------------------------------------------------

module magnet8x3()
{
    magnet(8,3);
}

//----------------------------------------------------------
// Imán de 10x3
//----------------------------------------------------------

module magnet10x3()
{
    magnet(10,3);
}

//----------------------------------------------------------
// Alojamiento 6x2
//----------------------------------------------------------

module socket6x2()
{
    magnetSocket(6,2);
}

//----------------------------------------------------------
// Alojamiento 8x3
//----------------------------------------------------------

module socket8x3()
{
    magnetSocket(8,3);
}

//----------------------------------------------------------
// Alojamiento 10x3
//----------------------------------------------------------

module socket10x3()
{
    magnetSocket(10,3);
}
