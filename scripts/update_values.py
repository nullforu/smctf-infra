#!/usr/bin/env python3

import argparse
import json
import subprocess
import sys
from pathlib import Path

import yaml


def load_tf_outputs(terraform_dir: Path) -> dict:
    try:
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=str(terraform_dir),
            check=True,
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        print("Error: terraform CLI not found in PATH.", file=sys.stderr)
        sys.exit(1)
    except subprocess.CalledProcessError as exc:
        print("Error: terraform output -json failed.", file=sys.stderr)
        if exc.stdout:
            print(exc.stdout, file=sys.stderr)
        if exc.stderr:
            print(exc.stderr, file=sys.stderr)
        sys.exit(exc.returncode)

    raw = json.loads(result.stdout)
    outputs = {}
    for key, payload in raw.items():
        outputs[key] = payload.get("value")
    return outputs


def set_path(doc: dict, path: list[str], value):
    cur = doc
    for key in path[:-1]:
        if key not in cur or cur[key] is None:
            cur[key] = {}
        cur = cur[key]
    cur[path[-1]] = value


def apply_updates(values_path: Path, updates: list[tuple[list[str], object]]):
    data = yaml.safe_load(values_path.read_text())
    if data is None:
        data = {}

    for path, value in updates:
        set_path(data, path, value)

    values_path.write_text(
        yaml.safe_dump(
            data,
            sort_keys=False,
            default_flow_style=False,
        )
    )


def main():
    parser = argparse.ArgumentParser(
        description="Update Helm values.yaml files from Terraform outputs."
    )
    parser.add_argument(
        "--terraform-dir",
        default=".",
        help="Path to the Terraform root directory (default: current directory)",
    )
    parser.add_argument(
        "--values-dir",
        default=".",
        help="Repository root containing kubernetes/ and kubernetes-observability/",
    )
    parser.add_argument(
        "--allow-missing",
        action="store_true",
        help="Skip updates when a Terraform output is missing.",
    )
    args = parser.parse_args()

    terraform_dir = Path(args.terraform_dir).resolve()
    values_dir = Path(args.values_dir).resolve()

    outputs = load_tf_outputs(terraform_dir)

    def get_output(name: str):
        if name not in outputs:
            if args.allow_missing:
                return None
            print(f"Error: missing terraform output '{name}'.", file=sys.stderr)
            sys.exit(1)
        return outputs[name]

    ecr_urls = get_output("ecr_repository_urls") or {}

    def ecr_repo(name: str):
        if name not in ecr_urls:
            if args.allow_missing:
                return None
            print(f"Error: missing ecr_repository_urls['{name}'].", file=sys.stderr)
            sys.exit(1)
        return ecr_urls[name]

    kube_values = values_dir / "kubernetes" / "values.yaml"
    obs_values = values_dir / "kubernetes-observability" / "values.yaml"

    kube_updates = [
        (["elbController", "serviceAccount", "annotations", "eks.amazonaws.com/role-arn"], get_output("irsa_alb_role_arn")),
        (["backend", "serviceAccount", "annotations", "eks.amazonaws.com/role-arn"], get_output("irsa_backend_role_arn")),
        (["provisioner", "serviceAccount", "annotations", "eks.amazonaws.com/role-arn"], get_output("irsa_container_provisioner_role_arn")),
        (["backend", "config", "DB_HOST"], get_output("rds_endpoint")),
        (["backend", "config", "REDIS_ADDR"], get_output("redis_primary_endpoint")),
        (["backend", "config", "S3_BUCKET"], get_output("s3_challenge_bucket")),
        (["backend", "ingress", "securityGroupId"], get_output("alb_security_group_id")),
        (["provisioner", "config", "DDB_STACK_TABLE"], get_output("dynamodb_table_name")),
        (["backend", "deployment", "image", "repository"], ecr_repo("backend")),
        (["provisioner", "deployment", "image", "repository"], ecr_repo("container-provisioner")),
    ]

    if kube_values.exists():
        apply_updates(kube_values, [(p, v) for p, v in kube_updates if v is not None])
    else:
        print(f"Warning: missing {kube_values}", file=sys.stderr)

    if obs_values.exists():
        obs_updates = [
            (["fluentbit", "serviceAccount", "annotations", "eks.amazonaws.com/role-arn"], get_output("irsa_fluentbit_role_arn")),
        ]
        apply_updates(obs_values, [(p, v) for p, v in obs_updates if v is not None])
    else:
        print(f"Warning: missing {obs_values}", file=sys.stderr)


if __name__ == "__main__":
    main()
