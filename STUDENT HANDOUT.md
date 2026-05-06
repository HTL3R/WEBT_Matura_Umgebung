\setlength\LTleft{0pt}
\setlength\LTright{0pt}
  
# WEBT Matura Umgebung

Entwicklungsumgebung für die WEBT-Matura mit einem PHP/Symfony Server, einem Vue.js und einem React Projekt.

## Allgemeines

- Das Projekt sollte in einer Ubuntu WSL ausgeführt werden, dh auch alle Befehle wie das Starten von VSCode oder Datagrip sollte über die Ubuntu WSL ausgeführt werden.

## Projektstruktur

```
├── server/          # PHP/Symfony Backend (Port 80)
├── client/
│   ├── vue-project/ # Vue.js Frontend (Port 5173)
│   └── react-project/ # React Frontend (Port 5174)
├── compose.yaml     # Docker Compose Konfiguration
├── start.sh         # Container starten/stoppen
```

## Umgebung starten

Beim Starten von Docker Desktop werden automatisch die vorhandenen Container gestartet. Falls dies nicht der Fall ist, können die Container mit den folgenden Befehlen gestartet werden.

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

Logs anzeigen
```bash
./start.sh -l
./start.sh -l vue
```


## Umgebung stoppen

```bash
./start.sh -s
```

## Ports

| Service | URL |
|---------|-----|
| Server | http://localhost:80 |
| Vue.js | http://localhost:5173 |
| React | http://localhost:5174 |


## Dokumentation

Folgende URLs sind aus der Prüfungsumgebung erreichbar:

https://symfony.com/doc/current/index.html

https://www.doctrine-project.org/projects/doctrine-dbal/en/4.0/index.html

https://vuejs.org/guide/introduction.html

https://react.dev/learn

https://axios-http.com/docs/intro

Die Dokumentation ist ebenfalls offline verfügbar. 

| Docu | URL |
|---------|-----|
| DevDocs | http://localhost:9292 |
| Symfony | http://localhost:9293 |


## Autocomplete 

Der Ordner `node_modules` ist nur im Container vorhanden und muss für die Verwendung von Autocomplete auf den Host kopiert werden. Dies ist optional und kann über die folgenden Befehle in der **Ubuntu WSL** gemacht werden:

### Vue.js
```bash
cd WEBT_Matura_Umgebung/client/vue-project
docker cp webt_matura_umgebung-vue-1:/app/node_modules ./node_modules
```

### React
```bash
cd WEBT_Matura_Umgebung/client/react-project
docker cp webt_matura_umgebung-react-1:/app/node_modules ./node_modules
```

## **WICHTIG** für Vue.js!

Der Vue.js Container muss einmal zu Beginn neu erstellt werden. Dazu die folgenden Befehle ausführen:

```bash
cd WEBT_Matura_Umgebung/
docker compose -f compose.yaml down vue
docker compose -f compose.yaml up vue -d
```