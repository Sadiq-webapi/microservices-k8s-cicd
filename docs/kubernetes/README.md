# Kubernetes Deployment

Enable ingress

```bash
minikube addons enable ingress
minikube addons enable ingress-dns
```

Deploy

```bash
kubectl apply -f infra/k8s/
```

Verify

```bash
kubectl get all -n microservices
```

Rollout

```bash
kubectl rollout status deployment/user-service -n microservices
kubectl rollout status deployment/order-service -n microservices
kubectl rollout status deployment/payment-service -n microservices
kubectl rollout status deployment/notification-service -n microservices
```