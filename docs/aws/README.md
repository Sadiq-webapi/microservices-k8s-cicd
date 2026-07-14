# AWS Setup

## Step 1: Fix IAM Permissions

Attach:

- AmazonEC2ContainerRegistryFullAccess

## Step 2: Create ECR Repositories

```bash
aws ecr create-repository --repository-name user-service --region ap-south-2
aws ecr create-repository --repository-name order-service --region ap-south-2
aws ecr create-repository --repository-name payment-service --region ap-south-2
aws ecr create-repository --repository-name notification-service --region ap-south-2
```

Verify:

```bash
aws ecr describe-repositories --region ap-south-2
```

Verify login:

```bash
aws sts get-caller-identity
```

Docker Login:

```bash
aws ecr get-login-password --region ap-south-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.ap-south-2.amazonaws.com
```