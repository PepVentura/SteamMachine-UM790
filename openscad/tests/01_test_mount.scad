//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : 01_test_mount.scad
//
// Test de montaje de la placa UM790 PRO
//
// ============================================================================


//--------------------------------------------------------------------
// Parámetros
//--------------------------------------------------------------------

include <../../00_parametros.scad>;

$fn = 64;


//--------------------------------------------------------------------
// Medidas de la pieza
//--------------------------------------------------------------------

test_x = 130;
test_y = 115;

corner_radius = 6;


//--------------------------------------------------------------------
// Base redondeada
//--------------------------------------------------------------------

module rounded_plate(x,y,h,r)
{

    linear_extrude(height=h)

    hull()
    {

        translate([-x/2+r,-y/2+r]) circle(r=r);

        translate([ x/2-r,-y/2+r]) circle(r=r);

        translate([-x/2+r, y/2-r]) circle(r=r);

        translate([ x/2-r, y/2-r]) circle(r=r);

    }

}


//--------------------------------------------------------------------
// Poste
//--------------------------------------------------------------------

module post()
{

    difference()
    {

        cylinder(
            d = standoff_dia,
            h = standoff_height);

        translate([0,0,
            standoff_height-insert_depth])

            cylinder(
                d = insert_dia,
                h = insert_depth+0.2);

    }

}


//--------------------------------------------------------------------
// Ensamblaje
//--------------------------------------------------------------------

difference()
{

    rounded_plate(
        test_x,
        test_y,
        base_thickness,
        corner_radius);

    //
    // Ventana central
    //

    translate([0,0,-0.1])

    linear_extrude(base_thickness+0.2)

        hull()
        {

            translate([-35,-20]) circle(r=5);

            translate([ 35,-20]) circle(r=5);

            translate([-35, 20]) circle(r=5);

            translate([ 35, 20]) circle(r=5);

        }

}


//--------------------------------------------------------------------
// Postes
//--------------------------------------------------------------------

translate([-off_x,-off_y,base_thickness])
    post();

translate([ off_x,-off_y,base_thickness])
    post();

translate([-off_x, off_y,base_thickness])
    post();

translate([ off_x, off_y,base_thickness])
    post();


//--------------------------------------------------------------------
// Texto
//--------------------------------------------------------------------

translate([0,-test_y/2+8,0.4])

linear_extrude(0.6)

text(
    "UM790 TEST V1",
    size=5,
    halign="center",
    valign="center");
