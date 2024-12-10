provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "osTicket-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "web_sg" {
  name        = "osTicket-Web-SG"
  description = "Allow HTTP and HTTPS traffic"

  ingress {
    from_port   = 80
    to_port     = 80
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
  ami           = "ami-0c94855ba95c71c99" # Ubuntu Server
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install -y apache2 php php-mysql unzip
                cd /var/www/html
                wget https://github.com/osTicket/osTicket/releases/download/v1.18.1/osTicket-v1.18.1.zip
                unzip osTicket-v1.18.1.zip -d /var/www/html
                sudo systemctl restart apache2
                EOF
}

resource "aws_instance" "db_server" {
  ami           = "ami-0c94855ba95c71c99" # Ubuntu Server
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name

  user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install -y mysql-server
                sudo mysql_secure_installation
                EOF
}
