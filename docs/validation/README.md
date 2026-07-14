# Full Pipeline Validation

## Step 14: Run a Full Pipeline Validation

### 1. Push a Feature Branch

```bash
git checkout -b feature/new-feature

git add .

git commit -m "Add new feature"

git push origin feature/new-feature
```

---

### 2. Create a Pull Request

- Open GitHub.
- Create a Pull Request.
- Review the changes.
- Merge the Pull Request into the `main` branch.

---

### 3. Verify Jenkins Pipeline

Confirm the following stages complete successfully:

- ✅ Checkout
- ✅ Maven Build
- ✅ Unit Tests
- ✅ Docker Build
- ✅ ECR Login
- ✅ Docker Push
- ✅ Kubernetes Deployment

---

### 4. Verify Amazon ECR

Confirm the latest Docker images are pushed successfully.

```bash
aws ecr describe-images --repository-name user-service --region ap-south-2

aws ecr describe-images --repository-name order-service --region ap-south-2

aws ecr describe-images --repository-name payment-service --region ap-south-2

aws ecr describe-images --repository-name notification-service --region ap-south-2
```

---

### 5. Verify Kubernetes Deployments

```bash
kubectl get deployments -n microservices

kubectl get pods -n microservices

kubectl get services -n microservices
```

---

### 6. Verify Rolling Updates

```bash
kubectl rollout status deployment/user-service -n microservices

kubectl rollout status deployment/order-service -n microservices

kubectl rollout status deployment/payment-service -n microservices

kubectl rollout status deployment/notification-service -n microservices
```

---

### 7. Verify Monitoring

Open Grafana:

```
http://localhost:3000
```

Confirm:

- Metrics are visible.
- Dashboards are loading.
- Prometheus targets are UP.

---

### 8. Verify Logging

Confirm Loki receives logs from all microservices.

Search for application logs in Grafana Explore.

---

### 9. Verify Notifications

Confirm:

- Slack notifications are received.
- Email notifications are delivered.
- Build status is reported correctly.

---

## Validation Checklist

- ✅ Feature branch created
- ✅ Pull Request merged
- ✅ Jenkins pipeline successful
- ✅ Docker images pushed to Amazon ECR
- ✅ Kubernetes deployments updated
- ✅ Pods healthy
- ✅ Grafana dashboards working
- ✅ Loki logs available
- ✅ Slack notifications received
- ✅ Email notifications received

---

## Pipeline Validation Complete

The complete CI/CD pipeline has been successfully validated end-to-end.