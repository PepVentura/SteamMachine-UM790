//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
// Archivo : ventilation.scad
// Versión : 1.0
//
// Patrones de ventilación
// ============================================================================

include <../00_parametros.scad>;

$fn = 32;

//----------------------------------------------------------
// Ranuras rectas
//----------------------------------------------------------

module slots(width,
             height,
             slot=4,
             spacing=4,
             depth=20)
{

    pitch = slot + spacing;

    for(y=[0:pitch:height-slot])
    {

        translate([0,y,0])

            cube([
                width,
                slot,
                depth
            ]);

    }

}

//----------------------------------------------------------
// Rejilla cuadrada
//----------------------------------------------------------

module squareGrid(width,
                  height,
                  hole=4,
                  wall=2,
                  depth=20)
{

    pitch = hole + wall;

    for(x=[0:pitch:width-hole])
    {

        for(y=[0:pitch:height-hole])
        {

            translate([x,y,0])

                cube([
                    hole,
                    hole,
                    depth
                ]);

        }

    }

}

//----------------------------------------------------------
// Rejilla hexagonal
//----------------------------------------------------------

module hexGrid(width,
               height,
               hole=6,
               wall=2,
               depth=20)
{

    pitchX = hole + wall;
    pitchY = pitchX * 0.866;

    for(row=[0:ceil(height/pitchY)])
    {

        y = row * pitchY;

        xOffset = (row % 2) ? pitchX/2 : 0;

        for(x=[0:pitchX:width])
        {

            translate([x+xOffset,y,0])

                cylinder(
                    d=hole,
                    h=depth,
                    $fn=6);

        }

    }

}

//----------------------------------------------------------
// Rejilla circular
//----------------------------------------------------------

module roundGrid(width,
                 height,
                 hole=5,
                 spacing=3,
                 depth=20)
{

    pitch = hole + spacing;

    for(x=[0:pitch:width-hole])
    {

        for(y=[0:pitch:height-hole])
        {

            translate([x,y,0])

                cylinder(
                    d=hole,
                    h=depth);

        }

    }

}

//----------------------------------------------------------
// Lamas inclinadas
//----------------------------------------------------------

module angledSlats(width,
                   height,
                   angle=45,
                   slot=3,
                   spacing=5,
                   depth=20)
{

    pitch = slot + spacing;

    rotate([0,0,angle])

        for(y=[-height:pitch:height*2])
        {

            translate([-width,y,0])

                cube([
                    width*3,
                    slot,
                    depth
                ]);

        }

}

//----------------------------------------------------------
// Patrón tipo Valve
//----------------------------------------------------------

module valvePattern(width,
                    height,
                    hole=5,
                    spacing=7,
                    depth=20)
{

    pitch = hole + spacing;

    for(y=[0:pitch:height])
    {

        for(x=[0:pitch:width])
        {

            translate([x,y,0])

            rotate([0,0,45])

                cube([
                    hole,
                    hole,
                    depth
                ],center=true);

        }

    }

}
