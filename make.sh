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

function echo_stage () {
    echo -e "\n\n\e[1m\e[32m>>>\e[0m \e[1m$1\e[0m\n"
}

function echo_bold() {
    echo -e "\e[1m$1\e[0m"
}

echo_stage "Checking need to build a new version..."
BUILD_COMMIT_ID_FILE=build/__commit_id__
if [[ -f $BUILD_COMMIT_ID_FILE ]]; then
    # Query tag's commit:
    REQUESTED_BUILD_VERSION_COMMIT=`git ls-remote $LIGHTGBM_REPO_URL $LIGHTGBM_VERSION | cut -f1`
    # No output? Error or queried a valid commit id. Assume it is a commit:
    REQUESTED_BUILD_VERSION_COMMIT=${REQUESTED_BUILD_VERSION_COMMIT:-$LIGHTGBM_VERSION}

    BUILT_COMMIT_ID=`cat $BUILD_COMMIT_ID_FILE`
    if [[ "$BUILT_COMMIT_ID" == "$REQUESTED_BUILD_VERSION_COMMIT" ]]; then
        echo "Found build/ contents to be up-to-date. Skipping build."
        exit
    else
        echo "build/ is not up-to-date. Proceeding with build."

        echo "Old build commit id: $BUILT_COMMIT_ID"
        echo "New build commit id: $REQUESTED_BUILD_VERSION_COMMIT"
    fi
fi

echo_stage "Building LightGBM CI docker image replica..."
bash make_docker_image.sh

echo_stage "Launching container..."
container=$(docker run -e LIGHTGBM_REPO_URL -t -d lightgbm-ci-build-env)
docker cp make_lightgbm.sh $container:/lightgbm
echo_bold "Running container: $container"

echo_stage "Building LightGBM..."
docker container exec $container bash make_lightgbm.sh "$LIGHTGBM_VERSION"

echo_stage "Copying artifacts to build/ ..."
rm -rf build
mkdir build

FROM="$container:/lightgbm/LightGBM"
docker cp $FROM/lib_lightgbm.so build
docker cp $FROM/lib_lightgbm_swig.so build
docker cp $FROM/build/lightgbmlib.jar build
docker cp $container:/usr/lib/x86_64-linux-gnu/libgomp.so.1.0.0 build

# Place version information
docker cp $FROM/build/__commit_id__ build
echo "$LIGHTGBM_VERSION" > build/__version__
date +"%y/%m/%d %T" > build/__timestamp__
echo "$LIGHTGBM_REPO_URL" > build/__lightgbm_repo_url__

echo_bold "Create pom..."
bash make_pom.sh "$LIGHTGBM_VERSION" "$PACKAGE_VERSION"
cp resources/copy_to_build/* build/

echo_stage "Cleaning up..."
echo_bold "Stopping and removing container..."
docker container rm -f $container

echo "Build $PACKAGE_VERSION finished for LightGBM $LIGHTGBM_VERSION version."
