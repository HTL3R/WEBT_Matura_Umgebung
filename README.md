# WEBT Matura Umgebung

Entwicklungsumgebung für die WEBT-Matura mit einem PHP/Symfony Server, einem Vue.js und einem React Projekt.

## Voraussetzungen

- [Docker](https://docs.docker.com/get-docker/) muss installiert sein.
- Das Projekt sollte in einer Ubuntu WSL ausgeführt werden.

## Projektstruktur

```
├── server/          # PHP/Symfony Backend (Port 80)
├── client/
│   ├── vue-project/ # Vue.js Frontend (Port 5173)
│   └── react-project/ # React Frontend (Port 5174)
├── compose.yaml     # Docker Compose Konfiguration
├── start.sh         # Container starten/stoppen
└── build.sh         # Images bauen und exportieren
```

## Umgebung starten

Alle Services (Server, Vue, React) starten:

```bash
./start.sh
```

Im Hintergrund starten:

```bash
./start.sh -d
```

Einzelne Services starten:

```bash
./start.sh vue
./start.sh react
./start.sh server
```

## Umgebung stoppen

```bash
./start.sh -s
```

## Weitere Befehle

| Befehl | Beschreibung |
|--------|-------------|
| `./start.sh -b` | Images neu bauen und starten |
| `./start.sh -r` | Container neu starten |
| `./start.sh -l` | Logs anzeigen |
| `./start.sh -l vue` | Logs eines einzelnen Services anzeigen |
| `./start.sh --status` | Status der Container anzeigen |

## Images bauen und exportieren

Images bauen (ohne zu starten):

```bash
./build.sh              # Alle Images
./build.sh server       # Nur Server
./build.sh vue          # Nur Vue
./build.sh react        # Nur React
```

Clean Build (ohne Docker Cache):

```bash
./build.sh -c           # Alle Images ohne Cache
./build.sh -c vue       # Nur Vue ohne Cache
```

Images bauen und als `.tar` exportieren (nach `_images/`):

```bash
./build.sh -e           # Alle Images
./build.sh -e server    # Nur Server
```

Optionen können kombiniert werden:

```bash
./build.sh -c -e        # Clean Build und Export aller Images
```

Exportierte Images auf einem anderen Rechner laden:

```bash
docker load -i _images/matura-webt-server.tar
```

## Ports

| Service | URL |
|---------|-----|
| Server | http://localhost:80 |
| Vue.js | http://localhost:5173 |
| React | http://localhost:5174 |

Die Ports können über Umgebungsvariablen angepasst werden: `HTTP_PORT`, `VUE_PORT`, `REACT_PORT`.
