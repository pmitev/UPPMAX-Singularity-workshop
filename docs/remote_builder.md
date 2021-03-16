# Building containers remotely

Building Singularity containers require `sudo` with `root` access which usually is not the case on community or public computer resources. Instances running on the cloud are an exception of this general rule.  

## Singularity Container Services
Default installation of Singularity is configured to connect to the public [cloud.sylabs.io](https://cloud.sylabs.io/) services which allows you to send a definition file to be build on the Sylab cloud.

Follow the manual about [Remote Endpoinst](https://sylabs.io/guides/3.7/user-guide/endpoint.html) to learn how to build containers remotely.

## Singularity Container Registry (Singularity Hub)
[Singularity Hub](https://singularity-hub.org/) is the predecessor to Singularity Registry, and while it also serves as an image registry, in addition it provides a cloud build service for users. Singularity Hub also takes advantage of Github for version control of build recipes. The user pushes to Github, a builder is deployed, and the image available to the user. Singularity Hub would allow a user to build and run an image from a resource where he or she doesn't have sudo simply by using Github as a middleman.