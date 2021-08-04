# containers-with-sboms

This project demonstrates how to use a series of tools to build container images with corresponding Software Bill Of Materials, or SBOM. The tools highlight the use of container basics, an SBOM generation tool, and an OCI compatible registry. The end result is an end-to-end (albeit, hacky) solution to integrate SBOM generation and distribution into the container ecosystem.

## Quick Start

If you have Virtual Box and Vagrant installed, all you have to do is clone this project, cd into it, and run:
```
vagrant up
vagrant ssh
```

_Note: depending on how powerful your computer is, bringing up the Vagrant box can take a long time. Perhaps go make yourself a nice cup of tea and come back._

Once you are in the vagrant box, spin up an instance of the distribution registry:
```
$ podman pull registry:2.7.1
$ podman run -d -p 5000:5000 --name registry registry:2.7.1
```

You can then build the container and corresponding sbom:
```
$ cd containers-with-sboms
$ ./base_container.sh
```

This should create a container called `localhost:5000/debian:10` and a file called `sbom1`.

Finally, you can publish the container and sbom:
```
$ buildah push --tls-verify=false localhost:5000/debian:10
$ oras push localhost:5000/debian-sbom:10 sbom1
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

## Contributing

I don't expect contributions to this project, but if you feel it is missing some key information or some misconceptions, feel free to submit a PR! For more details on how to contribute, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the BSD-2-Clause license. Please refer to the [LICENSE](LICENSE) and [NOTICE](NOTICE) files for more information.
