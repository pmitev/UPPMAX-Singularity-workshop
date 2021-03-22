# Common good or bad practices for building Singularity containers

_Discalmer: these might not be the best solutions at all._

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

  # Clen the installation folder (unless you want to keep it)
  rm -rf /installs
```

- dedicate a folder in the container's file structure
- fetch your installation files there (look how this might be improved for large files downloaded with `wget`)
- install in /opt and adjust the `$PATH`  
  or just allow the tool to mix with the system files.

## Conda

``` singularity
%environment
  export CONDA_ENVS_PATH=/opt/conda_envs

%post
  export CONDA_ENVS_PATH=/opt/conda_envs &&  mkdir -p ${CONDA_ENVS_PATH}

  mkdir /installs && cd /installs

  mconda="Miniconda3-py38_4.9.2-Linux-x86_64.sh"
  wget https://repo.anaconda.com/miniconda/${mconda} && \
  chmod +x ${mconda} && \
  ./${mconda} -b -p /opt/miniconda3 && \
  ln -s /opt/miniconda3/bin/conda /usr/bin/conda

  conda env create -f /env.yaml
```

## Downloading packages and files multiple times.

### Package installation - apt, yum, etc...

Even if you use `--sandbox` you might find that some commands does not behave the same way as when executed by the common routines `sudo build...`. Some of this problems are related to the shell interpreter which might be `sh` or `bash`...

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



``` singularity hl_lines="2-3 13" linenums="1"
%post
  mkdir -p /tmp/apt
  echo "Dir::Cache "/tmp/apt";" > /etc/apt/apt.conf.d/singularity-cache.conf

  apt-get update && \
  apt-get -y install  wget unzip git bwa samtools
  # the usual clean up
  rm -rf /var/lib/apt/lists/*

  ...

  # remove the /tmp caching configuration
  rm /etc/apt/apt.conf.d/singularity-cache.conf
```

!!! note
    Remember to remove these lines in the final recipe.
