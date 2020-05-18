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
\"region\":\"ap-southeast-1\"\
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

# sudo npm install -g serverless

# deploy frontend

cd frontend
amplify init . --yes --amplify {"envName": "prod"}
npm ci
npm run build:$environment
aws s3 sync --delete ./dist s3://$(cd ../terraform && terraform output bucket_$environment)

# deploy backend

cd ../backend

serverless deploy --stage $environment