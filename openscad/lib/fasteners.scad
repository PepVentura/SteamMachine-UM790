//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
// Archivo : fasteners.scad
// Versión : 1.0
//
// Tornillería e insertos
// ============================================================================

include <../00_parametros.scad>;

$fn = 64;

//----------------------------------------------------------
// Agujero pasante
//----------------------------------------------------------

module screwHole(d=3.4,h=10)
{
    translate([0,0,-0.05])
        cylinder(d=d,h=h+0.1);
}

//----------------------------------------------------------
// Agujero M2
//----------------------------------------------------------

module m2Hole(h=10)
{
    screwHole(2.4,h);
}

//----------------------------------------------------------
// Agujero M2.5
//----------------------------------------------------------

module m25Hole(h=10)
{
    screwHole(2.9,h);
}

//----------------------------------------------------------
// Agujero M3
//----------------------------------------------------------

module m3Hole(h=10)
{
    screwHole(mount_hole,h);
}

//----------------------------------------------------------
// Agujero M4
//----------------------------------------------------------

module m4Hole(h=10)
{
    screwHole(4.5,h);
}

//----------------------------------------------------------
// Poste M3
//----------------------------------------------------------

module m3Post(
    height=10,
    diameter=mount_post_diameter)
{

    difference()
    {
        cylinder(
            d=diameter,
            h=height);

        m3Hole(height+2);
    }

}

//----------------------------------------------------------
// Inserto térmico M3
//----------------------------------------------------------

module m3HeatInsert(
        h=heat_insert_height)
{

    cylinder(
        d=heat_insert_outer,
        h=h);

}

//----------------------------------------------------------
// Poste preparado para inserto
//----------------------------------------------------------

module m3InsertPost(
        height=10,
        diameter=10)
{

    difference()
    {

        cylinder(
            d=diameter,
            h=height);

        translate([0,0,height-heat_insert_height])

            m3HeatInsert();

    }

}

//----------------------------------------------------------
// Tuerca hexagonal M3
//----------------------------------------------------------

module m3NutPocket(
        height=2.5,
        flat=5.7,
        clearance=0.2)
{

    cylinder(
        d=(flat+clearance)/0.866,
        h=height,
        $fn=6);

}

//----------------------------------------------------------
// Avellanado ISO para M3
//----------------------------------------------------------

module m3Countersink(
        angle=90,
        head=6,
        depth=2)
{

    cylinder(
        d1=head,
        d2=mount_hole,
        h=depth);

}

//----------------------------------------------------------
// Separador
//----------------------------------------------------------

module spacer(
        height,
        diameter)
{

    cylinder(
        d=diameter,
        h=height);

}
