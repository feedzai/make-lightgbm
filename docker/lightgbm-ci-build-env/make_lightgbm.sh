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
#
# Usage: $1 serves to checkout a specific commit/tag
set -e

LIGHTGBM_VERSION="$1"


echo "Cloning $LIGHTGBM_REPO_URL ($LIGHTGBM_VERSION)..."
git clone --recursive "$LIGHTGBM_REPO_URL" LightGBM; cd LightGBM
git config advice.detachedHead false  # Disable warnings for detached head.
if [[ ! -z "$LIGHTGBM_VERSION" ]]; then
    git checkout "$LIGHTGBM_VERSION"
    git submodule update --init --recursive # needed to fetch the new submodules in dev branches
fi
mkdir build ; cd build
cmake .. -DUSE_SWIG=ON
make -j4

# Generate a commit id so we can track it outside
git rev-parse HEAD > __commit_id__
