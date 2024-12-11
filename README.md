# Projektarbeit M346
Dieses Repository wurde von Levin Fritz, Noé Messmer und Janis Mora im Rahmen einer Projektarbeit im M346 erstellt.

[Hier](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Dokumentation.md) geht es zur Dokumentation.

Dieses Projekt erstellt eine AWS-Infrastruktur für ein Ticketsystem mit osTicket. Es umfasst:
- Einen Webserver mit Apache und PHP
- Einen Datenbankserver mit MariaDB

## Voraussetzungen
- AWS CLI installiert und konfiguriert
- `git` installiert

## Installation
1. Klone das Repository:
   ```bash
   git clone https://github.com/levinfritz/M346-Levin-Noe-Janis.git
   cd M346-Levin-Noe-Janis/Konfiguration

2. Mache das  deploy.sh Skript ausführbar und führe es aus. 
    ```bash
   chmod u+x deploy.sh
   ./deploy.sh

3. Greife auf den Webserver zu: Öffne die IP-Adresse des Webservers in deinem Browser. 
