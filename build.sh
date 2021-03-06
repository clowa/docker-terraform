#! /bin/bash

usage="$(basename "$0") [-l | -a | -s] -- program to build docker images of terraform for multiple platforms.

where:
    -l  only build docker image of latest GitHub release
    -a  build docker image of all available GitHub releases
    -s  build docker image only on stable GitHub release"

# function joinByChar() {
#   local IFS="$1"
#   shift
#   echo "$*"
# }

function invertArray() {
  local array=("$@")
  local tmpArray=()

  ## get length of array
  len=${#array[@]}
  
  ## Use bash for loop 
  for (( i=0; i<$len; i++ )); do
    tmpArray[$len - $i]=${array[$i]}
  done
  echo "${tmpArray[@]}"
}

function buildTagArgs() {
  local tags=("$@")
  local tagArgs=()
  
  ## Iterate over each item of the array
  for t in "${tags[@]}"; do
    tagArgs+=("--tag ${DOCKER_IMAGE}:${t}")
  done
  echo "${tagArgs[@]}"
}

if [[ -z ${DOCKER_IMAGE+set} ]]; then
  echo "Environment variable DOCKER_IMAGE not set. Run \"export DOCKER_IMAGE=containous/whoami\""
  exit 2
fi

if [[ -z ${PLATFORMS+set} ]]; then
  echo "Environment variable PLATFORMS not set. Run \"export PLATFORMS=\"linux/amd64,linux/arm64\""
  exit 2
fi

if [[ -z ${ORGANIZATION+set} ]]; then
  echo "Environment variable ORGANIZATION not set. Run \"export ORGANIZATION=hashicorp\""
  exit 2
fi

if [[ -z ${REPOSITORY+set} ]]; then
  echo "Environment variable REPOSITORY not set. Run \"export REPOSITORY=terraform\""
  exit 2
fi

while getopts :hlas flag
do
    case "${flag}" in
        h)
          echo "$usage"
          exit
          ;;
        l)
          ## Only fetch latest releases
          LATEST=true
          VERSIONS=($(curl --silent https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/releases/latest | jq --raw-output '.name' | tr -d 'v'))
          set -e
          ;;
        a)
          ## Get all GitHub releases
          VERSIONS=($(curl --silent https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/releases | jq --raw-output '.[].name' | tr -d 'v'))
          ;;
        s)
          ## Filter out alpha and beta releases
          VERSIONS=($(curl --silent https://api.github.com/repos/${ORGANIZATION}/${REPOSITORY}/releases | jq --raw-output '.[]|select(.name|test("^v\\d*\\.\\d*\\.\\d*$"))|.name' | tr -d 'v'))
          ;;
    esac
done

## Invert array 
INVERTED_VERSIONS=($(invertArray ${VERSIONS[@]}))

for VERSION in "${INVERTED_VERSIONS[@]}"
do
    TAGS=($VERSION)
    
    if [[ $LATEST ]]; then
      TAGS+=("latest")
    fi

    TAG_ARGS=$(buildTagArgs ${TAGS[@]})


    echo "Build Info:"
    echo "  VERSION: ${VERSION}"
    echo "  Platforms: ${PLATFORMS}"
    for t in "${TAGS[@]}"; do
      echo "  Tag: $DOCKER_IMAGE:${t}"
    done

    docker buildx build \
      --push \
      --file ./docker/dockerfile.releases \
      --build-arg TERRAFORM_VERSION=${VERSION} \
      --platform ${PLATFORMS} \
      ${TAG_ARGS} \
      .
done