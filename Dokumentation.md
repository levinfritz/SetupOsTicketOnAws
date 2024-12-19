# Dokumentation M346-Ticketsystem

Dieses Repository wurde in Zusammenarbeit von Levin Fritz, Noé Messmer und Janis Mora erstellt. Diese Dokumentation beschreibt das gesamte Projekt von der Planung bis zum fertigen Skript. Ebenso wird eine Anleitung zur Installation des Ticketsystems mit unserem Skript bereitgestellt.

## Inhaltsverzeichnis

1. [Projektinformationen](#projektinformationen)  
   1.1 [Aufgabenstellung](#aufgabenstellung)  
   1.2 [Wahl des Ticketsystems](#wahl-des-ticketsystems)  
   1.3 [Aufgaben und Zuständigkeiten](#aufgaben-und-zuständigkeiten)  
2. [Installation und Konfiguration](#installation-und-konfiguration)  
   2.1 [Erklärung des Codes](#erklärung-des-codes)  
   2.2 [Begründung für Terraform statt Cloud-Init](#begründung-für-terraform-statt-cloud-init)  
3. [Anleitung](#anleitung)  
4. [Testfälle](#testfälle)  
5. [Reflexion](#reflexion)  

## 1. Projektinformationen

### 1.1 Aufgabenstellung

Für das Projekt sollte ein Ticketsystem auf einer AWS-Instanz eingerichtet werden. Die Installation der Instanzen und von OS-Ticket sollte automatisiert erfolgen.

### 1.2 Wahl des Ticketsystems

Wir haben uns für osTicket entschieden, da es eine stabile Open-Source-Lösung mit umfangreichen Funktionen ist. Es bietet eine benutzerfreundliche Oberfläche, flexible Konfigurationsmöglichkeiten und Unterstützung für mehrere Kommunikationskanäle.

### 1.3 Aufgaben und Zuständigkeiten

Das Projekt umfasste die Umsetzung des Ticketsystems und die Erstellung einer ausführlichen Dokumentation. Alle Gruppenmitglieder waren an allen Aufgaben beteiligt, jedoch konzentrierten sich Levin und Noé verstärkt auf die Einrichtung der AWS-Umgebung, während Janis die Dokumentation ausführlich gestaltete.

## 2. Installation und Konfiguration

### Verwendete Skripte

- **[`main.tf`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/main.tf):**  
  Definiert die gesamte Infrastruktur auf AWS, einschließlich EC2-Instanzen, Sicherheitsgruppen und Schüsselpaaren.

- **[`web-init.sh`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/web-init.sh):**  
  Installiert und konfiguriert osTicket auf einer Apache-Instanz. Die Verbindung zur Datenbank wird automatisch hergestellt.

- **[`db-init.sh`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/db-init.sh):**  
  Installiert und konfiguriert eine MariaDB-Instanz für osTicket. Es werden Datenbankname, Benutzer und Passwörter erstellt.

- **[`deploy.sh`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/deploy.sh):**  
  Automatisiert die Installation von Terraform, führt die Terraform-Skripte aus und stellt sicher, dass die Datenbank-IP in die Webserver-Konfiguration eingefügt wird.


### 2.1 Erklärung des Codes

#### Terraform (`main.tf`)
  - Zwei EC2-Instanzen werden erstellt: eine für den Webserver und eine für die Datenbank.
  - Sicherheitsgruppen regeln den Zugriff: HTTP/HTTPS für den Webserver und MySQL für die Datenbank.
  - Die Datenbank-Instanz wird über ihre private IP-Adresse vom Webserver aus angesprochen.
  - Die öffentliche IP-Adresse des Webservers und die private IP-Adresse des Datenbankservers werden exportiert, um sie im Deploy-Skript zu verwenden.

- **Beispiel: Sicherheitsgruppe für den Webserver**  
  ```hcl
  resource "aws_security_group" "web_sg" {
    name_prefix = "web-sg-"
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ```  
  **Erklärung:** Diese Sicherheitsgruppe erlaubt HTTP-Zugriff (Port 80) von allen IP-Adressen und alle ausgehenden Verbindungen.  

- **Outputs:**  
  ```hcl
  output "web_server_public_ip" {
    value = aws_instance.web_server.public_ip
  }
  ```  
  **Erklärung:** Die öffentliche IP-Adresse des Webservers wird exportiert, damit sie später im `deploy.sh`-Skript verwendet werden kann.

#### Webserver-Initialisierung (`web-init.sh`)
- Installiert alle notwendigen Pakete wie Apache, PHP und osTicket.
- Lädt osTicket von GitHub herunter und entpackt es.
- Verschiebt die osTicket-Dateien in das Webroot-Verzeichnis von Apache.
- Passt die Datei `ost-config.php` automatisch an, um die Verbindung zur Datenbank herzustellen:
  - Datenbank-Host, -Name, -Benutzer und -Passwort werden eingetragen.  

- **Installation von Apache und PHP**  
  ```bash
  sudo yum install -y httpd php php-mysqli wget unzip
  ```  
  **Erklärung:** Dieser Befehl installiert den Apache-Webserver, PHP und zusätzliche PHP-Module, die für osTicket erforderlich sind.

- **Herunterladen von osTicket**  
  ```bash
  wget -O /tmp/osTicket.zip https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip
  ```  
  **Erklärung:** osTicket wird von der offiziellen GitHub-Seite heruntergeladen und lokal gespeichert.

#### Datenbank-Initialisierung (`db-init.sh`)
- Installiert MariaDB und setzt die Basis-Konfiguration.
- Erstellt die osTicket-Datenbank und einen dedizierten Benutzer für die Anwendung.
- Aktiviert Remote-Zugriff auf die Datenbank und setzt entsprechende Berechtigungen.

- **Erstellung der Datenbank und Benutzer**  
  ```sql
  CREATE DATABASE osticket;
  CREATE USER 'osticketuser'@'%' IDENTIFIED BY 'securepassword';
  GRANT ALL PRIVILEGES ON osticket.* TO 'osticketuser'@'%';
  FLUSH PRIVILEGES;
  ```  
  **Erklärung:** Es wird eine neue Datenbank `osticket` erstellt, und der Benutzer `osticketuser` erhält vollständige Zugriffsrechte.

#### Deploy-Skript (`deploy.sh`)
- Installiert Terraform, initialisiert das Projekt und wendet die Konfiguration an.
- Ermittelt die IP-Adressen der Instanzen und übergibt die private Datenbank-IP an das Webserver-Setup.
- Gibt die öffentliche IP-Adresse des Webservers aus, um den Zugriff über den Browser zu ermöglichen. 

- **Initialisierung von Terraform**  
  ```bash
  terraform init
  ```  
  **Erklärung:** Dieser Befehl initialisiert das Terraform-Projekt, lädt benötigte Plugins und überprüft die Konfiguration.

- **Timer für Statusanzeige**  
  ```bash
  for ((elapsed_seconds=0; elapsed_seconds<=total_seconds; elapsed_seconds+=1)); do
    echo -ne "${percent}% [${bar}]
"
    sleep 1
  done
  ```  
  **Erklärung:** Dieser Timer zeigt den Fortschritt der Installation an und wartet, bis die Konfiguration abgeschlossen ist.

### 2.2 Begründung für Terraform statt Cloud-Init

Terraform bietet eine leistungsstarke und deklarative Methode zur Verwaltung der gesamten Infrastruktur. Dies ermöglicht eine konsistente Bereitstellung und Verwaltung von Ressourcen wie EC2-Instanzen, Sicherheitsgruppen und Schlüsselpaaren. Vorteile im Vergleich zu Cloud-Init:

1. **Wiederholbarkeit und Konsistenz:** Infrastruktur als Code sorgt für konsistente Deployments in unterschiedlichen Umgebungen.
2. **Zustandsmanagement:** Terraform speichert den Infrastrukturzustand, was die Nachverfolgung von Änderungen erleichtert.
3. **Komplexitätsmanagement:** Terraform eignet sich hervorragend für die Verwaltung mehrerer Ressourcen.
4. **Erweiterbarkeit:** Infrastruktur kann strukturiert erweitert werden, z. B. durch Hinzufügen von EC2-Instanzen oder S3-Buckets.
5. **Integration:** Terraform lässt sich problemlos in CI/CD-Pipelines integrieren.

Cloud-Init eignet sich eher für die Initialkonfiguration von Instanzen, nicht jedoch für das umfassende Infrastrukturmanagement.

## 3. Anleitung

### Voraussetzungen

- AWS CLI ist installiert und konfiguriert.
- Eine Linux-Maschine ist verfügbar und mit den notwendigen Berechtigungen ausgestattet.
- `git` ist installiert.

### Schritte

1. Klone das Repository:
   ```bash
   git clone https://github.com/levinfritz/M346-Levin-Noe-Janis.git
   cd M346-Levin-Noe-Janis/Konfiguration
   ```
2. Mache das `deploy.sh`-Skript ausführbar und starte die Installation:
   ```bash
   chmod u+x deploy.sh
   ./deploy.sh
   ```
3. Greife auf den Webserver zu: Öffne die IP-Adresse des Webservers in deinem Browser.
4. Klicke auf **Continue**.
5. Fülle die Felder aus:
   - **MySQL Hostname:** `<DB_SERVER_PUBLIC_IP>`
   - **MySQL Database:** `osticket`
   - **MySQL Username:** `osticketuser`
   - **MySQL Password:** `securepassword`
   Klicke anschließend auf **Install Now**.
6. Mögliche Lösung:
   ![Installation](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Bilder/Installation_OS-Ticket.png)

## 4. Testfälle

### Testfall 1: Webserver erreichbar

- **Datum:** 09.12.2024  
- **Testperson:** Levin Fritz  
- **Ergebnis:** Der Webserver war zunächst nicht erreichbar. Nach Anpassungen im `deploy.sh`-Skript wurde eine Überprüfung eingebaut, um sicherzustellen, dass die Installation abgeschlossen ist.

![Fehlerbehebung](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Bilder/FehlerWebserver.png)

### Testfall 2: Verbindung zur Datenbank

- **Datum:** 09.12.2024  
- **Testperson:** Levin Fritz  
- **Ergebnis:** Die Datenbankverbindung wurde erfolgreich getestet. Benutzer und Datenbank wurden korrekt eingerichtet.

![Erfolgreiche Installation](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Bilder/Erfolgreiche%20Installation.png)

## 5. Reflexion

### Levin Fritz
Ich konnte viel über die Automatisierung von Cloud-Infrastrukturen lernen. Besonders das Debuggen war lehrreich. Insgesamt hat das Projekt mein Verständnis für AWS und Automatisierung deutlich verbessert.

### Noé Messmer
Das Projekt war sehr spannend, und ich konnte mein Wissen über die Cloud und Linux-Administration erweitern. Für das nächste Projekt würde ich die Kommunikation und Aufgabenteilung in der Gruppe verbessern.

### Janis Mora
Ich fand das Projekt eine gute praktische Übung. Die Verbindung von Theorie und Praxis war sehr lehrreich. Für zukünftige Projekte sollten wir die Planungsphase intensiver gestalten.
