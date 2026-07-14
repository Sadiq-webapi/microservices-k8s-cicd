# Terraform Minikube

This project creates:

- VPC
- Public Subnet
- Internet Gateway
- Route Table
- Security Group
- EC2 Instance (Amazon Linux 2023)
- Docker
- kubectl
- Minikube
- Helm

## Deploy

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

After deployment:

```bash
ssh -i sadiq.pem ec2-user@<PUBLIC_IP>
```

Check Minikube:

```bash
minikube status
kubectl get nodes
```