#!/usr/bin/env bash

# Copyright (c) 2020 Feedzai
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
# @author Alberto Ferreira (alberto.ferreira@feedzai.com)

set -e

function echo_stage () { echo -e "\n\n\e[1m\e[32m>>>\e[0m \e[1m$1\e[0m\n"; }
function echo_bold() { echo -e "\e[1m$1\e[0m"; }

export LIGHTGBM_REPO_URL="${LIGHTGBM_REPO_URL:-https://github.com/microsoft/LightGBM}"


LIGHTGBM_VERSION=$([[ -z "$1" ]] && echo "master" || echo "$1")
PACKAGE_VERSION="$2"
if [[ -z "$PACKAGE_VERSION" ]]; then
    if [[ "$LIGHTGBM_VERSION" =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]; then
        PACKAGE_VERSION=${LIGHTGBM_VERSION:1} # strip 'v'
    else
        PACKAGE_VERSION="0.0.0"
    fi
fi

# If $ARCH_BUILD == single we generate only artifacts for AMD64
ARCH_BUILD="${ARCH_BUILD:-multi}"

echo_stage "Checking need to build a new version..."
BUILD_COMMIT_ID_FILE=build/__commit_id__

## Compute requested commit id from git command
# Query tag's commit:
REQUESTED_BUILD_VERSION_COMMIT=`git ls-remote $LIGHTGBM_REPO_URL $LIGHTGBM_VERSION | cut -f1`
# No output? Error or queried a valid commit id. Assume it is a commit:
REQUESTED_BUILD_VERSION_COMMIT=${REQUESTED_BUILD_VERSION_COMMIT:-$LIGHTGBM_VERSION}
echo "Requested build version commit ${REQUESTED_BUILD_VERSION_COMMIT}."
## Check build/ for the latest build. Does it match the requested one? If so, skip.
if [[ -f $BUILD_COMMIT_ID_FILE ]]; then
    BUILT_COMMIT_ID=`cat $BUILD_COMMIT_ID_FILE`
    if [[ "$BUILT_COMMIT_ID" == "$REQUESTED_BUILD_VERSION_COMMIT" ]]; then
        echo "Found build/ contents to be up-to-date. Skipping build."
        exit
    fi
fi

## Check build_cache/ for a build of the requested commit. Found one? Skip.
if [[ -d "build_cache/$REQUESTED_BUILD_VERSION_COMMIT" ]]; then
    echo "Found build in build_cache/. Copying build_cache to build/..."
    rm -rf build
    cp -r "build_cache/$REQUESTED_BUILD_VERSION_COMMIT" build
    echo "Build cache restored. Skipping build."
    exit
fi

## Tough luck, no caches, build from scratch.
echo "build/ is not up-to-date and no build caches found. Proceeding with build."
echo "Old build commit id: $BUILT_COMMIT_ID"
echo "New build commit id: $REQUESTED_BUILD_VERSION_COMMIT"

echo_stage "Building LightGBM CI docker image replicas..."
bash docker/make_docker_image.sh amd64

if [[ "$ARCH_BUILD" != "single" ]]; then
    bash docker/make_docker_image.sh arm64
fi

bash docker/make_docker_image.sh alpine

echo_stage "Launching AMD64 container..."
container_amd64=$(docker run -e LIGHTGBM_REPO_URL -t -d lightgbm-ci-build-env-amd64)
docker cp docker/make_lightgbm.sh $container_amd64:/lightgbm
echo_bold "Running AMD64 container: $container_amd64"

echo_stage "Building AMD64 LightGBM $LIGHTGBM_VERSION..."
docker container exec $container_amd64 bash make_lightgbm.sh "$LIGHTGBM_VERSION"

if [[ "$ARCH_BUILD" != "single" ]]; then
    echo_stage "Launching ARM64 container..."
    container_arm64=$(docker run --platform=arm64 -e LIGHTGBM_REPO_URL -t -d lightgbm-ci-build-env-arm64)
    docker cp docker/make_lightgbm.sh $container_arm64:/lightgbm
    echo_stage "Building ARM64 LightGBM $LIGHTGBM_VERSION..."
    docker container exec $container_arm64 bash make_lightgbm.sh "$LIGHTGBM_VERSION"
fi

echo_stage "Launching Alpine container..."
container_alpine=$(docker run -e LIGHTGBM_REPO_URL -t -d lightgbm-ci-build-env-alpine)
docker cp docker/make_lightgbm.sh $container_alpine:/lightgbm/make_lightgbm.sh
echo_bold "Running Alpine container: $container_alpine"

echo_stage "Building Alpine LightGBM $LIGHTGBM_VERSION..."
docker container exec $container_alpine bash make_lightgbm.sh "$LIGHTGBM_VERSION"

echo_stage "Copying artifacts to build/ ..."
rm -rf build
mkdir -p build/amd64/glibc
mkdir -p build/amd64/alpine
mkdir -p build/arm64

FROM_AMD64="$container_amd64:/lightgbm/LightGBM"
docker cp $FROM_AMD64/lib_lightgbm.so build/amd64/glibc
docker cp $FROM_AMD64/lib_lightgbm_swig.so build/amd64/glibc
docker cp $FROM_AMD64/build/lightgbmlib.jar build
docker cp $container_amd64:/usr/lib/x86_64-linux-gnu/libgomp.so.1.0.0 build/amd64/glibc

if [[ "$ARCH_BUILD" != "single" ]]; then
    FROM_ARM64="$container_arm64:/lightgbm/LightGBM"
    docker cp $FROM_ARM64/lib_lightgbm.so build/arm64
    docker cp $FROM_ARM64/lib_lightgbm_swig.so build/arm64
    docker cp $container_arm64:/usr/lib/aarch64-linux-gnu/libgomp.so.1.0.0 build/arm64
fi

FROM_ALPINE="$container_alpine:/lightgbm/LightGBM"
docker cp $FROM_ALPINE/lib_lightgbm.so build/amd64/alpine
docker cp $FROM_ALPINE/lib_lightgbm_swig.so build/amd64/alpine
docker cp $container_alpine:/usr/lib/libgomp.so.1.0.0 build/amd64/alpine

# Place version information
docker cp $FROM_AMD64/build/__commit_id__ build
echo "$LIGHTGBM_VERSION" > build/__version__
date +"%y/%m/%d %T" > build/__timestamp__
echo "$LIGHTGBM_REPO_URL" > build/__lightgbm_repo_url__

echo_bold "Create pom..."
bash resources/make_pom.sh "$LIGHTGBM_VERSION" "$PACKAGE_VERSION"
cp resources/copy_to_build/* build/

echo_stage "Cleaning up..."
echo_bold "Stopping and removing containers..."
docker container rm -f $container_amd64
if [[ "$ARCH_BUILD" != "single" ]]; then
    docker container rm -f $container_arm64
fi

if [[ "$3" == "--cache" ]]; then
    mkdir -p build_cache
    echo_stage "Creating build cache..."
    rm -rf build_cache/tmp
    echo_bold "Copying build..."
    cp -r build build_cache/tmp
    echo_bold "Archiving build cache..."
    mv build_cache/tmp build_cache/${REQUESTED_BUILD_VERSION_COMMIT}
fi

echo "Build $PACKAGE_VERSION finished for LightGBM $LIGHTGBM_VERSION version."
