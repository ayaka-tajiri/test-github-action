#!/bin/bash

echo "run script"

# get pull request number
BRANCH=$GITHUB_HEAD_REF
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
CURRENT_TAG_BODY=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases/latest")
CURRENT_TAG_NAME=$(echo "$CURRENT_TAG_BODY" | jq --raw-output '.tag_name')
VERSIONS=$(echo $CURRENT_TAG_NAME | tr "." " ")

if [ `echo $BRANCH | grep Bugfix` ]; then
  NUMBER=${VERSIONS[2]}
  VERSIONS[2]=$(( $NUMBER+1 ))
  echo "grep Bugfix"
  echo ${VERSIONS[2]}
elif [ `echo $BRANCH | grep Feature` ]; then
  NUMBER=${VERSIONS[1]}
  VERSIONS[1]=$(( $NUMBER+1 ))
  echo "grep Feature"
  echo ${VERSIONS[1]}
else
  echo "Not a proper branch name."
  exit 0
fi

echo ${VERSIONS[1]}
RESULT="${VERSIONS[0]}.${VERSIONS[1]}.${VERSIONS[2]}"
echo $RESULT
