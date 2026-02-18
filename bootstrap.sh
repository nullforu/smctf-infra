#!/bin/bash

RANDOM_PREFIX=$(openssl rand -hex 2)
AWS_REGION=ap-northeast-2
BUCKET_NAME=terraform-$RANDOM_PREFIX
DDB_TABLE_NAME=terraform-$RANDOM_PREFIX

aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $AWS_REGION \
  --create-bucket-configuration LocationConstraint=$AWS_REGION

aws dynamodb create-table \
  --table-name $DDB_TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $AWS_REGION

echo "Bucket Name: $BUCKET_NAME"
echo "DynamoDB Table Name: $DDB_TABLE_NAME"
