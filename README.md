# Infrastructure for SMCTF (Terraform IaC and Kubernetes Helm chart)

See [SMCTF Docs](https://github.com/nullforu/smctf-docs) for more information about SMCTF and how to use this repository.

## AWS Architecture Diagram

![AWS Architecture Diagram](./assets/aws.drawio.png)

## Kubernetes(EKS) Architecture Diagram

![Kubernetes Architecture Diagram](./assets/k8s.drawio.png)

## Logging (Fluent Bit + CloudWatch Logs)

This repository includes a Fluent Bit DaemonSet that tails Kubernetes container logs (stdout/stderr from `/var/log/containers/*.log`) and ships them to CloudWatch Logs.

### What Gets Shipped
- Backend and container-provisioner logs are collected from stdout/stderr.
- JSON logs are parsed in Fluent Bit and enriched with Kubernetes metadata.

### Required Setup
1. Apply Terraform so the Fluent Bit IRSA role and CloudWatch Logs policy are created.
2. Set the Fluent Bit IRSA role ARN in Helm values:
   - `fluentbit.serviceAccount.annotations.eks.amazonaws.com/role-arn`
   - You can use the Terraform output `irsa_fluentbit_role_arn`.

### Helm Values (Defaults)
These defaults live in the chart values:
- `fluentbit.env.AWS_REGION`: `ap-northeast-2`
- `fluentbit.env.LOG_GROUP_NAME`: `/aws/eks/smctf/logs`
- `fluentbit.env.LOG_STREAM_PREFIX`: `k8s`
- `fluentbit.namespace`: `logging` (namespace is created by the chart)

### Install/Upgrade
Example:
```bash
helm upgrade --install smctf /Users/workspace5/smctf-infra/kubernetes \
  --set fluentbit.serviceAccount.annotations.eks.amazonaws.com/role-arn=arn:aws:iam::<ACCOUNT_ID>:role/<IRSA_ROLE_NAME>
```

### Notes
- If you want a different log group name or region, override `fluentbit.env.LOG_GROUP_NAME` and `fluentbit.env.AWS_REGION`.
- CloudWatch log streams are created with the prefix from `fluentbit.env.LOG_STREAM_PREFIX`.
