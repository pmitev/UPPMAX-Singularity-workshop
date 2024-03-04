# R.ROSSETTA - Singularity container

Installation instructions [https://komorowskilab.github.io/R.ROSETTA/tutorials.html#installation](https://komorowskilab.github.io/R.ROSETTA/tutorials.html#installation)

The library requires [Wine](https://www.winehq.org/) (compatibility layer capable of running Windows applications) 32 bit...

```bash linenums="1"
Bootstrap: docker
From: ubuntu:22.04

%files
  # Add the file in the container "wine msiexec /i /opt/wine-mono-7.4.0-x86.msi"
  # https://dl.winehq.org/wine/wine-mono/7.4.0/wine-mono-7.4.0-x86.msi
  wine-mono-7.4.0-x86.msi /opt/


%environment
  export LC_ALL=C
  export PYTHONNOUSERSITE=True
  export WINEARCH=win32

%post
  export LC_ALL=C
  export PYTHONNOUSERSITE=True
  export DEBIAN_FRONTEND=noninteractive

  # apt packages cached in /tmp
  mkdir -p /tmp/apt22 &&  echo "Dir::Cache "/tmp/apt22";" > /etc/apt/apt.conf.d/singularity-cache.conf

  dpkg --add-architecture i386
  apt-get update && apt-get -y dist-upgrade 

  # R-CRAN
  apt-get -y  install dirmngr gnupg apt-transport-https ca-certificates software-properties-common
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
  add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/'
  apt-get update && apt-get -y  install r-base

  # Add a default CRAN mirror
  echo "options(repos = c(CRAN = 'https://cran.rstudio.com/'), download.file.method = 'libcurl')" >> /usr/lib/R/etc/Rprofile.site

  # Add a directory for host R libraries
  mkdir -p /library
  echo "R_LIBS_SITE=/library:\${R_LIBS_SITE}" >> /usr/lib/R/etc/Renviron.site

  # Install required build dependencies
  apt-get -y install git wget wine wine32 build-essential \
                    libxml2-dev libfontconfig1-dev libcurl4-openssl-dev \
                    libssl-dev libharfbuzz-dev libfribidi-dev libfreetype6-dev libpng-dev libtiff5-dev libjpeg-dev  
  
  # Follow th einstructions to install the library
Rscript - << EOF
  install.packages("devtools")
  library(devtools)
  install_github("komorowskilab/R.ROSETTA")
  library(R.ROSETTA)
EOF


%runscript
#!/bin/sh
  if command -v $SINGULARITY_NAME > /dev/null 2> /dev/null; then
    exec $SINGULARITY_NAME "$@"
  else
    echo "# ERROR !!! Command $SINGULARITY_NAME not found in the container"
  fi
```

Notes:

- `line 13`: Wine needs to run the 32 bit architecture `export WINEARCH=win32`
- `line 23`: Ubuntu needs to enable 32 bit repositories `dpkg --add-architecture i386`