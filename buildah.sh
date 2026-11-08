#!/bin/bash
set -euo pipefail

# Build fsp-server image from Containerfile. Computes FSP version and
# commit revision from the fsp-code submodule and passes them as
# build args.
#
# Usage: ./buildah.sh [image-tag]   (default tag: fsp-server)
#
# Requires the fsp-code submodule to be populated:
#   git submodule update --init

git_root="$(git rev-parse --show-toplevel)"
cd "$git_root"

buildah bud \
    --build-arg FSP_VERSION="$(sed -n "s/^VERSION='\(.*\)'/\1/p" fsp-code/SConstruct)" \
    --build-arg FSP_REVISION="$(git -C fsp-code describe --tags --always)" \
    -t "${1:-fsp-server}" \
    .
