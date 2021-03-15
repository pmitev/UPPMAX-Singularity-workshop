# Building simple container

Let's start with a simple example.  
For the  more complicated we will try to use a bit more interactive approach using `--sandbox` option.

Here we simply install the [Paraview](https://www.paraview.org/) program in virtual environment conveniently provided provided by the Ubuntu distribution via the docker hub repository.

`Singularity.paraview`
``` singularity
Bootstrap: docker
From: ubuntu:20.04

%post
  export DEBIAN_FRONTEND=noninteractive
  
  apt-get update && apt-get -y dist-upgrade && \
  apt-get install -y paraview && \
  apt-get clean

%runscript
  paraview $@
```

``` bash
$ sudo singularity build paraview.sif Singularity.paraview
```

This will download 301 MB and install 500 new packages... It might take some time to complete, but once you are done you will have a container that will run almost everywhere - there is always a catch.

Instead of paraview, modify the definiton file to install and run your, not necessary graphical, program. Few tips: gnuplot, grace, blender, povray, rasmol...

## Building interactively in a sandbox.

Unless you now exactly which programs and commands you need to install it might be rather tricky to assemble a recipe that will work. If every change requires rebuilding it becomes rather tedious work. Instead, we can try to build a container as we would do it interactively on the command line.

For this purpose we will use '--sandbox' option which keeps the file structure intact.A regular build will create this folder structure in the `/tmp` then at the end will wrap everything in a single compressed **read-only** file by `mksquasfs` and delete the folder...
The so called sandbox is writable (by root) and accessible as regular folder (by root).

This is extremely convenient for testing purposes. The sandbox folder could be later converted to a regular container - but please do not do it unless you have a good reason why you are braking all the reproducible features of the container. Instead, during the interactive build, take notes by editing the definition file and build from scratch when you think you are ready.