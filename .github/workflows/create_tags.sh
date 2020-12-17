#!/bin/bash

# get pull request number
BRANCH=$GITHUB_HEAD_REF
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
CURRENT_TAG_BODY=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases/latest")
CURRENT_TAG_NAME=$(echo "$CURRENT_TAG_BODY" | jq --raw-output '.tag_name')

SPLIT_TAG=$(echo $CURRENT_TAG_NAME | tr "." " ")
declare -a VERSIONS=($SPLIT_TAG)
NUMBER0=${VERSIONS[0]}
NUMBER1=${VERSIONS[1]}
NUMBER2=${VERSIONS[2]}

if [ `echo $BRANCH | grep Bugfix` ]; then
  NUMBER2=$(( $NUMBER2+1 ))
elif [ `echo $BRANCH | grep Feature` ]; then
  NUMBER1=$(( $NUMBER1+1 ))
  NUMBER2=0
else
  echo "Not a proper branch name."
  exit 0
fi

NEW_REELASE_TAG="${NUMBER0}.${NUMBER1}.${NUMBER2}"

curl -sSL \
  -H "${AUTH_HEADER}" \
  -H "${API_HEADER}" \
  -X POST \
  -H "Content-Type: application/json" \
  -d "{\"tag_name\":\"${NEW_REELASE_TAG}\", \"name\": \"release\", \"body\": \"image-tag: ${GITHUB_SHA:0:7}\"}" \
  "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases"

echo "New Release Tag is ${NEW_REELASE_TAG}"
