#!/usr/bin/env bash
set -e

# Usage: $1 serves to checkout a specific commit/tag

git clone --recursive https://github.com/microsoft/LightGBM ; cd LightGBM
[[ ! -z "$1" ]] && git checkout "$1"
mkdir build ; cd build
cmake .. -DUSE_SWIG=ON
make -j4

# Generate a commit id so we can track it outside
git rev-parse HEAD > __commit_id__
