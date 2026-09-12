# 13. Puesta en marcha de la Sinden Lightgun (Bazzite)

Procedimiento completo para dejar funcionando una Sinden Lightgun en la
Steam Machine (Bazzite/Fedora atómico), documentado tras la sesión del
2026-09-10/11. Escrito para no tener que redescubrir esto la próxima
vez — sobre todo la parte de adaptar las instrucciones oficiales
(pensadas para Arch/SteamOS) a Fedora/`rpm-ostree`.

---

## 0. Descartado antes: Wiimote + barra IR casera

Antes de tener la Sinden se intentó con un Wiimote + barra de LEDs
infrarrojos casera, usando `cwiid`/`wminput` (el software clásico para
traducir la cámara IR del Wiimote a puntero de ratón en Linux).

**Descartado**: `cwiid` no se actualiza desde hace más de una década y
falla con un error de Python (`PyCapsule_GetPointer called with
incorrect name`) incluso en su perfil más básico, en dos versiones
distintas de Debian (trixie y bookworm) — apunta a una incompatibilidad
de fondo con las versiones actuales de BlueZ, no arreglable cambiando
de distro. No merece la pena retomarlo salvo que aparezca un fork
mantenido. La alternativa moderna sería `xwiimote` (sí mantenido, ya
integrado en el kernel) + un script propio para traducir la posición IR
a ratón — no se ha llegado a escribir.

Con la Sinden Lightgun (periférico pensado específicamente para esto,
con software oficial) todo lo anterior deja de hacer falta.

---

## 1. Software oficial

Descargar desde `sindenlightgun.com/drivers/` — versión usada:
`SindenLightgunSoftwareReleaseV2.08b.zip`. Dentro:

```
SindenLightgunLinuxSoftwareV2.05/
├── SteamdeckVersion/Lightgun/   ← la que usamos (más cercana a Bazzite)
├── PCversion/
└── ARMversion/                   (Raspberry Pi, no aplica)
```

Copiar el contenido de `SteamdeckVersion/Lightgun/` a `~/Lightgun` en
la Steam Machine.

El `readme.txt` de esa carpeta trae las instrucciones oficiales, pero
están escritas para SteamOS/Arch (`pacman`, `steamos-readonly`) — no
funcionan tal cual en Bazzite. Lo que sigue es la traducción a
Fedora/`rpm-ostree`.

---

## 2. Dependencias (Fedora/Bazzite)

Bazzite es inmutable — los paquetes de sistema se instalan con
`rpm-ostree install` (no `dnf install` a secas) y **requieren
reiniciar** para aplicarse (a diferencia de `pacman` en SteamOS).

```bash
sudo rpm-ostree install mono-complete sdl12-compat SDL_image
systemctl reboot
```

Notas:
- `SDL2` ya viene de serie en Bazzite (`sdl2-compat`) — no hace falta
  instalarlo, y pedirlo junto con `SDL2-devel` provoca un conflicto de
  dependencias (`pkgconfig(glu)`) que no hace falta resolver, porque
  `-devel` tampoco hace falta para ejecutar el programa ya compilado.
- `mono-complete` sí está en los repos de Fedora directamente, sin
  necesidad de repos externos.
- `sdl12-compat` y `SDL_image` (la versión 1.2, no `SDL2_image`) están
  en Fedora con esos nombres exactos.

### 2.1. `libjpeg.so.8` — no está en Fedora, hay que sacarlo de un `.deb`

Fedora solo trae `libjpeg.so.62` (mucho más reciente); el software de
Sinden necesita literalmente la versión 8 (símbolo `LIBJPEG_8.0`) — un
enlace simbólico a la `.62` NO sirve, da error de versión de símbolo.

```bash
cd ~/Lightgun
curl -LO http://archive.ubuntu.com/ubuntu/pool/main/libj/libjpeg-turbo/libjpeg-turbo8_2.1.2-0ubuntu1_amd64.deb
ar x libjpeg-turbo8_2.1.2-0ubuntu1_amd64.deb
tar xf data.tar.xz
cp ./usr/lib/x86_64-linux-gnu/libjpeg.so.8 .
cp ./usr/lib/x86_64-linux-gnu/libjpeg.so.8.2.2 .
```

(El paquete `libjpeg8` de Ubuntu está vacío, solo depende de
`libjpeg-turbo8` — es este último el que hay que bajar.)

### 2.2. Nombres de librería exactos (Mono no busca con `lib` delante)

Mono busca los `.so` por el nombre EXACTO declarado en el binding, sin
el prefijo `lib` — hace falta un enlace:

```bash
cd ~/Lightgun
ln -s libSdlInterface.so SdlInterface.so
ln -s libCameraInterface.so CameraInterface.so
```

Para depurar qué librería falta en cada momento:

