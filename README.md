# SteamMachine-UM790
Proyecto de Steam Machine casera funcional
Diseño de carcasa 3D personalizada para convertir un mini PC **Minisforum UM790** en una Steam Machine compacta orientada a gaming, emulación y uso multimedia.

Proyecto desarrollado en **OpenSCAD**, con piezas preparadas para impresión 3D.

---

## 📷 Galería

<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/8020d66b-9920-4f28-941f-c2b32f67ebfd" />


---

## 📌 Características

- Carcasa modular diseñada específicamente para UM790.
- Diseño paramétrico en OpenSCAD.
- Piezas separadas para facilitar la impresión.
- Optimizada para impresoras FDM.
- Preparada para montaje con tornillería estándar.
- Ventilación integrada para mantener temperaturas adecuadas.
- Diseño orientado a estética tipo consola Steam Machine.
- Sistema de paneles frontales intercambiables.
- Identificación NFC para cambio de modo.
- Diseño preparado para expansión con nuevos paneles.

## 🎮 Sistema de paneles frontales NFC

Uno de los elementos principales del diseño es el sistema de paneles frontales intercambiables mediante identificación NFC.

La carcasa permite utilizar diferentes paneles frontales personalizados, cada uno asociado a una función, sistema o configuración concreta mediante etiquetas NFC integradas.

### Funcionamiento

Cada panel frontal incorpora:

- Un diseño físico específico según la temática.
- Una etiqueta NFC integrada en el propio panel.
- Identificación automática al acercar el dispositivo lector NFC.
- Posibilidad de lanzar diferentes configuraciones o aplicaciones según el panel utilizado.

Ejemplos de uso:

- 🎮 Panel Steam Machine → inicia Steam Big Picture.
- 🕹️ Panel Arcade → inicia RetroBat / frontend arcade.
- ⚙️ Panel Configuración → acceso a herramientas del sistema.
- 🎵 Panel Multimedia → reproducción multimedia.

---

## 🔌 Integración NFC

El sistema está pensado para trabajar con un lector NFC conectado al equipo.

Flujo de funcionamiento:

Las etiquetas NFC pueden programarse para ejecutar diferentes acciones:

- Abrir aplicaciones.
- Ejecutar scripts.
- Cambiar perfiles.
- Lanzar emuladores.
- Seleccionar diferentes modos de uso.

---

## 🧩 Diseño modular

Los paneles frontales están diseñados para poder sustituirse fácilmente:

- Sistema de fijación común.
- Compatibilidad con futuros diseños.
- Personalización mediante impresión 3D.
- Posibilidad de crear paneles temáticos.

El objetivo es que la SteamMachine pueda cambiar de función simplemente sustituyendo el panel frontal.---

## 🖨️ Impresión 3D

### Impresora recomendada

Compatible con:

- Anycubic Kobra X
- Impresoras FDM con volumen similar

### Material recomendado

- PLA para pruebas y prototipos.
- PETG para versión definitiva.
- ABS/ASA si se requiere mayor resistencia térmica.

### Parámetros orientativos

- Altura de capa: 0,20 mm
- Paredes: 3-4 perímetros
- Relleno: 15-30 %
- Soportes: según pieza

---

## 📂 Estructura del proyecto

SteamMachine-UM790
│
├── OpenSCAD
│ ├── 00_parametros.scad
│ ├── chasis.scad
│ ├── tapa.scad
│ └── piezas_auxiliares.scad
│
├── STL
│ ├── chasis_base.stl
│ ├── tapa_superior.stl
│ └── accesorios.stl
│
├── Images
│ └── renders
│
└── README.md


---

## 🛠️ Software utilizado

- OpenSCAD  
  https://openscad.org/

- Cura / OrcaSlicer / PrusaSlicer para laminado.

---

## ⚙️ Personalización

El diseño utiliza parámetros editables para modificar:

- Dimensiones generales.
- Posición del equipo.
- Grosor de paredes.
- Ventilación.
- Anclajes.
- Compatibilidad con diferentes accesorios.

Archivo principal:



---

## 🚀 Estado del proyecto

🟡 En desarrollo

### Completado

- [x] Definición inicial del diseño.
- [x] Sistema paramétrico.
- [x] Preparación del repositorio.

### Pendiente

- [ ] Validación de medidas reales.
- [ ] Primera impresión de prueba.
- [ ] Ajustes finales.
- [ ] Publicación de STL definitivos.

---


## 🤝 Contribuciones

Las mejoras, modificaciones y sugerencias son bienvenidas.

Si realizas una modificación o adaptación, puedes abrir un Pull Request.

---

## 📜 Licencia

Pendiente de definir.

---

## Autor

Pep Ventura

Proyecto creado para uso personal y compartido con la comunidad maker.

## Licencia

Este proyecto está bajo la **Licencia MIT**. Esto significa que puedes usar, modificar y distribuir el código libremente, incluso para fines comerciales. 

Para más detalles, consulta el archivo [LICENSE](LICENSE) incluido en este repositorio.

