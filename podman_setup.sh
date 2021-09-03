#!/bin/sh
#
# Copyright (c) 2021 VMware, Inc.
# SPDX-License-Identifier: BSD-2-Clause
#
# This is a convenience script to set up podman in a running
# Vagrant box. It spins up a local registry to interact with

podman pull registry:2.7.1
podman run -d -p 5000:5000 --name registry registry:2.7.1
