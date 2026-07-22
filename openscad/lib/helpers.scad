//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
// Archivo : helpers.scad
// Versión : 1.0
//
// Funciones auxiliares
// ============================================================================

include <../00_parametros.scad>;

$fn = 64;

//----------------------------------------------------------
// Cubo centrado
//----------------------------------------------------------

module centeredCube(size)
{
    cube(size, center=true);
}

//----------------------------------------------------------
// Cilindro centrado
//----------------------------------------------------------

module centeredCylinder(d, h)
{
    cylinder(d=d, h=h, center=true);
}

//----------------------------------------------------------
// Espejo en X
//----------------------------------------------------------

module mirrorX()
{
    children();
    mirror([1,0,0]) children();
}

//----------------------------------------------------------
// Espejo en Y
//----------------------------------------------------------

module mirrorY()
{
    children();
    mirror([0,1,0]) children();
}

//----------------------------------------------------------
// Espejo en XY
//----------------------------------------------------------

module mirrorXY()
{
    children();
    mirror([1,0,0]) children();
    mirror([0,1,0]) children();
    mirror([1,1,0]) children();
}

//----------------------------------------------------------
// Matriz rectangular
//----------------------------------------------------------

module arrayXY(nx, ny, dx, dy)
{
    for(ix=[0:nx-1])
        for(iy=[0:ny-1])
            translate([ix*dx, iy*dy, 0])
                children();
}

//----------------------------------------------------------
// Patrón circular
//----------------------------------------------------------

module arrayPolar(n, radius)
{
    for(i=[0:n-1])
        rotate([0,0,360*i/n])
            translate([radius,0,0])
                children();
}

//----------------------------------------------------------
// Centrar una pieza sobre XY
//----------------------------------------------------------

module onXY()
{
    translate([0,0,0])
        children();
}

//----------------------------------------------------------
// Elevar una pieza
//----------------------------------------------------------

module up(z)
{
    translate([0,0,z])
        children();
}

//----------------------------------------------------------
// Bajar una pieza
//----------------------------------------------------------

module down(z)
{
    translate([0,0,-z])
        children();
}

//----------------------------------------------------------
// Desplazamientos rápidos
//----------------------------------------------------------

module left(x)
{
    translate([-x,0,0])
        children();
}

module right(x)
{
    translate([x,0,0])
        children();
}

module front(y)
{
    translate([0,y,0])
        children();
}

module back(y)
{
    translate([0,-y,0])
        children();
}

//----------------------------------------------------------
// Esquinas de un rectángulo
//----------------------------------------------------------

module fourCorners(dx, dy)
{
    translate([ dx/2, dy/2,0]) children();
    translate([-dx/2, dy/2,0]) children();
    translate([ dx/2,-dy/2,0]) children();
    translate([-dx/2,-dy/2,0]) children();
}
