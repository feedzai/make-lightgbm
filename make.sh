#!/usr/bin/env bash
set -e

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


echo_stage "Building LightGBM CI docker image replica..."
bash make_docker_image.sh

echo_stage "Launching container..."
container=$(docker run -t -d lightgbm-ci-build-env)
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

echo_bold "Create pom..."
bash make_pom.sh "$LIGHTGBM_VERSION" "$PACKAGE_VERSION"
cp install_jar_locally.sh build/
cp resources/libopenmp.licence build/

echo_stage "Cleaning up..."
echo_bold "Stopping and removing container..."
docker container rm -f $container

echo "Build $PACKAGE_VERSION finished for LightGBM $LIGHTGBM_VERSION version."
