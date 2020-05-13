#!/bin/bash

while getopts e: flag
do
    case "${flag}" in
        e) environment=${OPTARG};;
    esac
done

echo "Deploying to $environment...";

# deploy frontend

cd frontend

npm run build:$environment

aws s3 sync --delete ./dist s3://$(cd ../terraform && terraform output bucket_$environment)

# deploy backend

cd ../backend

serverless deploy --stage $environment