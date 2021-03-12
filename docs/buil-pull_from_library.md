# Pulling Singularity container from online or local library/repository

### Bootstrap from different sources
- **library://** to build from the [Container Library](https://cloud.sylabs.io/library)  
` library://sylabs-jms/testing/lolcow`
- **docker://** to build from [Docker Hub](https://hub.docker.com/)  
` docker://godlovedc/lolcow`
- **shub://** to build from [Singularity Hub](https://singularityhub.com/)
- path to a existing container on your local machine
- path to a directory to build from a sandbox
- path to a Singularity definition file