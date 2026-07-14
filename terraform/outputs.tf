output "instance_id" {
  value = aws_instance.minikube.id
}

output "public_ip" {
  value = aws_instance.minikube.public_ip
}

output "public_dns" {
  value = aws_instance.minikube.public_dns
}

output "ssh_command" {
  value = "ssh -i sadiq.pem ec2-user@${aws_instance.minikube.public_ip}"
}

output "vpc_id" {
  value = aws_vpc.minikube_vpc.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "security_group" {
  value = aws_security_group.minikube_sg.id
}