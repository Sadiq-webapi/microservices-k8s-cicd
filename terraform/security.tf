#############################
# Security Group
#############################

resource "aws_security_group" "minikube_sg" {

  name        = "minikube-security-group"
  description = "Security Group for Minikube EC2"
  vpc_id      = aws_vpc.minikube_vpc.id

  ####################################
  # SSH
  ####################################
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ####################################
  # HTTP
  ####################################
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ####################################
  # HTTPS
  ####################################
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ####################################
  # Kubernetes API
  ####################################
  ingress {
    description = "Kubernetes API"
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ####################################
  # Minikube Dashboard
  ####################################
  ingress {
    description = "Minikube Dashboard"
    from_port   = 30000
    to_port     = 30000
    protocol    = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ####################################
  # Kubernetes NodePort Range
  ####################################
  ingress {
    description = "NodePort Services"

    from_port = 30000
    to_port   = 32767

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  ####################################
  # Outbound Traffic
  ####################################
  egress {

    from_port = 0
    to_port   = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "minikube-security-group"
  }

}