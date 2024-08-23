output "instance_public_ip" {
  value = aws_instance.my_web_server.public_ip
}
