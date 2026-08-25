# SteamMachine Software Core v0.2

Aplicacion Python que corre en el mini PC (Bazzite) y coordina el ESP32
(paneles NFC + boton + OLED + LEDs) con el lanzador de plataformas
(Steam, RetroDECK, TeknoParrot). Arquitectura y protocolo: ver `docs/03`,
`docs/04`, `docs/05`, `docs/08` en la raiz del repo.

## Instalar

```bash
cd software
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Ejecutar con el ESP32 real (hardware ya montado)

`config/config.json` tiene `"serial.simulate": false` por defecto: al
arrancar busca el ESP32 automaticamente por VID:PID (`"port": "auto"`).

```bash
python main.py
```

Si no lo encuentra, localiza el puerto a mano en Bazzite:

```bash
ls /dev/serial/by-id/     # busca algo como usb-1a86_USB_Serial-if00-port0
```

y ponlo explicitamente en `config/config.json`:

```json
"serial": { "port": "/dev/ttyUSB0", "simulate": false }
```

Antes de dar por buena una sesion con hardware real, sigue el checklist
de `firmware/README.md` ("Prueba de integracion") para confirmar que el
propio firmware responde bien por su cuenta.

Con `"simulate": false` el Core espera al ESP32 real: si no esta
conectado o no responde con `boot`, veras avisos de reconexion en el
log (`logs/steammachine.log`) cada `serial.reconnect_interval_seconds`.

## Ejecutar en modo simulado (sin ESP32, para desarrollo)

Util para tocar la logica del Core sin depender del hardware. Pon
`"serial.simulate": true` en `config/config.json` y ejecuta `python
main.py`: se abre una consola interactiva.

```
sim> 04A1C8B2      # simula "colocar panel Steam"
sim> b             # simula pulsar el boton -> lanza Steam
sim> r             # simula "retirar panel"
sim> q             # salir
```

Los UID de ejemplo (Steam / RetroDECK / TeknoParrot) estan en
`config/panel_database.json` y corresponden a los 3 paneles NFC ya
diseñados en el CAD — si tus tags reales tienen otros UID, actualiza
ese fichero con los que reporte el firmware al leerlos (ver el
checklist de `firmware/README.md`).

## Arranque automático (systemd)

Para que el Core arranque solo con la sesión gráfica de Bazzite, sin
tener que abrir una terminal cada vez (pensado para el uso "aparato",
incluida la segunda residencia):

```bash
mkdir -p ~/.config/systemd/user
cp steammachine.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now steammachine.service
```

Comprobar estado y logs:

```bash
systemctl --user status steammachine.service
journalctl --user -u steammachine.service -f
```

`steammachine.service` reinicia el Core solo si se cae (`Restart=on-failure`)
y espera a que el escritorio gráfico esté listo antes de arrancar. Editar
`ExecStart`/`WorkingDirectory` si tu ruta de instalación no es `~/SteamMachine-UM790/software`.

## Tests

```bash
pip install -r requirements-dev.txt
pytest
```

Cubren `LEDManager` y `OLEDManager` (comandos directos, `flash`/`fade` y su
cancelacion mutua, y la aproximacion de `sleep`/`wake`), `Application`
(logica de los eventos del protocolo — tag, tag_removed, button — con
`OLEDManager`/`LEDManager`/`Launcher`/`PanelDatabase` sustituidos por
dobles), `PanelDatabase` (carga/guardado, JSON malformado, mayus/minus
en el UID) y `Launcher`/`BasePlugin` (lanzar, parar y consultar estado
de procesos reales de corta duracion — se usa `python -c "..."` en vez
de steam/flatpak/lutris, que no estan instalados en este entorno).

Todo con dobles (`tests/fakes.py`) o ficheros temporales — no hace falta
hardware, ESP32 ni las plataformas reales para correrlos.

## Estructura

```
core/        Application, ConfigurationManager, EventManager, logger
devices/     SerialManager (real) / SimulatedSerialManager, ESP32Controller
database/    PanelDatabase (config/panel_database.json)
launcher/    BasePlugin + SteamPlugin, RetroDeckPlugin, TeknoParrotPlugin
config/      config.json, panel_database.json
```

## Pendiente

- Validar con hardware real (ver checklist en `firmware/README.md`,
  "Prueba de integración") — todo lo de arriba está probado con el
  ESP32 simulado, no con el físico.
- Actualizar `config/panel_database.json` con los UID reales de tus
  tags NFC en cuanto los leas del firmware (ahora mismo tiene UID de
  ejemplo).
- Persistir `_pending_panel` no es necesario (se resetea con cada tag),
  pero si se añade reconexion en caliente conviene revisar ese estado.
- Zumbador y actualizaciones OTA: sin implementar todavía (ver roadmap,
  Fase 10).

