# Building containers remotely

Building Singularity containers require `sudo` with `root` access which usually is not the case on community or public computer resources. Instances running on the cloud are an exception of this general rule.

In this course we will limit to exercises with local builds and try building remote when we gather some experience.

For now, here are the two most common remote building services (GitHub is experimenting with it as well).

## Singularity Container Services
Default installation of Singularity is configured to connect to the public [cloud.sylabs.io](https://cloud.sylabs.io/) services which allows you to send a definition file to be built on the Sylab cloud.

Follow the manual about [Remote Endpoinst](https://sylabs.io/guides/3.8/user-guide/endpoint.html) to learn how to build containers remotely.

## Building interactivelly in Gitpod
We are trying to provide an [**experimental build**](./gitpod.md) with graphical interface and Apptainer running in [Gitpod](https://www.gitpod.io/). The free tier allows users to run about 50 hours on the standard configuration (4 cores, 8GB RAM, ~30GB storage).


## Singularity Container Registry (Singularity Hub)
[Singularity Hub](https://singularity-hub.org/) is the predecessor to Singularity Registry, and while it also serves as an image registry, in addition it provides a cloud build service for users. Singularity Hub also takes advantage of Github for version control of build recipes. The user pushes to Github, a builder is deployed, and the image available to the user. Singularity Hub would allow a user to build and run an image from a resource where he or she doesn't have sudo simply by using Github as a middleman.

!!! failure "Notice"
    Singularity Hub is no longer online as a builder service, but exists as a read only archive. Containers built before April 19, 2021 are available at their same pull URLs. To see a last day gallery of Singularity Hub, please see [here](https://singularityhub.github.io/singularityhub-docs/lastday/)
