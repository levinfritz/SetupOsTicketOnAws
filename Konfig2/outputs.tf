output "web_server_ip" {
  value = aws_instance.web_server.public_ip
}

output "db_server_ip" {
  value = aws_instance.db_server.public_ip
}
