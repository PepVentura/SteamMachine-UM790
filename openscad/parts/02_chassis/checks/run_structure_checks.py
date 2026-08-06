#!/usr/bin/env python3
"""Comprueba las piezas estructurales (suelo, paredes, tapa, panel
trasero) contra los 8 componentes del ensamblaje virtual v1."""
import subprocess
from pathlib import Path

HERE = Path(__file__).resolve().parent
CHASSIS = HERE.parent
BANDEJA = CHASSIS.parent / "01_bandeja"

STRUCTURES = {
    "chassisFloor":     (CHASSIS / "floor.scad", "chassisFloor"),
    "chassisSideWalls": (CHASSIS / "walls.scad", "chassisSideWalls"),
    "chassisTop":       (CHASSIS / "top.scad", "chassisTop"),
    "rearPanel":        (BANDEJA / "rear_panel.scad", "rearPanel"),
}
# NOTA (2026-08-03): openscad/parts/03_panels/lower_panel.scad y
# nfc_panel.scad NO están aquí — añadirlos dispara el tiempo de
# ejecución del script bastante por encima de lo razonable (cada par
# con chassisSideWalls tarda ~25-30 s). Se han verificado a mano,
# aparte, contra chassisSideWalls (sin colisión real, solo contacto
# de borde esperado) — ver docs/03_Virtual_Assembly_Report.md.

COMPONENTS = [
    "um790InstanceBody", "noctuaInstanceBody", "rc522InstanceBody",
    "esp32InstanceBody", "hubInstanceBody", "oledInstanceBody",
    "pushbuttonInstanceBody", "usbFrontInstanceBody",
]

results = []
for sname, (spath, smodule) in STRUCTURES.items():
    rel = spath.relative_to(HERE.parent.parent.parent)
    for comp in COMPONENTS:
        scad = f"""
include <{'/'.join(['..']*3)}/00_parametros.scad>;
use <{spath}>;
use <{CHASSIS.parent.parent}/reference/components/assembly_instances.scad>;
$fn=32;
intersection() {{ {smodule}(); {comp}(); }}
"""
        tmp = HERE / "_tmp_check.scad"
        tmp.write_text(scad)
        out = subprocess.run(["openscad", "-o", str(HERE/"_tmp_check.stl"), str(tmp)],
                              capture_output=True, text=True)
        empty = "is empty" in out.stderr or "is empty" in out.stdout
        results.append((sname, comp, empty))
        tmp.unlink(missing_ok=True)
        (HERE/"_tmp_check.stl").unlink(missing_ok=True)

print(f"{'Estructura':20s} {'Componente':28s} Resultado")
print("-"*60)
n_ok = 0
n_bad = 0
for sname, comp, empty in results:
    status = "OK" if empty else "COLISIONA"
    if empty: n_ok += 1
    else: n_bad += 1
    print(f"{sname:20s} {comp:28s} {status}")
print("-"*60)
print(f"Total: {n_ok} sin colision, {n_bad} colisionan (de {len(results)})")


# ---- Estructura contra estructura -----------------------------------------
# Comprobación añadida el 2026-08-03 tras un aviso del usuario: el
# suelo (pilares de apoyo de la bandeja) y las paredes (rellenos de
# imán/tornillo) colisionaban entre sí, y esta comprobación no existía
# todavía — solo se comparaba cada pieza contra los componentes
# electrónicos, nunca las piezas del chasis entre sí.
#
# chassisFloor + chassisSideWalls se IMPRIMEN COMO UNA SOLA PIEZA
# (chassis.scad, chassisFixed() = union(...)) — el solape ahí es
# esperado, no un fallo.
#
# Los demás pares de esta lista son piezas SEPARADAS que se TOCAN por
# diseño (reposan una sobre otra, o llevan tornillos de unión):
#   - chassisSideWalls + chassisTop: la tapa se apoya en el borde
#     superior de la pared (ahí van los tornillos M3 de la tapa).
#   - chassisSideWalls + rearPanel: tornillos M3 de fijación del panel
#     trasero a la pared (2026-08-03).
#   - chassisFloor + rearPanel: el panel trasero apoya justo encima
#     del borde trasero del suelo (contacto de 0 mm de espesor,
#     verificado).
EXPECTED_UNION_PAIRS = {
    frozenset(["chassisFloor", "chassisSideWalls"]),
    frozenset(["chassisSideWalls", "chassisTop"]),
    frozenset(["chassisSideWalls", "rearPanel"]),
    frozenset(["chassisFloor", "rearPanel"]),
    frozenset(["chassisTop", "rearPanel"]),
}

print("\n" + "="*60)
print("ESTRUCTURA vs ESTRUCTURA")
print("="*60 + "\n")

names = list(STRUCTURES.keys())
struct_results = []
for i in range(len(names)):
    for j in range(i+1, len(names)):
        a, b = names[i], names[j]
        pa, ma = STRUCTURES[a][0], STRUCTURES[a][1]
        pb, mb = STRUCTURES[b][0], STRUCTURES[b][1]
        scad = f"""
include <{'/'.join(['..']*3)}/00_parametros.scad>;
use <{pa}>;
use <{pb}>;
$fn=32;
intersection() {{ {ma}(); {mb}(); }}
"""
        tmp = HERE / "_tmp_check.scad"
        tmp.write_text(scad)
        out = subprocess.run(["openscad", "-o", str(HERE/"_tmp_check.stl"), str(tmp)],
                              capture_output=True, text=True)
        empty = "is empty" in out.stderr or "is empty" in out.stdout
        expected = frozenset([a, b]) in EXPECTED_UNION_PAIRS
        struct_results.append((a, b, empty, expected))
        tmp.unlink(missing_ok=True)
        (HERE/"_tmp_check.stl").unlink(missing_ok=True)

n_ok2 = 0
n_bad2 = 0
n_expected = 0
for a, b, empty, expected in struct_results:
    if expected:
        status = "OK (union esperada, se imprimen juntas)"
        n_expected += 1
    elif empty:
        status = "OK"
        n_ok2 += 1
    else:
        status = "COLISIONA"
        n_bad2 += 1
    print(f"{a:20s} vs {b:20s} {status}")

print("-"*60)
print(f"Total: {n_ok2} sin colision, {n_bad2} colisionan, {n_expected} union esperada (de {len(struct_results)})")

