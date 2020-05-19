# https://kan.sh

## About

kan.sh is a simple, beatiful Kanban board for personal projects and small
teams. It provides opt-in features that keep user experience lean, and a 
websocket-based backend that enables sharing boards with other users and 
allows real-time, concurrent editing. The frontend is a 
single-page-application built with Vue.js, and served from an s3 bucket
behind a Cloudfront Distribution. The backend is built with 
Serverless Framework. Authentication is handled by AWS Cognito, and user
requests are verified with JWT tokens. Application wide infrastructure is 
managed with Terraform, and all resources are hosted on AWS. Kan.sh is 
deployed using a multi-environment CI/CD pipeline implemented with Github
Actions. 


## Development/ Installation

### 