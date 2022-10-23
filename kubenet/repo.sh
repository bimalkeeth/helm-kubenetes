#!/bin/bash
export LC_CTYPE=C

set -e

#create random string
RANDOM_STRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 8 | tr '[:upper:]' '[:lower:]' | head -n 1 )

DEFAULT_REGION="ap-southeast-2"
AWS_REGION="${AWS_REGION}:-${DEFAULT_REGION}"

#create s3 bucket
if [ "$AWS_REGION" == "ap-southeast-2" ] ; then
  aws s3api create-bucket --bucket helm-${RANDOM_STRING}
else
  aws s3api create-bucket --bucket helm-${RANDOM_STRING} --region $AWS_REGION --create-bucket-configurarion LocationConstraint=${AWS_REGION}
fi

#install helm plugin
helm plugin install https://github.com/hypnoglow/helm-s3.git

#initialize s3 bucket
helm s3 init s3://helm-${RANDOM_STRING}/charts

#add repository to the helm
helm repo add my-charts s3://helm-${RANDOM_STRING}/charts