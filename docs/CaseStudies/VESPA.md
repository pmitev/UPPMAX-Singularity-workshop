# VESPA: _Very large-scale Evolutionary and Selective Pressure Analyses_
[Project webpage](https://github.com/aewebb80/VESPA)

Here is an example of one very demanding [installation](https://vespa-evol.readthedocs.io/en/latest/installation.html) with plenty of third party software [requirements](https://vespa-evol.readthedocs.io/en/latest/installation.html#third-party-software). Since the environment originally is provided by conda, here we will use `From: continuumio/miniconda3`.

Third party software dependency.

| Program |	Version |	URL |
| ----------- | -------| -- |
|BLAST|	2.2.30+|	ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST |
|DendroPy|4.0|https://pythonhosted.org/DendroPy/#installing |
|MetAL|1.1|http://kumiho.smith.man.ac.uk/blog/whelanlab/?page_id=396|
|MrBayes|3.2.3|http://mrbayes.sourceforge.net/|
|MUSCLE|3.8.21|http://www.drive5.com/muscle/downloads.htm|
|NoRMD|1.3|ftp://ftp-igbmc.u-strasbg.fr/pub/NORMD/|
|PAML|4.4e|http://abacus.gene.ucl.ac.uk/software/paml.html|
|ProtTest3|	3.4|	https://github.com/ddarriba/prottest3|

!!! warning
    **It also requires Python 2.7!**

1. Clone the original repository - there are some binaries that needs to copyed in the container (lines 8 and 9 in the definition file).  
Download manually the third party software packages.
```bash
$ git clone https://github.com/aewebb80/VESPA.git
$ wget -O VESPA.tar.gz https://github.com/aewebb80/VESPA/archive/refs/tags/1.0.1.tar.gz
$ wget https://github.com/NBISweden/MrBayes/releases/download/v3.2.3/mrbayes-3.2.3.tar.gz
$ wget https://github.com/ddarriba/prottest3/releases/download/3.4.2-release/prottest-3.4.2-20160508.tar.gz
$ wget http://www.bork.embl.de/Docu/AQUA/latest/norMD1_3.tar.gz
```
2. Here is the Singularity definition file
``` singularity linenums="1"
Bootstrap: docker
From: continuumio/miniconda3

%files
  VESPA.tar.gz /
  mrbayes-3.2.3.tar.gz /
  prottest-3.4.2-20160508.tar.gz /
  VESPA/executables/Linux/normd /usr/local/bin
  VESPA/executables/Linux/metal /usr/local/bin
  vespa.yaml /

%environment
  export LC_ALL=C
  export PROTTEST_HOME=/opt/prottest-3.4.2


%post
  export LC_ALL=C
  export PROTTEST_HOME=/opt/prottest-3.4.2
  export DEBIAN_FRONTEND=noninteractive

  mkdir -p /tmp/apt
  echo 'Dir::Cache /tmp/apt;'  > /etc/apt/apt.conf.d/singularity-cache.conf

  apt-get update; apt-get -y dist-upgrade && apt-get install -y wget git ant perl build-essential cmake openjdk-11-jdk autoconf

  # VESPA -----------------------------------------------
  cd /opt ; tar -xvf /VESPA.tar.gz 
  cd VESPA-1.0.1; chmod +x vespa.py ; cp vespa.py /usr/local/bin
  chmod +x *Codeml*.pl ; cp *Codeml*.pl /usr/local/bin ; cp -a CodemlWrapper/ /usr/share/perl/5.32


  # Beagle ----------------------------------------------
  cd /opt
  #export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
  git clone --depth=1 https://github.com/beagle-dev/beagle-lib.git
  cd beagle-lib && mkdir build; cd build 
  cmake ..
  make install

  # MrBayes ---------------------------------------------
  cd /opt ; tar -xvf /mrbayes-3.2.3.tar.gz
  cd mrbayes_3.2.3/src && autoconf && ./configure LDFLAGS="-Wl,--allow-multiple-definition" && make install 

  # prottest3 ------------------------------------------
  cd /opt
  tar -xvf /prottest-3.4.2-20160508.tar.gz 

  # Conda ----------------------------------------------
  conda update -n base -c defaults conda
  #conda install -c conda-forge pip mamba

  conda env create -f /vespa.yaml -n VESPA
  echo "conda activate VESPA" >> /opt/conda/etc/profile.d/conda.sh

  conda clean --all --yes
  rm /*.tar.gz

%runscript
   params="$@"
  /bin/bash --rcfile /opt/conda/etc/profile.d/conda.sh -ic "vespa.py $params"
```
and the adapted `vespa.yaml` conda enviroment file.
```conda
name: vespa27
channels:
  - defaults
dependencies:
  - conda-forge::python=2.7
  - conda-forge::numba
  - conda-forge::h5py
  - bioconda::blast=2.2.31
  - bioconda::dendropy=4.2.0
  - bioconda::muscle=3.8.31
  - bioconda::paml
```

Note, how conda environment `VESPA` is activated (_first line 54, then line 61_) to run the tool within the environment.