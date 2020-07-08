#!/usr/bin/env bash

# @author Alberto Ferreira (alberto.ferreira@feedzai.com)

#set -e

export LIGHTGBM_VERSION="$1"
export PACKAGE_VERSION="$2"
export MAKE_LIGHTGBM_URL="$(git config --get remote.origin.url)"
export COMMIT="$(cat build/__commit_id__)"
export PACKAGE_TIMESTAMP="$(cat build/__timestamp__)"

if [[ "$PACKAGE_VERSION" == "0.0.0" ]]; then
    VERSION="$PACKAGE_VERSION-$LIGHTGBM_VERSION"
else
    VERSION="$PACKAGE_VERSION"
fi

sed -e 's,${VERSION},'"$VERSION"',g' \
    -e 's,${LIGHTGBM_VERSION},'"$LIGHTGBM_VERSION"',g' \
    -e 's,${PACKAGE_VERSION},'"$PACKAGE_VERSION"',g' \
    -e 's,${MAKE_LIGHTGBM_URL},'"$MAKE_LIGHTGBM_URL"',g' \
    -e 's,${COMMIT},'"$COMMIT"',g' \
    -e 's,${PACKAGE_TIMESTAMP},'"$PACKAGE_TIMESTAMP"',g' \
    pom_template.xml > build/pom.xml