```bash
LD_LIBRARY_PATH=. ldd libSdlInterface.so
LD_LIBRARY_PATH=. ldd libCameraInterface.so
```

(mirar las líneas `not found` — sin `LD_LIBRARY_PATH=.` no encuentra
las que están en la propia carpeta).

---

## 3. Permisos: cámara y puerto serie

```bash
sudo usermod -a -G video $USER
```

### 3.1. El grupo `dialout` — fallo real de esta instalación de Bazzite

`usermod -a -G dialout` y `gpasswd -a ... dialout` **no funcionan** en
este sistema aunque no den ningún error: el grupo `dialout` que ve
`getent group dialout` no vive en `/etc/group` (que está casi vacío,
gestionado aparte por `systemd`/`altfiles`) — `gpasswd` incluso llega a
decir literalmente que el grupo "no existe en /etc/group", aunque
`getent` sí lo ve. Comprobado con `cat /etc/nsswitch.conf | grep
group`: `files [SUCCESS=merge] altfiles [SUCCESS=merge] systemd`.

Arreglo: añadir la línea a mano, con el mismo GID que ya tiene el
sistema (18, estándar en casi cualquier distro):

```bash
echo 'dialout:x:18:'"$USER" | sudo tee -a /etc/group
systemctl reboot
```

Tras reiniciar, `groups` debería incluir `dialout`. Sin esto, el
programa encuentra la pistola pero da "Permiso denegado" al intentar
abrir `/dev/ttyACM0`.

---

## 4. Firmware — necesita v1.9, no la de fábrica

El propio software avisa en mayúsculas: **hace falta firmware v1.9**
para que el modo joystick (usado para la calibración) funcione bien.
Con v1.8 (de fábrica en la unidad usada aquí), el gesto de calibración
(mantener D-pad izquierda 5s) no llega a registrarse — la calibración
se sale sola apuntando a la esquina inferior derecha sin que dé tiempo
a nada.

La actualización de firmware **requiere Windows** (no hay ruta
documentada desde Linux) — usar
`SindenLightgunWindowsV2.08/SindenLightgun/Lightgun.exe` en un PC con
Windows:

1. Instalar los drivers de `Tools/FirmwareUpdateDrivers/` si Windows no
   reconoce la pistola sola.
2. Abrir `Lightgun.exe`, pestaña de actualización de firmware, subir a
   v1.9.
3. **Paso aparte, no combinado con la actualización**: en esa misma
   pestaña, activar explícitamente la casilla de "joystick
   functionality" para cada pistola.
4. No desconectar la pistola ni cerrar el programa mientras actualiza.

---

## 5. Lanzar y calibrar

```bash
cd ~/Lightgun
LD_LIBRARY_PATH=. mono LightgunMono.exe steam joystick sdl
```

- `steam` → encoge la utilidad para que quepa en pantalla.
- `joystick` → modo joystick (necesita firmware v1.9, ver arriba).
- `sdl` → abre la utilidad de calibración.

**Requisito de luz — importante**: la cámara de la Sinden puede
"temblar"/dar saltos con luz solar, bombillas incandescentes/halógenas
cerca, o reflejos — confirmado en esta sesión que a oscuras la mira
queda perfectamente estable. Jugar con la sala en penumbra, sin luz
directa detrás/cerca de la pantalla.

Procedimiento de calibración (con la mira ya estable):
1. Apuntar al centro de la pantalla.
2. Mantener pulsado **D-pad izquierda** 5 segundos seguidos.
3. Cuando la mira se centre sola, **disparar** ahí.
4. Salir apuntando a la esquina inferior derecha de la pantalla.

Ajustes recomendados en el software de Sinden para este juego
concreto (pestaña "Main"): contraste 128, brillo 39. Monitor/TV a
60Hz (una tasa de refresco alta no le sienta bien al rastreo).

---

## 6. THE HOUSE OF THE DEAD: Remake — marco blanco + mod necesario

El juego se publicó **sin soporte nativo de lightgun**. Con el marco
blanco de Sinden por sí solo, varios usuarios reportan que la mira se
descalibra en cada cambio de escena/cutscene — hace falta un mod de
terceros para que sea jugable de verdad.

### 6.1. Ajuste de pantalla del juego (aparte del mod)

En los ajustes de vídeo del propio juego: **Screen Mode = Fullscreen
Window** (no pantalla completa exclusiva) — si no, el marco de Sinden
no se puede superponer encima del juego. Desactivar la mira propia del
juego en Ajustes → Gameplay (la de Sinden ya hace ese papel).

### 6.2. ArcadeMod (argonlefou) — instalación

Repositorio: `github.com/argonlefou/HotdRemake_ArcadePlugin`.

