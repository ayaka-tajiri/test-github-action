#!/bin/bash

echo "run script"

# get pull request number
BRANCH=$GITHUB_HEAD_REF
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
CURRENT_TAG_BODY=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/releases/latest")
CURRENT_TAG_NAME=$(echo "$CURRENT_TAG_BODY" | jq --raw-output '.tag_name')
declare -a VERSIONS=()
VERSIONS=$(echo $CURRENT_TAG_NAME | tr "." " ")
NUMBER0=${VERSIONS[0]}
echo $NUMBER0
NUMBER1=${VERSIONS[1]}
echo $NUMBER1
NUMBER2=${VERSIONS[2]}
echo $NUMBER2

if [ `echo $BRANCH | grep Bugfix` ]; then
  NUMBER2=$(( $NUMBER2+1 ))
  echo "grep Bugfix"
  echo $NUMBER2
elif [ `echo $BRANCH | grep Feature` ]; then
  NUMBER1=$(( $NUMBER1+1 ))
  echo "grep Feature"
  echo $NUMBER1
else
  echo "Not a proper branch name."
  exit 0
fi

RESULT="${NUMBER0}.${NUMBER1}.${NUMBER2}"
echo $RESULT
