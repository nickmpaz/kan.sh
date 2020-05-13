# Container image that runs your code
FROM alpine:3.10

COPY . /app

CMD app/deploy.sh -e dev