**Ojo con esto**: el paquete instalable está en la sección
**Releases** del repositorio (a la derecha en GitHub), NO en el botón
verde "Code → Download ZIP" — ese botón baja el código fuente, sin el
`.exe` ya compilado. Es un error fácil de cometer (hay varios usuarios
en los foros con la misma confusión, buscando un `ArcadeMod_Config.exe`
que "no existe" tras bajar el ZIP equivocado).

1. `github.com/argonlefou/HotdRemake_ArcadePlugin/releases` → última
   versión (v3.0 en el momento de escribir esto) → descargar el `.zip`
   de sus Assets.
2. Descomprimir todo el contenido en la carpeta raíz del juego (donde
   está `The House of the Dead Remake.exe`).
3. Quitar cualquier plugin antiguo previo (p.ej. el de "Mystery
   Wizard", de versiones más viejas del parche) — pueden chocar entre
   sí.
4. Ejecutar `ArcadeMod_Config.exe`:
   - `Input Type` = **SINGLE PLAYER** (con una sola Sinden basta; MULTIPLAYER
     necesita además DemulShooter, para 2 pistolas).
   - `Display Settings` → Screen Mode = **FULLSCREEN WINDOW**.
   - Ajustar resolución a la pantalla real.
   - Guardar con "Save Config" (genera `ArcadeMod_Config.ini`).
5. El juego puede fallar/cerrarse la PRIMERA vez que arranca tras
   cambiar resolución o modo de pantalla — fallo conocido y
   documentado por el propio autor. Volver a abrirlo una segunda vez.
6. Jugar con teclado (`1` = inicio P1, `2` = inicio P2, `5` = monedas)
   y after eso, ratón/lightgun.
7. Para desinstalar: borrar el `.dll` de `BepInEx\plugin\` en la
   carpeta del juego.

### 6.3. Aviso: compatibilidad con Proton sin confirmar

El ArcadeMod está pensado para Windows (usa BepInEx, un framework de
modding de Unity). La Steam Machine corre el juego vía **Proton**
(capa de compatibilidad de Steam), y no hay ninguna confirmación
encontrada de que este mod en concreto funcione bajo Proton — ningún
hilo de los revisados lo menciona probado en Linux. Puede funcionar
(muchos plugins de BepInEx sí lo hacen), pero es la primera vez que se
prueba aquí. Si no carga, probar forzando una versión de Proton
distinta (Proton GE suele arreglar líos de compatibilidad con
BepInEx).

---

## 7. Pendiente

- **Verificar dentro del Game Mode/Big Picture real** (gamescope), no
  solo en el escritorio de KDE donde se hizo esta puesta a punto —
  gamescope tiene problemas conocidos y todavía abiertos con
  dispositivos de ratón "emulados" (cursor invisible, entrada no
  capturada). No confirmado si afecta a este periférico en concreto.
- **Confirmar el ArcadeMod funcionando de verdad** bajo Proton en la
  Steam Machine (ver 6.3) — quedó pendiente de probar tras corregir el
  enlace de descarga (Releases, no Code).
- THE HOUSE OF THE DEAD 2: Remake tiene su propio parche, distinto
  (de "Disc0-LightgunMad", mencionado en `sindenwiki.org`) — no
  investigado todavía.
- **El marco blanco no aparece en Linux fuera de la utilidad de
  calibración** (`sdl`) — confirmado con capturas reales: ni
  `mono LightgunMono.exe joystick` en primer plano ni
  `mono-service LightgunMono.exe joystick` en segundo plano dibujan
  ningún marco continuo durante el juego. A diferencia de Windows, el
  port a Linux de Sinden no trae overlay de marco a nivel de sistema
  — confirmado también por comentarios de la comunidad ("sería genial
  que Sinden diera un marco a nivel de sistema como en Windows").
  Se descartó la vía física (tira de LED alrededor del monitor, más
  simple y sin depender de ningún software) a favor de un overlay
  propio, en construcción — ver siguiente punto.

## 8. Overlay de marco blanco a medida (KDE/Wayland) — EN CONSTRUCCIÓN, sin terminar

Bazzite/KDE aquí corre en **Wayland** (`echo $XDG_SESSION_TYPE` →
`wayland`), no X11 — confirmado. Bajo Wayland, una ventana normal no
puede colocarse "siempre encima de todo, incluido el juego a pantalla
completa" ni "dejar pasar el ratón a través suyo" sin usar el
protocolo `wlr-layer-shell` — por eso hace falta un programa propio
(no una simple ventana), usando **LayerShellQt** (Qt6 + C++). Se
comprobó que existe un proyecto ya hecho con esta misma técnica,
confirmado funcionando en Fedora KDE/Wayland (`github.com/Defiect/koverlay`,
para notas de texto) — sirvió para confirmar que la técnica es viable
en esta plataforma exacta antes de escribir la nuestra.

### Dónde se quedó

Código en `~/sinden_border/` (dentro de una distrobox de **Fedora 44**,
`distrobox create --name sindenborder --image fedora:44` — Fedora, no
Debian, para que las librerías de Wayland/Qt coincidan con las del
sistema anfitrión).

Dependencias (dentro de la distrobox):
```bash
sudo dnf install -y qt6-qtbase-devel qt6-qtdeclarative-devel layer-shell-qt-devel wayland-devel cmake gcc-c++ make
```

`CMakeLists.txt` — el nombre real del paquete CMake es `LayerShellQt`
(NO `LayerShellQtInterface`, que era una suposición inicial
equivocada), con el target `LayerShellQt::Interface`:
```cmake
cmake_minimum_required(VERSION 3.16)
project(sinden_border)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD 17)

