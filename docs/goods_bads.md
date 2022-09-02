# Common good or bad practices for building Singularity containers

_Disclaimer: these might not be the best solutions at all._

## Where to compile and install source codes.

There are some, not so easy to see, complications. `/tmp` looks like good choice... The problem is that /tmp is mounted automatically even during the build process. This means that you will collide with leftovers from previous builds which might lead to rather unexpected results. We will use this problematic behavior in the next section for our advantage.

`$HOME` points to `/root` during build, and it is also mounted at build time. Really bad place to compile!

> So... Where is a good place to compile and install?

Here is an example scenario

``` singularity hl_lines="2 5 7" linenums="1"
%environment
  export PATH=/opt/tool-name/bin:${PATH}

%post
  mkdir -p /installs && cd /installs
  git clone repository-link && cd tool-name
  ./configure --prefix=/opt/tool-name
  make && make install

...

  # Clean the installation folder (unless you want to keep it)
  rm -rf /installs
```

- dedicate a folder in the container's file structure
- fetch your installation files there (look how this might be improved for large files downloaded with `wget`)
- install in /opt and adjust the `$PATH`  
  or just allow the tool to mix with the system files.

## **Conda**

Conda causes some unexpected problems. During the build and and the commands in `%runscrupt` sections are run with `/bin/sh` which fails upon `source /full_path_to/conda.sh` which in turn fails `conda activate my_environment`. Her are two examples how to deal with the situation.

!!! note "docker://continuumio/miniconda3 container"

    ``` singularity linenums="1"
    Bootstrap: docker
    From: continuumio/miniconda3

    %environment
      export LC_ALL=C
    
    %post
      export LC_ALL=C
    
      conda config --add channels defaults
      conda config --add channels conda-forge
      conda config --add channels bioconda
      conda config --add channels ursky
      conda create --name metawrap-env --channel ursky metawrap-mg=1.3.2 tbb=2020.2
    
      conda clean --all --yes
    
    %runscript
      params=$@
    /bin/bash <<EOF
      source /opt/conda/etc/profile.d/conda.sh
      conda activate metawrap-env
      metawrap $params
    EOF
    ```

??? note "Ubuntu + conda"
    ``` singularity linenums="1"
    Bootstrap: docker
    From: ubuntu:20.04
    
    %labels
      Author pmitev@gmail.com
    
    %environment
      export LC_ALL=C
      export CONDA_ENVS_PATH=/opt/conda_envs
      export PATH=/opt/metaWRAP/bin:$PATH
    
    %post
      export DEBIAN_FRONTEND=noninteractive
      export LC_ALL=C
      export CONDA_ENVS_PATH=/opt/conda_envs &&  mkdir -p ${CONDA_ENVS_PATH}
    
      apt-get update && apt-get -y install  wget git
    
      mkdir /installs && cd /installs
    
      # Conda installation     ==============================================
      mconda="Miniconda3-py38_4.9.2-Linux-x86_64.sh"
      wget https://repo.anaconda.com/miniconda/${mconda} && \
      chmod +x ${mconda} && \
      ./${mconda} -b -p /opt/miniconda3 && \
      ln -s /opt/miniconda3/bin/conda /usr/bin/conda
    
      # metaWRAP dependencies installation     ==============================
    /bin/bash <<EOF
      source /opt/miniconda3/etc/profile.d/conda.sh
    
      conda create -y -n metawrap-env python=2.7
      conda activate metawrap-env
      
      conda config --add channels defaults
      conda config --add channels conda-forge
      conda config --add channels bioconda
      conda config --add channels ursky
    
      conda install --only-deps -c ursky metawrap-mg
    
      conda clean --all --yes
    EOF
    
      # metaWRAP from github     ============================================
      cd /opt
      git clone https://github.com/bxlab/metaWRAP.git
    
      cd / && rm -r /installs
    
    %runscript
      params=$@
    /bin/bash <<EOF
      export PATH=/opt/metaWRAP/bin:$PATH
      source /opt/miniconda3/etc/profile.d/conda.sh
      conda activate metawrap-env
      metawrap $params
    EOF
    ```


### **pip**

Install only the minimum python (`python3-dev`) from the distribution package manager and the equivalent for `build-essential`. The rest should be perhaps better done by `pip`. Some libraries might still be needed.

## Downloading packages and files multiple times.

### Package installation - apt, yum, etc...

Even if you use `--sandbox` you might find that some commands do not behave the same way as when executed by the common routines `sudo build...`. Some of these problems are related to the shell interpreter which might be `sh` or `bash`...

!!! warning
    This nice file fetching trick will work interactively when you test but it will fail during the build
    ```
    wget -P bcftools/plugins https://raw.githubusercontent.com/freeseek/gtc2vcf/master/{gtc2vcf.{c,h},affy2vcf.c}
    ```
    It needs to be tricked a bit.
    ```
    /bin/bash -c 'wget -P bcftools/plugins https://raw.githubusercontent.com/freeseek/gtc2vcf/master/{gtc2vcf.{c,h},affy2vcf.c}'
    ```

