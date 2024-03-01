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

cd docker

case "$1" in
    arm64)
        echo "Building docker image for ARM64"
        docker build -t lightgbm-ci-build-env-arm64 --platform=arm64 lightgbm-ci-build-env-arm64
        ;;
    amd64)
        echo "Building docker image for AMD64"
        docker build -t lightgbm-ci-build-env-amd64 lightgbm-ci-build-env-amd64
        ;;
    alpine)
        echo "Building docker image for Alpine with musl"
        docker build -t lightgbm-ci-build-env-alpine lightgbm-ci-build-env-alpine
        ;;
    *)
        echo $"Usage $0 {amd64|arm64}"
        exit 1
esac

