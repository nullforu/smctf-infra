<!-- ```
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
-->

```
aws eks update-kubeconfig --region ap-northeast-2 --name smctf
```

## SMCTF Helm

```shell
helm install smctf ./kubernetes
helm install smctf-observability ./kubernetes-observability
```

## AWS Load Balancer Controller

```shell
helm repo add eks https://aws.github.io/eks-charts
helm repo update eks

VPC_ID=$(terraform output -raw vpc_id)
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=smctf \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller \
  --set nodeSelector.role=backend \
  --set vpcId="$VPC_ID" \
  --set region=ap-northeast-2
```

## Observability

Logging (Fluent Bit + CloudWatch) and monitoring (ServiceMonitor CRs) are now managed by the
`kubernetes-observability` Helm chart in this repo.
