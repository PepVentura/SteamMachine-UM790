//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo : common.scad
// Versión : 1.1
//
// Punto de entrada de todas las librerías.
//
// Ninguna función debe implementarse aquí.
// Este archivo únicamente importa los parámetros globales y el
// resto de librerías del proyecto.
//
// ============================================================================


//------------------------------------------------------------
// Parámetros globales
//------------------------------------------------------------

include <../00_parametros.scad>;


//------------------------------------------------------------
// Librerías básicas
//------------------------------------------------------------

include <helpers.scad>;


//------------------------------------------------------------
// Elementos mecánicos
//------------------------------------------------------------

include <fasteners.scad>;
include <guides.scad>;
include <magnets.scad>;


//------------------------------------------------------------
// Ventilación
//------------------------------------------------------------

include <ventilation.scad>;


//------------------------------------------------------------
// Modelos simplificados de hardware
//------------------------------------------------------------

include <hardware.scad>;