find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(LayerShellQt REQUIRED)

add_executable(sinden_border main.cpp)
target_link_libraries(sinden_border PRIVATE Qt6::Widgets LayerShellQt::Interface)
```

`main.cpp` — un `QWidget` sin decoración, fondo transparente, que
pinta solo un marco blanco (grosor configurable por argumento,
40px por defecto) y usa `LayerShellQt::Window` para anclarse a los 4
bordes de la pantalla en la capa superior (`LayerOverlay`), sin robar
el teclado (`KeyboardInteractivityNone`) y transparente para el ratón
(`Qt::WindowTransparentForInput` + `Qt::WA_TransparentForMouseEvents`):

```cpp
#include <QApplication>
#include <QWidget>
#include <QPainter>
#include <QScreen>
#include <QWindow>
#include <LayerShellQt/Window>

class BorderOverlay : public QWidget
{
public:
    explicit BorderOverlay(int thickness) : m_thickness(thickness)
    {
        setAttribute(Qt::WA_TranslucentBackground);
        setAttribute(Qt::WA_TransparentForMouseEvents);
        setWindowFlag(Qt::FramelessWindowHint);
        setWindowFlag(Qt::WindowStaysOnTopHint);
        setWindowFlag(Qt::WindowTransparentForInput);
    }

protected:
    void paintEvent(QPaintEvent *) override
    {
        QPainter p(this);
        p.setPen(Qt::NoPen);
        p.setBrush(Qt::white);
        const int w = width();
        const int h = height();
        p.drawRect(0, 0, w, m_thickness);
        p.drawRect(0, h - m_thickness, w, m_thickness);
        p.drawRect(0, 0, m_thickness, h);
        p.drawRect(w - m_thickness, 0, m_thickness, h);
    }

private:
    int m_thickness;
};

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

    int thickness = (argc > 1) ? QString(argv[1]).toInt() : 40;

    BorderOverlay overlay(thickness);
    QScreen *screen = QGuiApplication::primaryScreen();
    overlay.setGeometry(screen->geometry());
    overlay.show();

    auto lsWindow = LayerShellQt::Window::get(overlay.windowHandle());
    lsWindow->setLayer(LayerShellQt::Window::LayerOverlay);

    LayerShellQt::Window::Anchors anchors(LayerShellQt::Window::AnchorTop);
    anchors |= LayerShellQt::Window::AnchorBottom;
    anchors |= LayerShellQt::Window::AnchorLeft;
    anchors |= LayerShellQt::Window::AnchorRight;
    lsWindow->setAnchors(anchors);

    lsWindow->setExclusiveZone(-1);
    lsWindow->setKeyboardInteractivity(LayerShellQt::Window::KeyboardInteractivityNone);
    lsWindow->setScope(QStringLiteral("sinden-border"));

    return app.exec();
}
```

### Fallos ya encontrados y corregidos, por si se repiten

- `find_package(LayerShellQtInterface)` → nombre real es
  `find_package(LayerShellQt)`, target `LayerShellQt::Interface`.
  Confirmado con `rpm -ql layer-shell-qt-devel | grep -i cmake`.
- `LayerShellQt::Window::AnchorTop | ... | AnchorRight` pasado
  directamente a `setAnchors()` → error de compilación (`invalid
  conversion from 'int' to 'LayerShellQt::Window::Anchor'`, con
  `-fpermissive`): el operador `|` entre valores del enum da un `int`
  normal, no el `QFlags` que espera Qt. Arreglado construyendo el
  `QFlags` explícitamente (`LayerShellQt::Window::Anchors anchors(...);
  anchors |= ...;`) en vez de un único `|` encadenado.

### Siguiente paso (sin hacer todavía)

Con el fallo de compilación de arriba corregido en el propio
`main.cpp` (ver más arriba, ya corregido en el código de esta
sección), toca:
```bash
cd ~/sinden_border/build
make
./sinden_border
```
Y comprobar en pantalla: ¿aparece el marco blanco?, ¿el centro es
realmente transparente (se ve el escritorio a través)?, ¿el ratón
atraviesa la ventana (un clic en algo de debajo funciona con
normalidad)? Sin probar todavía.
