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

cat <<EOF > /etc/profile.d/conda-env.sh
# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/miniconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/opt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/opt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
EOF

%runscript
  source /etc/profile.d/conda-env.sh
  /bin/bash $@
```

### pip

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



## Downloading large files

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