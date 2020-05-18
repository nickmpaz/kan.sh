#!/bin/bash

while getopts e: flag
do
    case "${flag}" in
        e) branch=${OPTARG};;
    esac
done

case $branch in
  master) environment="prod";;
  develop) environment="dev";;
esac

echo "Deploying to $environment.";

# # install and initialize amplify

# sudo npm install -g @aws-amplify/cli

# mkdir ~/.aws && touch ~/.aws/credentials && touch ~/.aws/config

# cd frontend

# export VUECONFIG="{\
# \"SourceDir\":\"src\",\
# \"DistributionDir\":\"dist\",\
# \"BuildCommand\":\"npm run-script build\",\
# \"StartCommand\":\"npm run-script serve\"\
# }"

# export AWSCLOUDFORMATIONCONFIG="{\
# \"configLevel\":\"project\",\
# \"useProfile\":false,\
# \"profileName\":\"default\",\
# \"accessKeyId\":\"$AWS_ACCESS_KEY_ID\",\
# \"secretAccessKey\":\"$AWS_SECRET_ACCESS_KEY\",\
# \"region\":\"us-east-1\"\
# }"

# export FRONTEND="{\
# \"frontend\":\"javascript\",\
# \"framework\":\"vue\",\
# \"config\":$VUECONFIG\
# }"

# export AMPLIFY="{\
# \"projectName\":\"myproject\",\
# \"envName\":\"prod\",\
# \"defaultEditor\":\"vscode\"\
# }"

# export PROVIDERS="{\
# \"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
# }"

# amplify init \
# --amplify $AMPLIFY \
# --frontend $FRONTEND \
# --providers $PROVIDERS \
# --yes

# cd ..

# # initialize terraform 

# cd terraform 

# terraform init

# cd ..

# # install serverless and plugins 

# cd backend

# npm ci

# ./node_modules/.bin/serverless plugin install --name serverless-python-requirements

# cd ..

# # deploy frontend

# cd frontend

# npm ci

# npm run build:$environment

# aws s3 sync --delete ./dist s3://$(cd ../terraform && terraform output bucket_$environment)

# cd ..

# # deploy backend

# cd backend

# ./node_modules/.bin/serverless deploy --stage $environment

# cd ..