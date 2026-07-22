# SteamMachine UM790
## Design Rules
### Versión 1.0

---

# Filosofía del proyecto

El objetivo de este proyecto es recrear una Steam Machine moderna basada en el Minisforum UM790 Pro manteniendo una estética inspirada en el diseño original de Valve, pero con una arquitectura interna completamente modular y preparada para futuras actualizaciones.

Cada decisión de diseño debe favorecer:

- Modularidad.
- Facilidad de impresión.
- Facilidad de montaje.
- Mantenimiento.
- Reutilización del código.
- Parametrización.

Nunca se priorizará la rapidez sobre la calidad del diseño.

---

# OpenSCAD

## 1. Medidas

Queda prohibido utilizar medidas numéricas directamente en las piezas.

Incorrecto:

```scad
cylinder(d=3.4,h=20);
```

Correcto:

```scad
m3Hole(20);
```

Todas las dimensiones deberán proceder de:

- 00_parametros.scad
- parámetros del módulo

---

## 2. Reutilización

Si una geometría aparece dos veces, deberá convertirse en un módulo.

Nunca se copiará código.

---

## 3. Parametrización

Toda pieza deberá poder modificarse desde los parámetros.

Ejemplo:

```scad
wall = 3;
guide_height = 12;
magnet_diameter = 8;
```

---

## 4. Organización

Cada archivo tendrá una única responsabilidad.

Ejemplos:

fasteners.scad

Solo tornillería.

guides.scad

Solo guías.

hardware.scad

Solo modelos simplificados.

---

## 5. Compatibilidad

Todo el proyecto deberá funcionar con OpenSCAD estable.

No se utilizarán funciones experimentales.

---

# Diseño mecánico

## 6. Sin soportes

Siempre que sea posible las piezas deberán imprimirse sin soportes.

---

## 7. Espesores mínimos

Paredes:

3 mm

Nervios:

2 mm

Postes:

10 mm diámetro mínimo para M3.

---

## 8. Holguras

Piezas móviles:

0.30 mm

Imanes:

0.15 mm

Insertos:

según fabricante.

---

## 9. Tornillería

Todo el proyecto utilizará preferentemente:

- Tornillos M3
- Insertos M3

Solo se utilizarán otros diámetros cuando sea imprescindible.

---

## 10. Modularidad

La sustitución del mini-PC deberá requerir únicamente:

- Nueva bandeja.
- Nuevo panel trasero.

El resto del chasis deberá permanecer idéntico.

---

# Electrónica

Todo componente electrónico deberá ser sustituible.

Ningún componente irá pegado.

Todos los soportes serán atornillados o encajados.

---

# Panel frontal

El panel frontal será completamente desmontable.

La fijación será mediante imanes.

El cambio de frontal no deberá requerir herramientas.

---

# Panel trasero

El panel trasero irá unido a la bandeja.

Al extraer la bandeja saldrá también el panel trasero.

---

# Refrigeración

La refrigeración será vertical.

Entrada inferior.

Salida superior.

Ventilador superior:

Noctua NF-A12x15 PWM.

---

# Código

Todo archivo deberá comenzar con una cabecera indicando:

- Proyecto
- Archivo
- Versión
- Descripción

---

Los nombres de módulos deberán escribirse en camelCase.

Ejemplo:

m3Post()

guideMale()

magnetSocket()

Nunca:

M3_POST()

guide_male()

---

# GitHub

Cada modificación importante deberá incrementar la versión.

Ejemplo:

v0.1

v0.2

v0.3

v1.0

---

Todo commit deberá describir claramente el cambio realizado.

---

# Objetivo final

Construir una Steam Machine moderna que pueda imprimirse completamente en una impresora FDM doméstica, utilizando componentes comerciales fácilmente sustituibles y manteniendo un diseño limpio, modular y fácilmente ampliable.

# Versionado de piezas

Toda pieza deberá incluir una variable:

part_version = "1.0";

y un comentario indicando:

- Fecha
- Autor
- Cambios respecto a la versión anterior
