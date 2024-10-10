# Other projects on the net

## [BioContainers](https://biocontainers.pro/)
BioContainers is a community-driven project that provides the infrastructure and basic guidelines to create, manage and distribute bioinformatics packages (e.g conda) and containers (e.g docker, singularity). BioContainers is based on the popular frameworks Conda, Docker and Singularity.
Quick links:
- https://biocontainers.pro/registry
- https://github.com/BioContainers/containers

## [NGC Catalog](https://catalog.ngc.nvidia.com/containers)
The NGC catalog hosts containers for AI/ML, metaverse, and HPC applications and are performance-optimized, tested, and ready to deploy on GPU-powered on-prem, cloud, and edge systems.

## [Seqera containers](https://seqera.io/containers/)
Container images are built on-demand by using Seqeras publicly hosted [Wave](https://seqera.io/wave/) service. When you request an image, the following steps take place:

1. The set of packages and their versions are sent to the Seqera Containers API, including configuration settings such as image format (Docker / Singularity) and architecture (amd64 / arm64).
2. The Seqera Containers API validates the request and calls the Wave service API to request the image.
3. The Wave service API returns details such as the image name and build details to the Seqera Containers backend, which are then returned to the web interface.
4. The web interface uses the build ID to query the Wave service API directly for details such as build status and build details.
5. If needed, Wave creates the container build file (either `Dockerfile` or Singularity recipe) and runs the build. It returns the resulting image and pushes it to the Wave community registry for any subsequent request.

## [Container recipes provided at C3SE clusters](https://github.com/c3se/containers)
This repository holds the recipes of the centrally provided Singularity containers at C3SE's clusters. They are also useable as a reference for users who wish to build their own Singularity containers.

## [ImageBlueprint](https://github.com/stela2502/ImageBlueprint)
Apptainer image tailored for bioinformatics workflows, focusing on Python and R packages, and configuring the image to run Jupyter Notebooks by default.