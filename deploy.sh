#!/bin/bash

while getopts e: flag
do
    case "${flag}" in
        e) environment=${OPTARG};;
    esac
done
echo "Deploying to $environment.";

# install and initialize amplify

sudo npm install -g @aws-amplify/cli

mkdir ~/.aws && touch ~/.aws/credentials && touch ~/.aws/config

cd frontend

export VUECONFIG="{\
\"SourceDir\":\"src\",\
\"DistributionDir\":\"dist\",\
\"BuildCommand\":\"npm run-script build\",\
\"StartCommand\":\"npm run-script serve\"\
}"

export AWSCLOUDFORMATIONCONFIG="{\
\"configLevel\":\"project\",\
\"useProfile\":false,\
\"profileName\":\"default\",\
\"accessKeyId\":\"$AWS_ACCESS_KEY_ID\",\
\"secretAccessKey\":\"$AWS_SECRET_ACCESS_KEY\",\
\"region\":\"us-east-1\"\
}"

export FRONTEND="{\
\"frontend\":\"javascript\",\
\"framework\":\"vue\",\
\"config\":$VUECONFIG\
}"

export AMPLIFY="{\
\"projectName\":\"myproject\",\
\"envName\":\"prod\",\
\"defaultEditor\":\"vscode\"\
}"

export PROVIDERS="{\
\"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
}"

amplify init \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--yes

cd ..

# initialize terraform 

cd terraform 

terraform init

cd ..

# install serverless and plugins

sudo npm install -g serverless

cd backend

sudo serverless plugin install -n serverless-python-requirements

cd ..

# deploy frontend

cd frontend

npm ci

npm run build:$environment

aws s3 sync --delete ./dist s3://$(cd ../terraform && terraform output bucket_$environment)

cd ..

# deploy backend

cd backend

serverless deploy --stage $environment

cd ..