# Indirect executable calls

The common approach for Singularity is to have single entry point defined by `%runscript` or by `%app`. This is not so convenient for daily use... So, here is a minimal example on how to implement a well known trick to use single executable for multiple commands (see for example the [BusBox](https://busybox.net/screenshot.html) project).


``` singularity
Bootstrap: docker
From: ubuntu:20.04

%environment
  export LC_ALL=C

%post
  export LC_ALL=C
  export DEBIAN_FRONTEND=noninteractive

  mkdir -p /tmp/apt
  echo "Dir::Cache /tmp/apt;" > /etc/apt/apt.conf.d/singularity-cache.conf

  apt-get update && \
  apt-get --no-install-recommends -y install  wget unzip git bwa samtools bcftools bowtie
  
%runscript
  if command -v $SINGULARITY_NAME &> /dev/null; then
    exec $SINGULARITY_NAME "$@"
  else
    echo "# ERROR !!! Command $SINGULARITY_NAME not found in the container"
  fi
```


Let's build the recipe and make soft links to the executables in the image:
``` bash
sudo singularity build samtools.sif Singularity.samtools

# make bin folder
mkdir -p bin

# Extraxt the executable names from the packages of interest
SIMG=samtools.sif
bins=$(singularity exec ${SIMG} dpkg -L bwa samtools bcftools bowtie | grep /bin/)

# Make softlinks pointing to the Singularity image
for i in $bins; do echo $i; ln -s ../${SIMG} bin/${i##*/} ; done

# Check what is the content of bin
[09:11:36]> ls -l bin
total 0
lrwxrwxrwx 1 user user 15 Apr  4 09:09 ace2sam -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bcftools -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 blast2sam.pl -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie2sam.pl -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie-align-l -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie-align-l-debug -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie-align-s -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie-align-s-debug -> ../samtools.sif
lrwxrwxrwx 1 user user 15 Apr  4 09:09 bowtie-build -> ../samtools.sif
...
``` 

Let's test the tools (you can add the `bin` folder in `$PATH` if you want...)
``` bash
./bin/bwa 
/usr/bin/bwa

Program: bwa (alignment via Burrows-Wheeler transformation)
Version: 0.7.17-r1188
Contact: Heng Li <lh3@sanger.ac.uk>

Usage:   bwa <command> [options]

Command: index         index sequences in the FASTA format
         mem           BWA-MEM algorithm
         fastmap       identify super-maximal exact matches
         pemerge       merge overlapping paired ends (EXPERIMENTAL)
         aln           gapped/ungapped alignment
         samse         generate alignment (single ended)
         sampe         generate alignment (paired ended)
         bwasw         BWA-SW for long queries
...
```

``` bash
./bin/samtools --help
/usr/bin/samtools

Program: samtools (Tools for alignments in the SAM format)
Version: 1.10 (using htslib 1.10.2-3)

Usage:   samtools <command> [options]

Commands:
  -- Indexing
     dict           create a sequence dictionary file
     faidx          index/extract FASTA
     fqidx          index/extract FASTQ
     index          index alignment
...
```

``` bash
./bin/bcftools --help
/usr/bin/bcftools

Program: bcftools (Tools for variant calling and manipulating VCFs and BCFs)
Version: 1.10.2 (using htslib 1.10.2-3)

Usage:   bcftools [--version|--version-only] [--help] <command> <argument>

Commands:

 -- Indexing
    index        index VCF/BCF files
...
```

We can add other tools that we want from the image...
``` bash
# Make soft link for date
ln -s ../samtools.sif bin/date

# Running date from the image
./bin/date
/usr/bin/date
Mon Apr  4 07:23:16 Europe 2022

# Running date from the container
date
Mon 04 Apr 2022 09:24:12 AM CEST
```

Note the different time zones ;-)