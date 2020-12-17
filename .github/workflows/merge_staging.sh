#!/bin/bash

API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/pulls/${number}/reviews?per_page=100")
reviews=$(echo "$body" | jq --raw-output '.[] | {state: .state} | @base64')

approvals=0
for r in $reviews; do
  echo $r
  review="$(echo "$r" | base64 -d)"
  state=$(echo "$review" | jq --raw-output '.state')

  if [[ "$state" == "APPROVED" ]]; then
    approvals=$((approvals+1))
  fi
done
echo $approvals

#if [[ "$approvals" -ge "$APPROVALS" ]] && [[ "$GITHUB_BASE_REF" -ge "main" ]]; then
  mergeStaging=$(curl -sSL \
    -H "${AUTH_HEADER}" \
    -H "${API_HEADER}" \
    -X POST \
    -d "{\"base\":\"staging\", \"head\":\"${GITHUB_HEAD_REF}\"}" \
    "${URI}/repos/${GITHUB_REPOSITORY}/merges")
  echo $mergeStaging
#fi
