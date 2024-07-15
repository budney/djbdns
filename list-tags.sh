#!/bin/sh

# Define the repository and the image you are working with
SOURCE_IMAGE="alpine:latest"

# List any applicable git tags. If there are no git tags,
# use the current date.
GIT_TAGS=$(git tag --contains HEAD)
if test "${GIT_TAGS}" = ""; then
    GIT_TAGS=$(date +%Y%M%d)
fi

# Pull the source image
docker pull -q ${SOURCE_IMAGE} > /dev/null

# Get the digest of the source image
DIGEST=$(docker inspect --format='{{index .RepoDigests 0}}' ${SOURCE_IMAGE} | cut -d'@' -f2)

# Get the repository name (assumes Docker Hub)
REPO=$(echo ${SOURCE_IMAGE} | cut -d':' -f1)

# Find all tags associated with the digest
TAGS=$(curl -s "https://hub.docker.com/v2/repositories/library/${REPO}/tags/?page_size=100" | jq -r ".results[] | select(.digest==\"${DIGEST}\") | .name ")

# Filter out the special tag "latest"
TAGS=$(for t in ${TAGS}; do echo ${t}; done|egrep -v latest)

# Now combine with git tags
TAGS="${GIT_TAGS} $(for t in ${TAGS};do for g in ${GIT_TAGS}; do echo ${g}-alpine${t}; done; done)"

echo ${TAGS}
