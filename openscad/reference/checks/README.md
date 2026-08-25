# Verificación de colisiones — Ensamblaje virtual v1

Comprueba automáticamente, componente contra componente, si los
volúmenes mecánicos del ensamblaje virtual (`virtual_assembly_v1.scad`)
colisionan entre sí.

## Cómo funciona

Para cada par de componentes se calcula `intersection(A, B)` en
OpenSCAD y se exporta el resultado a STL:

- Si el STL resultante está **vacío** → los volúmenes no se tocan →
  **sin colisión**.
- Si el STL contiene triángulos → los volúmenes se solapan
  físicamente → **colisión real**.

Se comprueban dos niveles:

1. **Cuerpos mecánicos rígidos** (`*InstanceBody`): cualquier
   intersección aquí es un fallo bloqueante — dos piezas físicas no
   pueden ocupar el mismo espacio.
2. **Volúmenes de seguridad / cableado** (`*InstanceKeepout`) contra
   cuerpos de *otros* componentes: es un aviso informativo, no un
   fallo. Indica que conviene revisar cómo se enruta el cableado en
   ese punto, no que dos piezas sólidas choquen.

Ambas comprobaciones usan las mismas posiciones que el ensamblaje
visual (`openscad/reference/components/assembly_positions.scad` y
`assembly_instances.scad`), así que el resultado del render y el de
la comprobación son siempre coherentes entre sí.

## Uso

```bash
cd openscad/reference/checks
python3 run_collision_checks.py
```

Requiere el binario `openscad` en el `PATH`. Los archivos `.scad` y
`.stl` intermedios se generan en `_generated/` (no se versionan, ver
`.gitignore`).

## Último resultado conocido

Ver `docs/Virtual_Assembly_Report.md` para el resultado de la
última ejecución y su interpretación.

## Añadir un componente nuevo

1. Crear su módulo en `openscad/reference/components/`.
2. Añadir su posición a `assembly_positions.scad`.
3. Añadir su `*InstanceBody()` (y `*InstanceKeepout()` si aplica) a
   `assembly_instances.scad`.
4. Añadirlo a la lista `COMPONENTS` (y `KEEPOUTS` si aplica) en
   `run_collision_checks.py`.
