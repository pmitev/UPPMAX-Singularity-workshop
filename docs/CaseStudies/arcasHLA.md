# arcasHLA in Singularity

Here is the tool's [GitHub](https://github.com/RabadanLab/arcasHLA) with rather elaborate dependency list.


!!! note
    ## Dependencies:
    ### arcasHLA requires the following utilities:
    - Git Large File Storage
    - coreutils

    ### Make sure the following programs are in your PATH:

    - Samtools v1.19
    - bedtools v2.27.1
    - pigz v2.3.1
    - Kallisto v0.44.0
    - Python 3.6
    
    ### arcasHLA requires the following Python modules:
    - Biopython v1.77 (or lower)
    - NumPy
    - SciPy
    - Pandas

This requires some reasonable efforts to setup. It is doable but if you need to setup this on multiple locations or for multiple users... it becomes unbearable.  

The developers of the tool has provided [Dockerfile](https://github.com/RabadanLab/arcasHLA/blob/master/Docker/Dockerfile) which is perfect guide for installation, by the way. The container is not available to pull from DockerHub so you need to build it yourself and convert it to Sinfularity ([relevant info here](../docker2singularity.md)) or rewrite the recipe for Singularity following the original -  there are tools but it is not that difficult. here it is:

```singularity
Bootstrap: docker
From: ubuntu:18.04

%labels
  Author pmitev@gmail.com

%environment
  export LC_ALL=C

%post
  export DEBIAN_FRONTEND=noninteractive
  export LANG=C.UTF-8
  export LC_ALL=C.UTF-8

  export kallisto_version=0.44.0
  export samtools_version=1.9
  export bedtools_version=2.29.2
  export biopython_version=1.77  

  mkdir -p /tmp/apt
  echo "Dir::Cache "/tmp/apt";" > /etc/apt/apt.conf.d/singularity-cache.conf

  apt-get update && \
  apt-get  -y --no-install-recommends install \
    build-essential \
    cmake \
    automake \
    zlib1g-dev \
    libhdf5-dev \
    libnss-sss \
    curl \
    autoconf \
    bzip2 \
    python3-dev \
    python3-pip \
    python \
    pigz \
    git \
    libncurses5-dev \
    libncursesw5-dev \
    libbz2-dev \
    liblzma-dev \
    bzip2 \
    unzip

  python3 -m pip install --upgrade pip setuptools 
  python3 -m pip install --upgrade numpy scipy pandas biopython==${biopython_version}
  
  # install kallisto
  mkdir -p /usr/bin/kallisto \
    && curl -SL https://github.com/pachterlab/kallisto/archive/v${kallisto_version}.tar.gz \
    | tar -zxvC /usr/bin/kallisto

  mkdir -p /usr/bin/kallisto/kallisto-${kallisto_version}/build
  cd /usr/bin/kallisto/kallisto-${kallisto_version}/build && cmake ..
  cd /usr/bin/kallisto/kallisto-${kallisto_version}/ext/htslib && autoreconf
  cd /usr/bin/kallisto/kallisto-${kallisto_version}/build && make -j4
  cd /usr/bin/kallisto/kallisto-${kallisto_version}/build && make install

  # install samtools
  cd /usr/bin/
  curl -SL https://github.com/samtools/samtools/releases/download/${samtools_version}/samtools-${samtools_version}.tar.bz2  > samtools-${samtools_version}.tar.bz2
  tar -xjvf samtools-${samtools_version}.tar.bz2 &&   cd /usr/bin/samtools-${samtools_version} && ./configure && make -j4 && make install

  # install bedtools
  cd  /usr/bin
  curl -SL https://github.com/arq5x/bedtools2/releases/download/v${bedtools_version}/bedtools-${bedtools_version}.tar.gz > bedtools-${bedtools_version}.tar.gz
  tar -xzvf bedtools-${bedtools_version}.tar.gz && cd /usr/bin/bedtools2 && make -j4 && ln -s /usr/bin/bedtools2/bin/bedtools /usr/bin/bedtools


  # git lfs
  curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash
  apt-get install -y git-lfs 
  git lfs install --system --skip-repo


  cd /opt
  git clone --recursive https://github.com/RabadanLab/arcasHLA.git arcasHLA-master

  rm /etc/apt/apt.conf.d/singularity-cache.conf

%runscript
  if command -v $SINGULARITY_NAME > /dev/null 2> /dev/null; then
    exec $SINGULARITY_NAME "$@"
  else
    echo "# ERROR !!! Command $SINGULARITY_NAME not found in the container"
  fi
```

Now, you can easily avoid some unnecessary repetitive installations of multiple tools...
 
With a small trick in the `%runscript` section, you can make soft links, and you will be able to run other tools from the container - look here for [more](../indirect-call.md) information.
