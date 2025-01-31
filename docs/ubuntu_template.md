# Tips collected in an template 
>  Ubuntu definition file

```singularity
Bootstrap: docker
From: ubuntu:24.04

%environment
  export LC_ALL=C.utf8          
  export PYTHONNOUSERSITE=True  # Disable user's local python modules in ~/.local
  # Fix to be able to activate conda environment in the shell
  # export SINGULARITY_SHELL=/bin/bash
  # set -- --init-file /opt/etc/bashrc

%post
  export LC_ALL=C.utf8
  export PYTHONNOUSERSITE=True
  export DEBIAN_FRONTEND=noninteractive

  # apt packages cached in /tmp
  mkdir -p /tmp/apt24 &&  echo "Dir::Cache "/tmp/apt24";" > /etc/apt/apt.conf.d/singularity-cache.conf

  apt-get update && apt-get -y dist-upgrade && \
  apt-get install -y git


  # Download
  # export TMPD=/tmp/downloads &&   mkdir -p $TMPD
  # wget -P $TMPD -c  ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/technical/reference/human_g1k_v37.fasta.gz
  # gunzip -c $TMPD/human_g1k_v37.fasta.gz > human_g1k_v37.fasta || true


  # Miniforge3
  # export TMPD=/tmp/downloads &&   mkdir -p $TMPD
  # wget -P $TMPD -c https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh && \
  # sh $TMPD/Miniforge3-Linux-x86_64.sh -b -p /opt/miniforge3
  # mkdir -p /opt/etc
  # echo "source /opt/miniforge3/etc/profile.d/conda.sh" >> /opt/etc/bashrc
  # echo "source /opt/miniforge3/etc/profile.d/mamba.sh" >> /opt/etc/bashrc


  # pip cache in /tmp
  # export PIP_TMP=/tmp/pip-cache ;  mkdir -p $PIP_TMP
  # python3 -m pip install --cache-dir $PIP_TMP --upgrade pip setuptools wheel

  # pip without caching
  # python3 -m pip install --no-cache-dir       --upgrade pip setuptools wheel


  # Sourcing file when running/executing the container
  # Note: function declarations are not preserved in the subsequent bash shell
  # cp /usr/local/gromacs/bin/ACTRC.bash   /.singularity.d/env/99-ACTRC.sh

# cat to a file
#cat << EOF > /tmp/myfile
# ...
#EOF

# Run in bash sub-shell
#/bin/bash <<EOF
# ...
#EOF
  
  # Patch for old kernels and Qt5
  # strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5 

%runscript
#!/bin/sh
  if command -v $SINGULARITY_NAME > /dev/null 2> /dev/null; then
    exec $SINGULARITY_NAME "$@"
  else
    echo "# ERROR !!! Command $SINGULARITY_NAME not found in the container"
  fi
```
