#!/usr/bin/env bash

# Copyright (c) 2022 Feedzai
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

BUILD_LGBM_PATCH_FROM="$1"

if [[ -z "$BUILD_LGBM_PATCH_FROM" ]]; then
    echo "ERROR: Specify lightgbm/build/ folder where to build a patch from."
    exit 1
fi
if [[ ! -f build/lib_lightgbm.so ]]; then
    echo "ERROR: Run make.sh before make_patch.sh."
    exit 1
fi

echo_stage "Building LGBM patch from source!"
echo_bold "Compiling with existing CMake settings at build_dir=${BUILD_LGBM_PATCH_FROM}"
CWD="$(pwd)"
cd "$BUILD_LGBM_PATCH_FROM"
make -j4
find . -name "*.so" -exec cp {} "${CWD}/build" \;
cp lightgbmlib.jar "${CWD}/build"
cp $(ldd "${CWD}/build/lib_lightgbm.so" | awk '/libgomp/{print $3}') "${CWD}/build/libgomp.so.1.0.0"

echo_bold "Patched LightGBM build."
