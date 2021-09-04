# containers-with-sboms

This project demonstrates how to use a series of tools to build container images with corresponding Software Bill Of Materials, or SBOM. The tools highlight the use of container basics, an SBOM generation tool, and an OCI compatible registry. The end result is an end-to-end (albeit, hacky) solution to integrate SBOM generation and distribution into the container ecosystem.

## Quick Start

We will use Virtual Box and Vagrant to spin up a Vagrant box (a VM) containing all the required ingredients installed. We just clone this project, cd into it and run:
```
vagrant up
vagrant ssh
```

_Note: depending on how powerful your computer is, bringing up the Vagrant box can take a long time. Perhaps go make yourself a nice cup of tea and come back._

Once we are in the vagrant box, we can spin up an instance of the distribution registry:
```
$ podman pull registry:2.7.1
$ podman run -d -p 5000:5000 --name registry registry:2.7.1
```
Or run the convenience `podman_setup.sh` script:
```
$ cd containers-with-sboms
$ ./podman_setup.sh
```

We then build the container and corresponding sbom:
```
$ cd containers-with-sboms <-- (only if you are not already in the directory)
$ ./base_container.sh
```

This should create a container called `localhost:5000/debian:10`, and a file called `debian-sbom`, which is also pushed to the local registry. You should still be able to see the image when running `podman images` or `buildah images` and the sbom file.

## Derived Containers

Now that we have a container with an OS and a corresponding SBOM, we can create another container on top of this which includes the original SBOM:
```
$ ./derived_container.sh
```

This should create container called `localhost:5000/python:3` and two files called `debian-sbom` and `python-sbom`. These files can be deleted as we now have them on the registry.

## Multi-stage builds

The nice thing about reusing SBOMs in this way is that even if the build container is gone, the SBOMs describing the containers remain and can be propagated with the deployment image. To demonstrate this, we first make a golang container using the base debian image and a golang binary:
```
$ ./golang_container.sh
```

We can then use this container to build our golang application:
```
$ ./hello_container.sh
$ podman run localhost:5000/hello:1.0 hello
```

## Ingredients

You may view the `bootstrap.sh` script to see how to provision a single node with all the tools. Here, I am using a debian/bullseye Vagrant box as it is the easiest seed for creating a base container rootfs. Your Mileage May Vary.

Overall, you will need the following tools: 
- Install python3, pip3, buildah, and ORAS (untar the binary from github release and place it somewhere where the system can find it)
- Install tern using pip3 (pip3 install tern)
- Obtain an OS rootfs (I used debootstrap to create one)
- Locate an OCI compatible registry (I spun up a distribution/docker registry)

## Under The Hood

1. `base_container.sh` creates a container from scratch using buildah.
2. `buildah unshare` will mount the container in the user's namespace and return a mount path. There is some path manipulation as this is not exactly where the files are located since `buildah unshare` creates the mount point in a different namespace which disappears.
3. `buildah add` will add the `debian.tar` rootfs which we had created before using `debootstrap`.
4. `buildah commit` will create an image containing this rootfs.
5. `tern report --live` will generate an SBOM given the path to the rootfs. The rootfs doesn't have to be mounted at this point, although in order to show the resulting filesystem created by the storage driver in subsequent container uses, this is required for generating an accurate SBOM.

## Next Steps

We notice that there are some very basic UX needs in order to make this usable at a large scale:

We need to keep track of all of the tags. This is currently the problem with many client tools which use registries to store artifacts along with container images. A working group on using [Reference Types](https://github.com/opencontainers/artifacts/pull/29) which link the artifacts back to the container image allows the reduction of tags as shown below

## Contributing

I don't expect contributions to this project, but if you feel it is missing some key information or some misconceptions, feel free to submit a PR! For more details on how to contribute, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the BSD-2-Clause license. Please refer to the [LICENSE](LICENSE) and [NOTICE](NOTICE) files for more information.
