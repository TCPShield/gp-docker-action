#!/bin/sh

DOCKER_USERNAME=$1
DOCKER_TOKEN=$2
DOCKER_IMAGE_TAG=$3
EXTRACT_TAG_FROM_GIT_REF=$4
DOCKERFILE=$5
BUILD_CONTEXT=$6
PULL_IMAGE=$7
CUSTOM_DOCKER_BUILD_ARGS=$8

git config --global url."https://${DOCKER_USERNAME}:${DOCKER_TOKEN}@github.com/".insteadOf "https://github.com/"

if [ $EXTRACT_TAG_FROM_GIT_REF == "true" ]; then
  DOCKER_IMAGE_TAG=$(echo ${GITHUB_REF} | sed -e "s/refs\/tags\///g")
fi

DOCKER_IMAGE_NAME=$(echo ghcr.io/${GITHUB_REPOSITORY} | tr '[:upper:]' '[:lower:]')
DOCKER_IMAGE_NAME_WITH_TAG=$(echo ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_TAG} | tr '[:upper:]' '[:lower:]')

docker login -u ${DOCKER_USERNAME} -p ${DOCKER_TOKEN} ghcr.io

if [ $PULL_IMAGE == "true" ]; then
  docker pull $DOCKER_IMAGE_NAME_WITH_TAG || docker pull $DOCKER_IMAGE_NAME || 1
fi

docker build -t $DOCKER_IMAGE_NAME_WITH_TAG -f $DOCKERFILE $CUSTOM_DOCKER_BUILD_ARGS $BUILD_CONTEXT
docker push $DOCKER_IMAGE_NAME_WITH_TAG