Now, if you find yourself repeatedly rebuilding your definition file... and you find that every time you need to re-download packages from the repositories... Some hosting services might slow you down or even block you upon repetitive downloads...



``` singularity hl_lines="2-3 12-13" linenums="1"
%post
  mkdir -p /tmp/apt
  echo "Dir::Cache "/tmp/apt";" > /etc/apt/apt.conf.d/singularity-cache.conf

  apt-get update && \
  apt-get --no-install-recommends -y install  wget unzip git bwa samtools
  # the usual clean up
  rm -rf /var/lib/apt/lists/*

  ...

  # remove the /tmp/apt caching configuration
  rm /etc/apt/apt.conf.d/singularity-cache.conf
```

!!! note
    - **Remember to remove these lines in the final recipe.**
    - note the `--no-install-recommends` which can save on installing unnecessary packages. It is rather popular option.



## **Downloading large files**

The example bellow is from the installation instructions for https://github.com/freeseek/gtc2vcf.

Here is the original code, which downloads the 871MB file and extracts it on the fly. Then some indexing is applied.
```
wget -O- ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz | \
  gzip -d > $HOME/GRCh37/human_g1k_v37.fasta
samtools faidx $HOME/GRCh37/human_g1k_v37.fasta
bwa index $HOME/GRCh37/human_g1k_v37.fasta
```

The file is rather large for multiple downloads... we could rewrite a bit the lines like this and keep the original file during builds.

``` singularity
%post

  export TMPD=/tmp/downloads
  mkdir -p $TMPD

  # Install the GRCh37 human genome reference =======================================
  mkdir -p /data/GRCh37 && cd /data/GRCh37

  wget -P $TMPD -c  ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz
  gunzip -c $TMPD/human_g1k_v37.fasta.gz > human_g1k_v37.fasta || true

  samtools faidx /data/GRCh37/human_g1k_v37.fasta
  bwa index /data/GRCh37/human_g1k_v37.fasta || true
```
!!! note
    `gunzip` is returning non-zero exit code which signals an error and the Singularity build will stop. The not so nice solution is to apply the `|| true` "trick" to ignore the error. Similar for the `bwa` tool.

!!! warning
    The `samtools` and `bwa` are computationally intensive, memory demanding, and time demanding. This will conflict with some of the limitations of the free online building services. You might consider doing this outside the container and only copy the files (the uncompressed result is even larger) or better - as in the original instructions they will be installed in the user's `$HOME` directory.

Have look for alternative advanced ideas - [Image Mounts](https://sylabs.io/guides/3.7/user-guide/bind_paths_and_mounts.html#image-mounts)


## **Installing R and libraries**

!!! warning
    If you are using `vagrand` to run Singularity, keep in mind that installing R libraries often might need more than 4GB memory, which needs increasing the memory of the instance. Inspect the build log for failures... singularity does not catch them and continues building...

Here are some tips (_try them but they might be autdated_).

``` singularity
Bootstrap: docker
From: ubuntu:20.04

%post

  # R-CRAN
  apt-get -y  install dirmngr gnupg apt-transport-https ca-certificates software-properties-common
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/'
  apt-get update && apt-get -y  install r-base

  # Add a default CRAN mirror
  echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site

  # Rstudio
  wget -P /tmp/ -c https://download1.rstudio.org/desktop/bionic/amd64/rstudio-2021.09.1-372-amd64.deb
  apt-get -y install /tmp/rstudio-2021.09.1-372-amd64.deb

  # Fix R package libpaths (helps RStudio Server find the right directories)
  mkdir -p /usr/lib64/R/etc
  echo "R_LIBS_USER='/usr/lib64/R/library'" >> /usr/lib64/R/etc/Renviron

  # Install reticulate 
  Rscript -e 'install.packages("reticulate")'

  # Perhaps miniconda via 
  Rscript -e 'reticulate::install_miniconda()'

```

Here you can find more detailed instructions related to different ideas related to R: [link](https://github.com/CSCfi/singularity-recipes/blob/fc36f908d0e8216f234a6721f6a086a1c53d4e72/r-env-singularity/4.1.1/4.1.1.def).


## **Compiling code...**

... and cleaning the development tools and libraries to slim-down the container.

!!! warning
    Removing the build dependencies, might remove some necessary libraries - you need to install them back if necessary.

``` singularity hl_lines="4 13"
...

# install packages needed for compiling 
deps="wget git make cmake gcc g++ gfortran"
apt-get install -y --no-install-recommends $deps

# install packages needed for OpenGL
apt-get install -y --no-install-recommends mesa-utils ...

# compile some code here

# remove build dependencies
apt-get purge -y --auto-remove $deps

...
```

## **Kernel dependencies**

Nowadays, `glibc`, and probably other libraries, occasionally take advantage of new kernel syscalls. Singulariy images run with the host machine's kernel.  
Debian 9 has an old enough `glibc` to not have many features that would only work on newer machines, and the other packages are new enough to compile all of these dependencies. Consider `FROM debian:9` or `FROM ubuntu:18.04` to address such problems.