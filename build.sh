#!/bin/bash
set -euo pipefail

#IMAGE_NAME=registry.example.com/yourorg/yourserver

docker image build -t bingo

GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
GIT_COMMIT=$(git rev-parse --short HEAD)

# Pull previous version, and use with --cache-now
# for build caching:
docker pull $IMAGE_NAME:$GIT_BRANCH || true

# Use branch+commit for tagging:
docker build -t "$IMAGE_NAME:$GIT_BRANCH" \
             -t "$IMAGE_NAME:$GIT_COMMIT" \
             --label git-commit=$GIT_COMMIT \
             --label git-branch=$GIT_BRANCH \
             --build-arg BUILDKIT_INLINE_CACHE=1 \
             --cache-from=$IMAGE_NAME:$GIT_BRANCH .

# Security scanners:
docker run --entrypoint=bash $IMAGE_NAME:$GIT_BRANCH \
           -c "pip install --user safety && ~/.local/bin/safety check"
trivy --ignore-unfixed --exit-code 1 \
    $IMAGE_NAME:$GIT_BRANCH

# Push to the registry:
docker push "$IMAGE_NAME:$GIT_BRANCH"
docker push "$IMAGE_NAME:$GIT_COMMIT"

# TODO additional code to ensure a complete rebuild 
# (docker build --pull --no-cache) once a week.
