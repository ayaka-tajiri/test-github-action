#!/bin/bash

echo "run script"

# get pull request number
BRANCH=$GITHUB_HEAD_REF
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
CURRENT_TAG_BODY=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${GITHUB_API_URL}/${GITHUB_REPOSITORY}/releases/latest")
CURRENT_TAG_NAME=$(echo "$CURRENT_TAG_BODY" | jq --raw-output '.tag_name')
echo $CURRENT_TAG_NAME
VERSIONS=$(echo $CURRENT_TAG_NAME | tr "." " ")
echo ${#VERSIONS[@]}

if [ `echo $branch | grep Bugfix` ]; then
  VERSIONS[2]=$VERSIONS[2]+1
elif [ echo $branch | grep Feature ]; then
  VERSIONS[1]=$VERSIONS[1]+1
else
  echo "Not a proper branch name."
  exit 0
fi

RESULTS="$(IFS="."; echo "${VERSIONS[*]}")"

echo $RESULTS
