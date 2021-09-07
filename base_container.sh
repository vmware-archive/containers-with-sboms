#!/bin/sh
#
# Copyright (c) 2021 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause

# This script will build a container image with an SBoM from scratch
# On successful completion we should have a debian base image,
# an SBOM file called "sbom1", and a config file called sbom_config1.json

# We create a container image using buildah
echo starting...
ctr=$(buildah from scratch)
echo creating container image...
mnt=$(buildah unshare buildah mount $ctr)
buildah add $ctr debian.tar

# We already know this is a debian 10 minbase rootfs so
# we will name the image accordingly
img=$(buildah commit $ctr localhost:5000/debian:10)

# We then provide this directory to tern
echo generating sbom...
tern report --live $mnt -f spdxjson -o debian-sbom
echo image: localhost:5000/debian:10
echo sbom: debian-sbom

# Now push the image and the sbom
buildah push --tls-verify=false localhost:5000/debian:10
oras push localhost:5000/debian:10-sbom debian-sbom:application/json

# Let's sign our artifacts
# This assumes a cosign keypair has been generated and exists
# in a directory called "cosign"
cosign sign -key ~/cosign/cosign.key localhost:5000/debian:10
cosign sign -key ~/cosign/cosign.key localhost:5000/debian:10-sbom

# clean up all the running containers
buildah rm --all
rm debian-sbom
echo ready.
