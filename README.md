# containers-with-sboms

This project demonstrates how to use a series of tools to build container images with corresponding Software Bill Of Materials, or SBOM. The tools highlight the use of container basics, an SBOM generation tool, and an OCI compatible registry. The end result is an end-to-end (albeit, hacky) solution to integrate SBOM generation and distribution into the container ecosystem.

## Quick Start

If you have Virtual Box and Vagrant installed, all you have to do is clone this project, cd into it, and run:
```
vagrant up
vagrant ssh
```

Then you can follow along with the demo.

## Ingredients

You may view the `bootstrap.sh` script to see how to provision a single node with all the tools. Here, I am using a debian/bullseye Vagrant box as it is the easiest seed for creating a base container rootfs. Your Mileage May Vary.

Overall, you will need the following tools: 
- Install python3, pip3, buildah, and ORAS (untar the binary from github release and place it somewhere where the system can find it)
- Install tern using pip3 (pip3 install tern)
- Obtain an OS rootfs (I used debootstrap to create one)
- Locate an OCI compatible registry (I spun up a distribution/docker registry)

## Contributing

I don't expect contributions to this project, but if you feel it is missing some key information or some misconceptions, feel free to submit a PR! For more details on how to contribute, refer to [CONTRIBUTING.md](CONTRIBUTING.md).

## License

This project is licensed under the BSD-2-Clause license. Please refer to the [LICENSE](LICENSE) and [NOTICE](NOTICE) files for more information.
