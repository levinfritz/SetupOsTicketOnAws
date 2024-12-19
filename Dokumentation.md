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
  Definiert die gesamte Infrastruktur auf AWS, einschliesslich EC2-Instanzen, Sicherheitsgruppen und Schüsselpaaren.

- **[`web-init.sh`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/web-init.sh):**  
  Installiert und konfiguriert osTicket auf einer Apache-Instanz. Die Verbindung zur Datenbank wird automatisch hergestellt.

- **[`db-init.sh`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/db-init.sh):**  
  Installiert und konfiguriert eine MariaDB-Instanz für osTicket. Es werden Datenbankname, Benutzer und Passwörter erstellt.

- **[`deploy.sh`](https://github.com/levinfritz/M346-Levin-Noe-Janis/blob/main/Konfiguration/deploy.sh):**  
  Automatisiert die Installation von Terraform, führt die Terraform-Skripte aus und stellt sicher, dass die Datenbank-IP in die Webserver-Konfiguration eingefügt wird.



### 2.1 Erklärung des Codes

#### Terraform (`main.tf`)

- **Zwei EC2-Instanzen werden erstellt:**
  ```hcl
  resource "aws_instance" "web_server" {
    ami           = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name      = aws_key_pair.deployer_key.key_name
    security_groups = [aws_security_group.web_sg.name]
    user_data = file("web-init.sh")
    tags = {
      Name = "WebServer"
    }
  }

  resource "aws_instance" "db_server" {
    ami           = "ami-0c02fb55956c7d316"
    instance_type = "t2.micro"
    key_name      = aws_key_pair.deployer_key.key_name
    security_groups = [aws_security_group.db_sg.name]
    user_data = file("db-init.sh")
    tags = {
      Name = "DBServer"
    }
  }
  ```
  **Erklärung:** Es werden zwei EC2-Instanzen bereitgestellt, eine für den Webserver und eine für die Datenbank.

- **Sicherheitsgruppen für Zugriffskontrolle:**
  ```hcl
  resource "aws_security_group" "web_sg" {
    ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  resource "aws_security_group" "db_sg" {
    ingress {
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  ```
  **Erklärung:** Die Sicherheitsgruppen regeln, dass der Webserver HTTP-Zugriff erlaubt und die Datenbank nur über MySQL erreichbar ist.

- **Outputs der IP-Adressen:**
  ```hcl
  output "web_server_public_ip" {
    value = aws_instance.web_server.public_ip
  }

  output "db_server_public_ip" {
    value = aws_instance.db_server.public_ip
  }
  ```
  **Erklärung:** Exportiert die öffentlichen und privaten IP-Adressen, um sie im `deploy.sh`-Skript zu verwenden.

---

#### Webserver-Initialisierung (`web-init.sh`)

- **Installation von Apache und PHP:**
  ```bash
  sudo yum install -y httpd php php-mysqli wget unzip
  ```
  **Erklärung:** Apache und PHP werden installiert, um den Webserver und die Anwendung osTicket bereitzustellen.

- **Herunterladen und Entpacken von osTicket:**
  ```bash
  wget -O /tmp/osTicket.zip https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip
  sudo unzip -o /tmp/osTicket.zip -d /var/www/html/osticket
  ```
  **Erklärung:** osTicket wird von GitHub heruntergeladen und in das Apache-Webverzeichnis entpackt.

- **Konfiguration von Apache:**
  ```bash
  sudo sed -i "s|DocumentRoot "/var/www/html"|DocumentRoot "/var/www/html"|" /etc/httpd/conf/httpd.conf
  ```
  **Erklärung:** Apache wird so konfiguriert, dass es das korrekte Webroot für osTicket verwendet.

---

#### Datenbank-Initialisierung (`db-init.sh`)

- **Installation von MariaDB:**
  ```bash
  sudo yum install -y mariadb-server
  ```
  **Erklärung:** Installiert MariaDB, das als Datenbank für osTicket verwendet wird.

- **Datenbank und Benutzer einrichten:**
  ```sql
  CREATE DATABASE osticket;
  CREATE USER 'osticketuser'@'%' IDENTIFIED BY 'securepassword';
  GRANT ALL PRIVILEGES ON osticket.* TO 'osticketuser'@'%';
  FLUSH PRIVILEGES;
  ```
  **Erklärung:** Erstellt die Datenbank `osticket` und den Benutzer `osticketuser` mit vollständigen Zugriffsrechten.

---

#### Deploy-Skript (`deploy.sh`)

- **Terraform initialisieren und anwenden:**
  ```bash
  terraform init
  terraform apply -auto-approve
  ```
  **Erklärung:** Initialisiert Terraform und wendet die Konfiguration an, um die Infrastruktur zu erstellen.

- **Wartezeit während der Installation:**
  ```bash
  total_minutes=4
  total_seconds=$((total_minutes * 60)) 
  bar_length=20                        
  for ((elapsed_seconds=0; elapsed_seconds<=total_seconds; elapsed_seconds+=1)); do
    percent=$((elapsed_seconds * 100 / total_seconds))
    filled_length=$((percent * bar_length / 100))

    bar=$(printf "%-${bar_length}s" "=" | tr ' ' '=')
    arrow=">"
    bar="[${bar:0:filled_length}${arrow}${bar:filled_length:bar_length}]"
    
    echo -ne "${percent}% ${bar}\r"
    
    sleep 1
  done
  ```
  **Erklärung:** Wartet mit einem Fortschrittsbalken, bis die Installation abgeschlossen ist.

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
   Klicke anschliessend auf **Install Now**.
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
