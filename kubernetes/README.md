```
> tree .
.
├── backend
│   ├── backend-config.yaml
│   ├── backend-deployment.yaml
│   ├── backend-ingress-https.yaml
│   ├── backend-ingress.yaml
│   ├── backend-secret.yaml
│   ├── backend-service.yaml
│   └── backend-serviceaccount.yaml
├── cluster
│   ├── elb-controller-serviceaccount.yaml
│   ├── namespaces.yaml
│   ├── networkpolicy.yaml
│   └── quotas.yaml
├── provisioner
│   ├── provisioner-config.yaml
│   ├── provisioner-deployment.yaml
│   ├── provisioner-secret.yaml
│   ├── provisioner-service.yaml
│   └── serviceaccounts.yaml
└── README.md

4 directories, 17 files
```

```
kubectl apply -f cluster/namespaces.yaml
kubectl apply -f cluster/elb-controller-serviceaccount.yaml
kubectl apply -f cluster/networkpolicy.yaml
kubectl apply -f cluster/quotas.yaml
```

```
kubectl apply -f backend/backend-serviceaccount.yaml
kubectl apply -f backend/backend-secret.yaml
kubectl apply -f backend/backend-config.yaml
kubectl apply -f backend/backend-deployment.yaml
kubectl apply -f backend/backend-service.yaml
kubectl apply -f backend/backend-ingress-https.yaml
```

```
kubectl apply -f provisioner/provisioner-secret.yaml
kubectl apply -f provisioner/provisioner-config.yaml
kubectl apply -f provisioner/provisioner-deployment.yaml
kubectl apply -f provisioner/provisioner-service.yaml
kubectl apply -f provisioner/serviceaccounts.yaml
```
