# ORFfinder on Rackham (CentOS7.x)

The tool is distributed precompiled [here](https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/linux-i64/), but from the [release log](https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/CHANGELOG.txt) one can read:

> 02/26/2017 - v 0.4.3  
Built with statically linked libstdc++  
(on issue of GCC-4.9 libraries not yet supported on CentOS7)

It means that the tool will not run on Rackhama and Bianca, which currently are running CentOS7.

Here is a simple Singularity recipe that will provide newer environment with the necessary libraries...

```singularity
Bootstrap: docker
From: rockylinux:8.5

%environment
  export LC_ALL=C

%post
  export LC_ALL=C

  yum update -y && yum install -y libuv wget gzip libnghttp2 && yum clean all

  wget -P /tmp -c https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/ORFfinder/linux-i64/ORFfinder.gz
  gunzip -k -f /tmp/ORFfinder.gz
  mv /tmp/ORFfinder /usr/bin/
  chmod +x /usr/bin/ORFfinder

%runscript
  /usr/bin/ORFfinder "$@"
```

Then you can build and name the container to have the same name so you can run it seemingly.

```bash
$ sudo singularity build ORFfinder Singularity.def
```

```bash
$ ./ORFfinder -h 
USAGE
  ORFfinder [-h] [-help] [-xmlhelp] [-in Input_File] [-id Accession_GI]
    [-b begin] [-e end] [-c circular] [-g Genetic_code] [-s Start_codon]
    [-ml minimal_length] [-n nested_ORFs] [-strand Strand] [-out Output_File]
    [-outfmt output_format] [-logfile File_Name] [-conffile File_Name]
    [-version] [-version-full] [-version-full-xml] [-version-full-json]
    [-dryrun]

DESCRIPTION
   Searching open reading frames in a sequence

Use '-help' to print detailed descriptions of command line arguments
```