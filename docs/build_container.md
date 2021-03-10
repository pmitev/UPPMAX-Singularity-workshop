# Building your first container

## Simple Singularity recipe

!!! note "Singularity.lolcow"
    ``` singularity
    BootStrap: docker
    From: ubuntu:16.04

    %post
      apt-get -y update
      apt-get -y install fortune cowsay lolcat

    %environment
      export LC_ALL=C
      export PATH=/usr/games:$PATH

    %runscript
      fortune | cowsay | lolcat
    ```

## Build the Singularity recipe

``` bash
$ sudo singularity build lolcow.sif Singularity.lolcow

Starting build...
Getting image source signatures
Copying blob 4007a89234b4 done  
Copying blob 5dfa26c6b9c9 done  
Copying blob 0ba7bf18aa40 done  
Copying blob 4c6ec688ebe3 done  
Copying config 24336f603e done  
Writing manifest to image destination
Storing signatures

...

INFO:    Adding environment to container
INFO:    Adding runscript
INFO:    Creating SIF file...
INFO:    Build complete: lolcow.sif
```

## Run the Singularity

```
$ ./lolcow.sif 
_________________________________________
/ You will stop at nothing to reach your  \
| objective, but only because your brakes |
\ are defective.                          /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```

### Bootsrap agents - [online documentation](https://sylabs.io/guides/3.7/user-guide/definition_files.html#preferred-bootstrap-agents)
- `library` - images hosted on the [Container Library](https://cloud.sylabs.io/library)
- `docker` - images hosted on [Docker Hub](https://hub.docker.com/)
- `shub` - images hosted on [Singularity Hub](https://singularityhub.com/)
- ...
- Other: `localimage`, `yum`, `debootstrap`, `oci`, `oci-archive`, `docker-daemon`, `docker-archive`, `arch`, `busybox`, `zypper`





### Bootstrap
- **library://** to build from the [Container Library](https://cloud.sylabs.io/library)  
` library://sylabs-jms/testing/lolcow`
- **docker://** to build from [Docker Hub](https://hub.docker.com/)  
` docker://godlovedc/lolcow`
- **shub://** to build from [Singularity Hub](https://singularityhub.com/)
- path to a existing container on your local machine
- path to a directory to build from a sandbox
- path to a Singularity definition file

