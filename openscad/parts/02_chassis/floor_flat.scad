//
// ============================================================================
// SteamMachine UM790
// Project Phoenix
//
// Archivo  : floor_flat.scad
// Versión  : 1.0
// Fecha    : 2026-08-19
//
// Suelo del chasis, listo para laminar directamente — no necesita
// ningún giro, floor.scad ya lo genera orientado plano de forma
// natural (grosor del suelo en Z, mucho menor que su ancho/fondo).
//
// PEDIDO POR EL USUARIO: ficheros .scad independientes para las
// piezas ya orientadas para imprimir (floor/leftwall/rightwall
// flat), no solo los STL exportados.
//
// ============================================================================

include <../../../00_parametros.scad>;
include <../../reference/components/assembly_positions.scad>;
use <floor.scad>;

$fn = 64;

chassisFloor();
