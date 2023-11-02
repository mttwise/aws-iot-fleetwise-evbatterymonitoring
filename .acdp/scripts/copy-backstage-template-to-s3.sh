#!/bin/bash

#Navigate to the .acdp dir
cd "$(dirname "$0")"
cd ..

base_directory=$PWD
aws_account=`aws sts get-caller-identity --query "Account" --output text`
aws_region=${AWS_REGION:-$(aws configure get region --output text)}

if [[ -z "$aws_region" ]]; then
    echo "*************************"
    echo "Unable to identify AWS_REGION, please add AWS_REGION to environment variables"
    echo "*************************"
    exit 1
fi

bucket_name=${CMS_RESOURCE_BUCKET:-"${aws_account}-cms-resources-${aws_region}"}
solution_version=${CMS_SOLUTION_VERSION:-"v0.0.0"}

s3_templates_base_prefix="${solution_version}/backstage/templates"

module_name="test-service"

s3_key="${s3_templates_base_prefix}/${module_name}.yaml"

aws s3api put-object \
    --bucket ${bucket_name} \
    --key "${s3_key}" \
    --body ${base_directory}/template.yaml \
    --expected-bucket-owner ${aws_account} \
    > /dev/null #Only output errors to prevent noise

echo Module "'${module_name}'": Uploaded backstage template to "'s3://${bucket_name}/${s3_key}'"
