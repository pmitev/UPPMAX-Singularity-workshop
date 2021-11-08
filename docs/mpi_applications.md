# Singularity and MPI applications

The Singularity documentation is excellent starting point - [link](https://sylabs.io/guides/3.8/user-guide/mpi.html)

The C3SE Singularity has really nice summary that is included bellow - [source](https://www.c3se.chalmers.se/documentation/applications/containers-advanced/#running-singularity-with-mpi-across-multiple-nodes)

## **Running singularity with MPI across multiple nodes**
- There are four main components involved in a containerised MPI-based application:  
:   1.The executable MPI program (e.g. a.out)  
    2.The MPI library  
    3.MPI runtime, e.g. mpirun  
    4.Communication channel, e.g. SSH server

- Depending on how to containerise those elements, there are two general approaches to running a containerised application across a multi-node cluster:  
:   1.Packaging the MPI program and the MPI library inside the container, but keeping the MPI runtime outside on the host  
    2.Packaging the MPI runtime also inside the container leaving only the communication channel on the host

## **Host-based MPI runtime**
In this approach, the mpirun command runs on the host: `$ mpirun singularity run myImage.sif myMPI_program`

mpirun does, among other things, the following: * Spawns the ORTE daemon on the compute nodes * Launches the MPI program on the nodes * Manages the communication among the MPI ranks

This fits perfectly with the regular workflow of submitting jobs on the HPC clusters, and is, therefore, **the recommended approach**. There is one thing to keep in mind however:  
The MPI runtime on the host needs to be able to communicate with the MPI library inside the container; therefore,  
:   i) there must be the same implementation of the MPI standard (e.g. OpenMPI) inside the container, and,  
    ii) the version of the two MPI libraries should be as close to one another as possible to prevent unpredictable behaviour (ideally the exact same version).

## **Image-based MPI runtime**
- In this approach, the MPI launcher is called from within the container; therefore, it can even run on a host system without an MPI installation (your challenge would be to find one!):  
 `$ singularity run myImage.sif mpirun myMPI_program`
- Everything works well on a single node. There's a problem though: as soon as the launcher tries to spawn into the second node, the ORTED process crashes. The reason is it tries to launch the MPI runtime on the host and not inside the container.
- The solution is to have a launch agent do it inside the container. With OpenMPI, that would be:  
`$ singularity run myImage.sif mpirun --launch-agent 'singularity run myImage.sif orted' myMPI_program`

## **Example - running conteinerized gromacs in parallel**

Here is a simple setup to build and test simple Singularity container with Gromacs with binaries for OpenMPI parallelization provided with the Ubuntu 20.04 distribution.

``` singularity
Bootstrap: docker
From: ubuntu:20.04

%setup

%files

%environment
  export LC_ALL=C

%post
  export LC_ALL=C
  export DEBIAN_FRONTEND=noninteractive

  apt-get update && apt-get -y dist-upgrade && apt-get install -y git wget gawk cmake build-essential libopenmpi-dev openssh-client gromacs-openmpi

%runscript
  /usr/bin/mdrun_mpi "$@"
```

At the time of writing this page, the recipe will install

- GROMACS - mdrun_mpi, 2020.1-Ubuntu-2020.1-1
- mpirun (Open MPI) 4.0.3

!!! note
    Keep in mind that the binaries provided by the package manager are not optimized for the CPU and you could read such message in the output:
    > Compiled SIMD: SSE2, but for this host/run AVX2_256 might be better (see log).
    The current CPU can measure timings more accurately than the code in
    mdrun_mpi was configured to use. This might affect your simulation
    speed as accurate timings are needed for load-balancing.
    Please consider rebuilding mdrun_mpi with the GMX_USE_RDTSCP=ON CMake option.
    Reading file benchMEM.tpr, VERSION 4.6.3-dev-20130701-6e3ae9e (single precision)
    Note: file tpx version 83, software tpx version 119

We can use [A free GROMACS benchmark set](https://www.mpibpc.mpg.de/grubmueller/bench) to perform tests with this [set](https://www.mpibpc.mpg.de/15101317/benchMEM.zip).

### Running on single node

#### Image-based MPI runtime

``` bash
# Run shell in the container
$ singularity shell Gromacs-openmpi.sif

# 2 MPI processes, 4 OpenMP threads per MPI process
Singularity> mpirun -n 2 mdrun_mpi -ntomp 4 -s benchMEM.tpr -nsteps 10000 -resethway
```

#### Host-based MPI runtime

On my host which runs Ubuntu 20.04 the OpenMPI version is identical. On other machines you need to make sure to run compatible version. On HPC clusters this should be module which provides OpenMPI compiled with gcc.
``` bash
$ mpirun -n 2 singularity exec Gromacs-openmpi.sif /usr/bin/mdrun_mpi -ntomp 4 -s benchMEM.tpr -nsteps 10000 -resethway

# or relying on the runscript
$ mpirun -n 2 Gromacs-openmpi.sif -ntomp 4 -s benchMEM.tpr -nsteps 10000 -resethway
```

#### Compiling Gromacs

> Note: the recipe bellow uses the OpenMPI from the distribution that triggers "Segmentation fault" problems when running the container on Rackham@UPPMAX.

??? note "recipe"
    ``` singularity
    Bootstrap: docker
    From: ubuntu:20.04
    
    %setup
    
    %files
    
    %environment
      export LC_ALL=C
    
    %post
      export LC_ALL=C
      export DEBIAN_FRONTEND=noninteractive
      export NCPU=$(grep -c ^processor /proc/cpuinfo)
    
      apt-get update && apt-get -y dist-upgrade && apt-get install -y git wget gawk cmake build-essential libopenmpi-dev openssh-client
    
      mkdir -p installs
    
      # Gromacs
      mkdir -p /tmp/downloads && cd /tmp/downloads
      test -f gromacs-2021.2.tar.gz || wget https://ftp.gromacs.org/gromacs/gromacs-2021.2.tar.gz
      tar xf gromacs-2021.2.tar.gz -C /installs
    
      cd /installs/gromacs-2021.2
      mkdir build-normal && cd build-normal
      cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gromacs-2021.2 -DGMX_GPU=OFF -DGMX_MPI=ON -DGMX_THREAD_MPI=ON -DGMX_BUILD_OWN_FFTW=ON -DGMX_DOUBLE=OFF -DGM
    X_PREFER_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RELEASE
      make -j $NCPU && make install
    
      cd /installs/gromacs-2021.2
      mkdir build-mdrun-only && cd build-mdrun-only
      cmake .. -DCMAKE_INSTALL_PREFIX=/opt/gromacs-2021.2 -DGMX_GPU=OFF -DGMX_MPI=ON -DGMX_THREAD_MPI=ON -DGMX_BUILD_OWN_FFTW=ON -DGMX_DOUBLE=OFF -DGM
    X_PREFER_STATIC_LIBS=ON -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=RELEASE -DGMX_BUILD_MDRUN_ONLY=ON
      make -j $NCPU && make install
    
      cd /
      rm -r /installs
      rm /etc/apt/apt.conf.d/singularity-cache.conf
    
    %runscript
    #!/bin/bash
      source /opt/gromacs-2021.2/bin/GMXRC
      exec gmx_mpi "$@"
    ```
