//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
// Archivo : guides.scad
// Versión : 1.0
//
// Guías deslizantes parametrizadas
// ============================================================================

include <../00_parametros.scad>;

$fn = 32;

//------------------------------------------------------------------
// Perfil macho
//------------------------------------------------------------------

module dovetailMale(
    length,
    width = guide_width,
    height = guide_height)
{

    linear_extrude(height = length)
        polygon([
            [-width/2,0],
            [ width/2,0],
            [ width,height*0.60],
            [ width*0.60,height],
            [-width*0.60,height],
            [-width,height*0.60]
        ]);

}

//------------------------------------------------------------------
// Perfil hembra
//------------------------------------------------------------------

module dovetailFemale(
    length,
    width = guide_width,
    height = guide_height,
    clearance = guide_clearance)
{

    linear_extrude(height = length)
        polygon([
            [-(width/2+clearance),-clearance],
            [ (width/2+clearance),-clearance],
            [ (width+clearance),height*0.60],
            [ (width*0.60+clearance),height+clearance],
            [-(width*0.60+clearance),height+clearance],
            [-(width+clearance),height*0.60]
        ]);

}

//------------------------------------------------------------------
// Carril macho
//------------------------------------------------------------------

module guideMale(length)
{

    rotate([90,0,90])
        dovetailMale(length);

}

//------------------------------------------------------------------
// Canal hembra
//------------------------------------------------------------------

module guideFemale(length)
{

    rotate([90,0,90])
        dovetailFemale(length);

}

//------------------------------------------------------------------
// Tope delantero
//------------------------------------------------------------------

module guideStopFront(
    width = guide_width,
    height = guide_height,
    thickness = 3)
{

    cube([
        thickness,
        width,
        height
    ]);

}

//------------------------------------------------------------------
// Tope trasero
//------------------------------------------------------------------

module guideStopRear(
    width = guide_width,
    height = guide_height,
    thickness = 3)
{

    cube([
        thickness,
        width,
        height
    ]);

}

//------------------------------------------------------------------
// Guía completa
//------------------------------------------------------------------

module guideAssembly(length)
{

    guideMale(length);

    translate([length,0,0])
        guideStopRear();

    guideStopFront();

}

//------------------------------------------------------------------
// Canal completo
//------------------------------------------------------------------

module guideChannel(length)
{

    guideFemale(length);

}
