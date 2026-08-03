#!/usr/bin/env python3
"""
SteamMachine UM790 — Project Phoenix

run_collision_checks.py

Comprueba, para cada par de componentes del ensamblaje virtual v1,
si sus volúmenes mecánicos rígidos (InstanceBody) colisionan.

Método:
  1. Para cada par (A, B) se genera un .scad que calcula
     intersection() { A(); B(); } usando las posiciones reales
     definidas en openscad/reference/components/assembly_positions.scad.
  2. Se exporta esa intersección a STL binario con OpenSCAD.
  3. Un STL binario vacío (0 triángulos) significa que los volúmenes
     NO se solapan → sin colisión. Un STL con triángulos significa
     que SÍ hay colisión física.

Uso:
    python3 run_collision_checks.py

Requiere el binario `openscad` en el PATH.
"""

import subprocess
import sys
from itertools import combinations
from pathlib import Path

HERE = Path(__file__).resolve().parent
GENERATED = HERE / "_generated"
TEMPLATE = HERE / "pair_template.scad"

# Cuerpos mecánicos rígidos definidos en assembly_instances.scad
COMPONENTS = [
    "um790InstanceBody",
    "noctuaInstanceBody",
    "rc522InstanceBody",
    "esp32InstanceBody",
    "hubInstanceBody",
    "oledInstanceBody",
    "pushbuttonInstanceBody",
    "usbFrontInstanceBody",
]

# Volúmenes de seguridad / cableado (comprobación "blanda": informativa,
# no bloqueante). Mapa: keepout -> componente al que pertenece (para no
# comprobarlo contra su propio cuerpo, lo cual siempre se solapa).
KEEPOUTS = {
    "um790InstanceKeepout":  "um790InstanceBody",
    "noctuaInstanceKeepout": "noctuaInstanceBody",
    "rc522InstanceKeepout":  "rc522InstanceBody",
    "esp32InstanceKeepout":  "esp32InstanceBody",
    "hubInstanceKeepout":    "hubInstanceBody",
    "usbFrontInstanceKeepout": "usbFrontInstanceBody",
}


def triangle_count(stl_path: Path) -> int:
    """Cuenta los triángulos de un STL ASCII (formato que exporta OpenSCAD por defecto)."""
    if not stl_path.exists():
        return 0
    text = stl_path.read_text(errors="ignore")
    return text.count("facet normal")


def run_pair(a: str, b: str) -> int:
    GENERATED.mkdir(exist_ok=True)

    scad_text = TEMPLATE.read_text().replace("__A__", a).replace("__B__", b)
    scad_path = GENERATED / f"{a}__vs__{b}.scad"
    stl_path = GENERATED / f"{a}__vs__{b}.stl"

    scad_path.write_text(scad_text)

    result = subprocess.run(
        ["openscad", "-o", str(stl_path), str(scad_path)],
        capture_output=True,
        text=True,
    )

    # Cuando intersection() da como resultado un volumen vacío (es decir,
    # NO hay colisión), OpenSCAD no genera STL y termina con
    # "Current top level object is empty." — este es el resultado
    # correcto de "sin colisión", no un error.
    if "is empty" in result.stderr or "is empty" in result.stdout:
        return 0

    if result.returncode != 0:
        print(f"  [ERROR OpenSCAD] {a} vs {b}")
        print(result.stderr.strip())
        return -1

    if not stl_path.exists():
        return 0

    return triangle_count(stl_path)


def main():
    pairs = list(combinations(COMPONENTS, 2))
    print(f"Comprobando {len(pairs)} pares de componentes...\n")

    collisions = []
    clean = []
    errors = []

    for a, b in pairs:
        n = run_pair(a, b)
        label = f"{a:28s} vs {b:28s}"

        if n < 0:
            errors.append((a, b))
            print(f"  ERROR   {label}")
        elif n == 0:
            clean.append((a, b))
            print(f"  OK      {label}  (sin intersección)")
        else:
            collisions.append((a, b, n))
            print(f"  COLISIÓN {label}  ({n} triángulos de solape)")

    print("\n=====================================================")
    print(f"Pares sin colisión : {len(clean)} / {len(pairs)}")
    print(f"Pares en colisión  : {len(collisions)}")
    print(f"Errores de render  : {len(errors)}")
    print("=====================================================")

    if collisions:
        print("\nCOMPONENTES EN COLISIÓN:")
        for a, b, n in collisions:
            print(f"  - {a} <-> {b} ({n} triángulos)")

    # ---- Segunda pasada: volúmenes de seguridad / cableado (informativa) ----
    print("\n=====================================================")
    print("AVISOS — volúmenes de seguridad / cableado")
    print("(no bloqueante: indica que conviene revisar el routing")
    print("del cableado en ese punto, no una colisión mecánica dura)")
    print("=====================================================\n")

    warnings = []
    for keepout, owner in KEEPOUTS.items():
        for other in COMPONENTS:
            if other == owner:
                continue
            n = run_pair(keepout, other)
            if n > 0:
                warnings.append((keepout, other, n))
                print(f"  AVISO   {keepout:28s} vs {other:28s}  ({n} triángulos)")

    if not warnings:
        print("  Sin avisos: ningún volumen de seguridad invade otro componente.")

    print("\n=====================================================")
    print(f"Total avisos de cableado: {len(warnings)}")
    print("=====================================================")

    return 1 if (collisions or errors) else 0


if __name__ == "__main__":
    sys.exit(main())
