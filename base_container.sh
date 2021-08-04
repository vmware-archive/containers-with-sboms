#!/bin/sh

# This script will build a container image with an SBoM from scratch
# On successful completion we should have a debian base image
# and an SBOM file called "sbom1" 

# We create a container image using buildah
echo starting...
ctr=$(buildah from scratch)
echo creating container...
mnt=$(buildah unshare buildah mount $ctr)
buildah add $ctr debian.tar
# We already know this is a debian 10 minbase rootfs so
# we will name the image accordingly
echo creating container image...
img=$(buildah commit $ctr debian:10)

# The real directory where the data gets stored is somewhere else
realmnt=$(echo $mnt | sed 's/merged/diff\/debian/g')
# We then provide this directory to tern
tern report --live $realmnt -f spdxjson -o sbom1
# Let's tag the image ready to be pushed
buildah tag docker.io/library/debian:10 localhost:5000/debian:10
echo tagged image: localhost:5000/debian:10
