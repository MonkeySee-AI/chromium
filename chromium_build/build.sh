#!/bin/bash -e

# Function to fetch Git SHA from Chromium Revision
get_git_sha_from_revision() {
  local revision="$1"
  local url="https://cr-rev.appspot.com/_ah/api/crrev/v1/redirect/${revision}"
  # Using curl to make an HTTP GET request and extract git_sha from the JSON response
  local git_sha=$(curl -s "${url}" | jq -r '.git_sha')
  echo "${git_sha}"
}

if [ -z "$1" ]; then
  echo "Usage: $0 <Chromium Revision>"
  exit 1
fi

chromium_revision="$1"

# Fetching the Git SHA corresponding to the Chromium Revision
git_sha=$(get_git_sha_from_revision "${chromium_revision}")

if [ -z "${git_sha}" ]; then
  echo "Failed to fetch the Git SHA for Chromium Revision: ${chromium_revision}"
  exit 1
fi

# Build the Docker image, passing the Git SHA as a build-arg
docker build --build-arg CHROMIUM_SHA="${git_sha}" -t chromium-builder .
