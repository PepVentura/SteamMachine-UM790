//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
// Archivo : common.scad
// Versión : 1.0
//
// Librería común
// ============================================================================

include <../00_parametros.scad>;

$fn = 64;

//----------------------------------------------------------
// Centro de una pieza
//----------------------------------------------------------

module centeredCube(size)
{
    translate([-size[0]/2,-size[1]/2,-size[2]/2])
        cube(size);
}

//----------------------------------------------------------
// Agujero pasante
//----------------------------------------------------------

module hole(diameter,height)
{
    translate([0,0,-0.01])
        cylinder(
            d=diameter,
            h=height+0.02);
}

//----------------------------------------------------------
// Taladro M3
//----------------------------------------------------------

module m3Hole(height=10)
{
    hole(mount_hole,height);
}

//----------------------------------------------------------
// Inserto térmico M3
//----------------------------------------------------------

module heatInsert(height=heat_insert_height)
{
    hole(heat_insert_outer,height);
}

//----------------------------------------------------------
// Poste M3
//----------------------------------------------------------

module m3Post(height=10,
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
// Separador simple
//----------------------------------------------------------

module spacer(height,
              diameter)
{

    cylinder(
        d=diameter,
        h=height);

}

//----------------------------------------------------------
// Alojamiento para imán
//----------------------------------------------------------

module magnetSocket(
        diameter=magnet_diameter,
        height=magnet_height,
        clearance=0.15)
{

    hole(
        diameter+clearance,
        height+clearance);

}

//----------------------------------------------------------
// Canal LED
//----------------------------------------------------------

module ledChannel(length)
{

    cube([
        length,
        led_strip_width,
        led_channel_depth
    ]);

}

//----------------------------------------------------------
// Cruz de referencia
//----------------------------------------------------------

module centerMark(size=12,
                  thickness=1,
                  height=0.4)
{

    cube([
        size,
        thickness,
        height
    ],center=true);

    cube([
        thickness,
        size,
        height
    ],center=true);

}

//----------------------------------------------------------
// Texto grabado
//----------------------------------------------------------

module engravedText(
        txt="",
        size=6,
        depth=0.6)
{

    linear_extrude(depth)
        text(
            txt,
            size=size,
            halign="center",
            valign="center");

}

//----------------------------------------------------------
// Rejilla rectangular
//----------------------------------------------------------

module ventilationSlots(
        width,
        height,
        slot=4,
        spacing=4)
{

    for(y=[0:slot+spacing:height])
    {

        translate([0,y,0])

            cube([
                width,
                slot,
                20
            ]);

    }

}

//----------------------------------------------------------
// Chaflán 45º
//----------------------------------------------------------

module chamfer(length,
               size)
{

    linear_extrude(length)

        polygon([
            [0,0],
            [size,0],
            [0,size]
        ]);

}

//----------------------------------------------------------
// Cola de milano (provisional)
//
// La versión definitiva estará en guides.scad
//----------------------------------------------------------

module dovetailPlaceholder(length=20)
{

    cube([
        length,
        guide_width,
        guide_height
    ]);

}
