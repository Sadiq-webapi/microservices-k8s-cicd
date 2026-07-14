# Monitoring

## Install Prometheus & Grafana

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
kubectl create namespace monitoring
helm install kube-prom-stack prometheus-community/kube-prometheus-stack --namespace monitoring
```

Access Grafana

```bash
kubectl port-forward svc/kube-prom-stack-grafana -n monitoring 3000:80
```

Open

```
http://localhost:3000
```

## Install Loki

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm install loki grafana/loki-stack --namespace monitoring --set promtail.enabled=true
```