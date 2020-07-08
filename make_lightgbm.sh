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

# Usage: $1 serves to checkout a specific commit/tag

git clone --recursive https://github.com/microsoft/LightGBM ; cd LightGBM
[[ ! -z "$1" ]] && git checkout "$1"
mkdir build ; cd build
cmake .. -DUSE_SWIG=ON
make -j4

# Generate a commit id so we can track it outside
git rev-parse HEAD > __commit_id__
