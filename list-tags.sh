#!/bin/sh

# Define the repository and the image you are working with
SOURCE_IMAGE="alpine:latest"
TARGET_IMAGE="${LOGNAME}/djbdns"

# Pull the source image
docker pull -q ${SOURCE_IMAGE} > /dev/null

# Get the digest of the source image
DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ${SOURCE_IMAGE} | cut -d'@' -f2)

# Get the repository name (assumes Docker Hub)
REPO=$(echo ${SOURCE_IMAGE} | cut -d':' -f1)

# Find all tags associated with the digest
TAGS=$(curl -s "https://hub.docker.com/v2/repositories/library/${REPO}/tags/?page_size=100" | jq -r ".results[] | select(.digest==\"${DIGEST}\") | .name ")

echo ${TAGS}
