# Building simple container

Let's start with a simple example.  

Here is a definition file to install the [Paraview](https://www.paraview.org/) program in virtual environment conveniently provided by the Ubuntu distribution via the docker hub repository.

!!! note "paraview.def"
    ``` singularity
    Bootstrap: docker
    From: ubuntu:20.04

    %post
      export DEBIAN_FRONTEND=noninteractive
      
      apt-get update && apt-get -y dist-upgrade && \
      apt-get install -y paraview && \
      apt-get clean

    %runscript
      paraview "$@"
    ```

``` bash
$ sudo singularity build paraview.sif paraview.def
```

This will download 301 MB and install 500 new packages... It might take some time to complete, but once you are done you will have a container that will run almost everywhere - there is always a catch.

Instead of paraview, modify the definition file to install and run your, not necessarily graphical, program. Few tips: `gnuplot`, `grace`, `blender`, `povray`, `rasmol`  ...

