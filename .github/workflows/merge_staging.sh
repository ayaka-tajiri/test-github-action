#!/bin/bash

cat $GITHUB_EVENT_PATH
API_HEADER="Accept: application/vnd.github.v3+json"
AUTH_HEADER="Authorization: token ${GITHUB_TOKEN}"
number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
baseBranch=$(jq --raw-output .pull_request.base.ref "$GITHUB_EVENT_PATH")
headBranch=$(jq --raw-output .pull_request.head.ref "$GITHUB_EVENT_PATH")
reviewState=$(jq --raw-output .review.state "$GITHUB_EVENT_PATH")
echo $reviewState

if [[ "$reviewState" != "approved" ]]; then
  exit 0
fi

body=$(curl -sSL -H "${AUTH_HEADER}" -H "${API_HEADER}" "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/pulls/${number}/reviews?per_page=100")
reviews=$(echo "$body" | jq --raw-output '.[] | {state: .state} | @base64')

approvals=0
for r in $reviews; do
  review="$(echo "$r" | base64 -d)"
  state=$(echo "$review" | jq --raw-output '.state')

  if [[ "$state" == "APPROVED" ]]; then
    approvals=$((approvals+1))
  fi
done

echo $approvals
if [[ "$approvals" -ge "$APPROVALS" ]] && [[ "$baseBranch" = "main" ]]; then
  mergeStaging=$(curl -sSL \
      -H "${AUTH_HEADER}" \
      -H "${API_HEADER}" \
      -X POST \
      -d "{\"base\":\"staging\", \"head\":\"${headBranch}\"}" \
      -w "HTTPSTATUS:%{http_code}" \
      "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/merges")
  mergeStagingStatus=$(echo $mergeStaging | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
  mergeStagingBody=$(echo $mergeStaging | sed -e 's/HTTPSTATUS\:.*//g')

  commentBody=""
  if [[ $mergeStagingStatus -eq 201 ]]; then
    commentBody="2つのApproveがあったため、stagingブランチにマージされました。"
  elif [[ $mergeStagingStatus -eq 409 ]]; then
    commentBody="2つのApproveがあったため、stagingブランチへのマージを行いましたが、コンフリクトが発生して失敗しました。手動でstagingブランチへマージしてください。"
  else
    commentBody="2つのApproveがあったため、stagingブランチへのマージを行いましたが、エラーが発生して失敗しました。手動でstagingブランチへマージしてください。"
  fi

  postComment=$(curl -sSL \
      -H "${AUTH_HEADER}" \
      -H "${API_HEADER}" \
      -X POST \
      -s \
      -d "{\"body\":\"${commentBody}\"}" \
      "${GITHUB_API_URL}/repos/${GITHUB_REPOSITORY}/issues/${number}/comments")
fi
