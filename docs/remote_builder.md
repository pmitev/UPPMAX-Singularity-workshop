# Building containers remotely

Building Singularity containers might require `sudo` with `root` access which usually is not the case on community or public computer resources. Instances running on the cloud are an exception of this general rule.

In this course we will limit to exercises with local builds and try building remote when we gather some experience.

For now, here are the two most common remote building services (GitHub is experimenting with it as well).

## Singularity Container Services
- Default installation of Singularity is configured to connect to the public [cloud.sylabs.io](https://cloud.sylabs.io/) services which allows you to send a definition file to be built on the Sylab cloud.
- Follow the manual about [Remote Endpoinst](https://docs.sylabs.io/guides/latest/user-guide/endpoint.html) to learn how to build containers remotely.

## [Seqera containers](https://seqera.io/containers/)
Container images are built on-demand by using Seqeras publicly hosted [Wave](https://seqera.io/wave/) service. When you request an image, the following steps take place:

1. The set of packages and their versions are sent to the Seqera Containers API, including configuration settings such as image format (Docker / Singularity) and architecture (amd64 / arm64).
2. The Seqera Containers API validates the request and calls the Wave service API to request the image.
3. The Wave service API returns details such as the image name and build details to the Seqera Containers backend, which are then returned to the web interface.
4. The web interface uses the build ID to query the Wave service API directly for details such as build status and build details.
5. If needed, Wave creates the container build file (either `Dockerfile` or Singularity recipe) and runs the build. It returns the resulting image and pushes it to the Wave community registry for any subsequent request.

## Building interactivelly in Gitpod
We are trying to provide an [**experimental build**](./gitpod.md) with graphical interface and Apptainer running in [Gitpod](https://www.gitpod.io/). The free tier allows users to run about 50 hours on the standard configuration (4 cores, 8GB RAM, ~30GB storage).


## Singularity Container Registry (Singularity Hub)
[Singularity Hub](https://singularity-hub.org/) is the predecessor to Singularity Registry, and while it also serves as an image registry, in addition it provides a cloud build service for users. Singularity Hub also takes advantage of Github for version control of build recipes. The user pushes to Github, a builder is deployed, and the image available to the user. Singularity Hub would allow a user to build and run an image from a resource where he or she doesn't have sudo simply by using Github as a middleman.

!!! failure "Notice"
    Singularity Hub is no longer online as a builder service, but exists as a read only archive. Containers built before April 19, 2021 are available at their same pull URLs. To see a last day gallery of Singularity Hub, please see [here](https://singularityhub.github.io/singularityhub-docs/lastday/)
