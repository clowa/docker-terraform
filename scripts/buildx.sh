#! /bin/bash

usage="$(basename "$0") [-l | -a] -- program to build docker images of terraform for multiple platforms.

where:
    -l  only build docker image of latest GitHub release
    -a  build docker image of all available GitHub releases"

function joinByChar() {
  local IFS="$1"
  shift
  echo "$*"
}

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

if [ -z ${DOCKER_IMAGE+set} ]; then
  DOCKER_IMAGE='clowa/terraform'
fi

if [ -z ${PLATFORMS+set} ]; then
  PLATFORMS=("linux/386" "linux/amd64" "linux/arm/v6" "linux/arm/v7" "linux/arm64/v8")
fi

while getopts :hla: flag
do
    case "${flag}" in
        h)
          echo "$usage"
          exit
          ;;
        l)
          ## Only fetch latest releases
          LATEST=true
          TERRAFORM_VERSIONS=($(curl --silent https://api.github.com/repos/hashicorp/terraform/releases/latest | jq --raw-output '.name' | tr -d 'v'))
          set -e
          ;;
        a)
          ## Get all GitHub releases
          TERRAFORM_VERSIONS=($(curl --silent https://api.github.com/repos/hashicorp/terraform/releases | jq --raw-output '.[].name' | tr -d 'v'))
          ;;
        *)
          ## Filter out alpha and beta releases
          TERRAFORM_VERSIONS=($(curl --silent https://api.github.com/repos/hashicorp/terraform/releases | jq --raw-output '.[]|select(.name|test("^v[\\d]*\\.[\\d]*\\.[\\d]*$"))|.name' | tr -d 'v'))
          ;;
    esac
done

## Invert array 
INVERTED_TF_VERSIONS=($(invertArray ${TERRAFORM_VERSIONS[@]}))

for TF_VERSION in "${INVERTED_TF_VERSIONS[@]}"
do
    echo "Build Info:"
    echo "  TF_VERSION: ${TF_VERSION}"
    echo "  Platforms: $(joinByChar ',' "${PLATFORMS[@]}")"
    echo "  Tag: $DOCKER_IMAGE:${TF_VERSION}"

    docker buildx build \
            --push \
            --file ./docker/dockerfile.releases \
            --build-arg TERRAFORM_VERSION=${TF_VERSION} \
            --platform $(joinByChar ',' "${PLATFORMS[@]}") \
            --tag $DOCKER_IMAGE:${TF_VERSION} .
done