# SteamMachine Software Core v0.2

Aplicacion Python que corre en el mini PC (Bazzite) y coordina el ESP32
(paneles NFC + boton + OLED + LEDs) con el lanzador de plataformas
(Steam, RetroDECK, TeknoParrot). Arquitectura y protocolo: ver `docs/03`,
`docs/04`, `docs/05`, `docs/08` en la raiz del repo.

> Nota: `docs/03_Software_Architecture.md` y `docs/08_Software_API.md`
> mencionan todavia Windows/RetroBat, de una version anterior del
> proyecto. Este Core esta implementado para Linux/Bazzite (RetroDECK +
> TeknoParrot via Lutris), segun la decision mas reciente. Pendiente de
> actualizar esos dos documentos.

## Instalar

```bash
cd software
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

## Ejecutar (modo simulado, sin ESP32)

Por defecto `config/config.json` tiene `"serial.simulate": true`, asi que
puedes probar todo el flujo sin firmware ni hardware conectado:

```bash
python main.py
```

Se abre una consola interactiva:

```
sim> 04A1C8B2      # simula "colocar panel Steam"
sim> b             # simula pulsar el boton -> lanza Steam
sim> r             # simula "retirar panel"
sim> q             # salir
```

Los UID de ejemplo (Steam / RetroDECK / TeknoParrot) estan en
`config/panel_database.json` y corresponden a los 3 paneles NFC ya
diseñados en el CAD.

## Ejecutar con el ESP32 real

Cuando el firmware exista, pon `"serial.simulate": false` en
`config/config.json` (o deja `"port": "auto"`, que detecta el ESP32 por
VID:PID). El protocolo esperado es exactamente el de `docs/04`.

## Estructura

```
core/        Application, ConfigurationManager, EventManager, logger
devices/     SerialManager (real) / SimulatedSerialManager, ESP32Controller
database/    PanelDatabase (config/panel_database.json)
launcher/    BasePlugin + SteamPlugin, RetroDeckPlugin, TeknoParrotPlugin
config/      config.json, panel_database.json
```

## Pendiente

- Firmware ESP32 (Fase 7 del roadmap) — el protocolo ya esta implementado
  en el lado PC, listo para conectarse en cuanto exista.
- OLEDManager / LEDManager "ricos" (animaciones, iconos) — de momento
  el Core envia comandos de texto/color simples via `ESP32Controller`.
- Persistir `_pending_panel` no es necesario (se resetea con cada tag),
  pero si se añade reconexion en caliente conviene revisar ese estado.

