#############################################
# Get Latest Amazon Linux 2023 AMI
#############################################

data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#############################################
# EC2 Instance
#############################################

resource "aws_instance" "minikube" {

  ami = data.aws_ami.amazon_linux.id

  instance_type = var.instance_type

  key_name = var.key_name

  subnet_id = aws_subnet.public_subnet.id

  vpc_security_group_ids = [
    aws_security_group.minikube_sg.id
  ]

  associate_public_ip_address = true

  user_data = file("${path.module}/user-data.sh")

  root_block_device {

    volume_size = 30

    volume_type = "gp3"

    delete_on_termination = true
  }

  tags = {
    Name = "Minikube-Server"
  }

}