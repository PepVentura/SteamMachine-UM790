//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : magnets.scad
// Versión : 1.1
//
// Utilidades para alojamientos de imanes.
//
// Esta librería NO dibuja imanes.
// Únicamente genera los huecos necesarios.
//
// ============================================================================


//----------------------------------------------------------
// Alojamiento genérico
//----------------------------------------------------------

module magnetSocket(
    diameter = magnet_diameter,
    height   = magnet_height,
    clearance = magnet_clearance)
{

    translate([0,0,-0.01])

        cylinder(
            d = diameter + clearance,
            h = height + clearance + 0.02);

}


//----------------------------------------------------------
// Alojamiento 6x2
//----------------------------------------------------------

module socket6x2()
{
    magnetSocket(
        diameter = 6,
        height   = 2);
}


//----------------------------------------------------------
// Alojamiento 8x3
//----------------------------------------------------------

module socket8x3()
{
    magnetSocket(
        diameter = 8,
        height   = 3);
}


//----------------------------------------------------------
// Alojamiento 10x3
//----------------------------------------------------------

module socket10x3()
{
    magnetSocket(
        diameter = 10,
        height   = 3);
}


//----------------------------------------------------------
// Dos alojamientos
//----------------------------------------------------------

module magnetPair(
    spacing,
    diameter = magnet_diameter,
    height   = magnet_height)
{

    translate([-spacing/2,0,0])

        magnetSocket(
            diameter,
            height);

    translate([ spacing/2,0,0])

        magnetSocket(
            diameter,
            height);

}


//----------------------------------------------------------
// Cuatro alojamientos
//----------------------------------------------------------

module magnetCorners(
    dx,
    dy,
    diameter = magnet_diameter,
    height   = magnet_height)
{

    translate([-dx/2,-dy/2,0])
        magnetSocket(diameter,height);

    translate([ dx/2,-dy/2,0])
        magnetSocket(diameter,height);

    translate([-dx/2, dy/2,0])
        magnetSocket(diameter,height);

    translate([ dx/2, dy/2,0])
        magnetSocket(diameter,height);

}
