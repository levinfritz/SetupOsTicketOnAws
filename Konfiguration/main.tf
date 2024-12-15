provider "aws" {
  region = "us-east-1"
}

# Schlüssel für die SSH-Verbindung erstellen
resource "tls_private_key" "deployer_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "local_file" "private_key" {
  filename = "deployer_key.pem"
  content  = tls_private_key.deployer_key.private_key_pem
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = tls_private_key.deployer_key.public_key_openssh
}

# Sicherheitsgruppe für den Webserver
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port   = 443
  to_port     = 443
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

resource "aws_instance" "web_server" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  security_groups = [aws_security_group.web_sg.name]

  # Aktualisiertes web-init.sh
  user_data = file("web-init.sh")

  tags = {
    Name = "WebServer"
  }
}


# Sicherheitsgruppe für die Datenbank
resource "aws_security_group" "db_sg" {
  name_prefix = "db-sg-"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

# Datenbankserver-Instanz
resource "aws_instance" "db_server" {
  ami           = "ami-0c02fb55956c7d316" # Ubuntu 20.04 LTS
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  security_groups = [aws_security_group.db_sg.name]

  user_data = file("db-init.sh")
  tags = {
    Name = "DBServer"
  }
}

# Ausgaben für die IP-Adressen
output "web_server_public_ip" {
  value = aws_instance.web_server.public_ip
}

output "db_server_private_ip" {
  value = aws_instance.db_server.private_ip
}
