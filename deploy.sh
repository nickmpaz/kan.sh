#!/bin/bash

while getopts e: flag
do
    case "${flag}" in
        e) environment=${OPTARG};;
    esac
done
echo "Deploying to $environment.";

# deploy frontend

echo "Deploying frontend."
cd frontend
echo "Installing dependencies."
npm ci
echo "Installing Amplify CLI."
npm install -g @aws-amplify/cli
amplify status
echo "Building frontend."
npm run build:$environment
echo "Syncing frontend to s3 bucket."
aws s3 sync --delete ./dist s3://$(cd ../terraform && terraform output bucket_$environment)

# deploy backend

cd ../backend

serverless deploy --stage $environment