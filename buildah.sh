#!/bin/bash

# Does not compile on fedora, use debian as a build container to compile fsp
build_container="$(buildah from docker.io/library/debian:bookworm-slim)"
buildah run "$build_container" apt-get update
buildah run "$build_container" apt-get install -y build-essential python3 flex gcc scons
git_root="$(git rev-parse --show-toplevel)"
buildah run --mount type=bind,source="$git_root"/fsp-code/,destination=/fsp-code/,rw "$build_container" bash -c "cd /fsp-code && scons install without-clients=yes without-fspscan=yes prefix=/usr sysconfdir=/etc"

# Create image using the same debian image as base
runtime_container="$(buildah from docker.io/library/debian:bookworm-slim)"
buildah copy --from "$build_container" "$runtime_container" /usr/bin/fspd /usr/bin/
buildah config --port 21/udp "$runtime_container"
buildah config --entrypoint '["/usr/bin/fspd"]' "$runtime_container"
buildah commit "$runtime_container" fsp-server

# Clean up
buildah rm "$build_container" "$runtime_container"
