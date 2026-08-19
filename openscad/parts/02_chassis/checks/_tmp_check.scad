
include <../../../00_parametros.scad>;
use </home/claude/repo/openscad/parts/02_chassis/walls.scad>;
use </home/claude/repo/openscad/reference/components/assembly_instances.scad>;
$fn=32;
intersection() { chassisSideWalls(); rc522InstanceBody(); }
