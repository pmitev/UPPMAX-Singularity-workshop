# Portable BioTools

This setup works on any computer with installed Singularity/Apptainer.


## Setup details (2023.11.01)

[https://github.com/pmitev/UPPMAX-Singularity/tree/main/BioTools](https://github.com/pmitev/UPPMAX-Singularity/tree/main/BioTools)

Avalable on

- Rackham/Bianca: `/sw/apps/pm-tools/latest/rackham/singularity/BioTools/bin`
- Dardel: `/pdc/software/uppmax_legacy/pm-tools/singularity/BioTools/bin`


## Tools in the container
> Note: some tool names are different in the container


| Name      | Package           |
| --------  | --------          |
| blast+    | ncbi-blast+       |
| deeptools | python3-deeptools |



```
abyss               2.3.5+dfsg-2
augustus            3.5.0+dfsg-2
bbmap               39.01+dfsg-2
bcftools            1.16-1
beast2-mcmc         2.7.3+dfsg-1
bedtools            2.30.0+dfsg-3
bioperl             1.7.8-1
bowtie2             2.5.0-3+b2
busco               5.4.4-1
bwa                 0.7.17-7+b2
canu                2.0+dfsg-2+b1
cd-hit              4.8.1-4
cutadapt            4.2-1
delly               1.1.6-1
exonerate           2.4.0-5
fasta3              36.3.8i.14-Nov-2020-1
fastp               0.23.2+dfsg-2+b1
fastqc              0.11.9+dfsg-6
gffread             0.12.7-3
hmmer               3.3.2+dfsg-1
igv                 2.16.0+dfsg-1
infernal            1.1.4-1
jellyfish           2.3.0-15+b3
kisto               0.48.0+dfsg-3
kraken2             2.1.2-2
kraken              1.1.1-4
macs                2.2.7.1-6+b1
mafft               7.505-1
minimap2            2.24+dfsg-3+b1
mrbayes             3.2.7a-6
multiqc             1.14+dfsg-1
ncbi-blast+         2.12.0+ds-3+b1
paml                4.9j+dfsg-4
pbbamtools          2.1.0+dfsg-2
phast               1.6+dfsg-3+b1
picard              2.8.5-1+b1
pilon               1.24-2
python3-deeptools   3.5.1-3
qcumber             2.3.0-2
qiime               2022.11.1-2
quicktree           2.5-5
ray                 2.3.1-7
salmon              1.10.1+ds1-1+b1
samblaster          0.1.26-4
samclip             0.4.0-4
samtools            1.16.1-1
snap-aligner        2.0.2+dfsg-1
snpeff              5.1+d+dfsg-3
spades              3.15.5+dfsg-2
spaln               2.4.13f+dfsg-1
stacks              2.62+dfsg-1
STAR                2.7.11a
stringtie           2.2.1+ds-2
tophat-recondition  1.4-3
trf                 4.09.1-6
trim-galore         0.6.10-1
velvet              1.2.10+dfsg1-8
vmatch              2.3.1+dfsg-8
vsearch             2.22.1-1
wham-align          0.1.5-8
```

    
## Setup on new location
1. Bring the `BioTools-ubuntu.sif` container to your project folder.
2. Create links for the installed tools in sub-folder `bin`.
    ```bash
    # Navigate to the folder where the bin folder with tools will be created
    # Avoid soft links in the folder location!!!
    cd your_folder
    
    # Run the script
    singularity exec BioTools-debian.sif /opt/make_links.sh
    ```
3. Add the path to your environment $PATH
    ```bash
    export PATH=$PATH:your_folder/bin
    ```
4. Check the tool versions in the container
    ```bash
    singularity exec BioTools-debian.sif /opt/package-versions.sh
    ```
## Test / running
```bash
$ blastp -version
blastp: 2.12.0+
 Package: blast 2.12.0, build Mar  8 2022 16:19:08

$ bwa 
Program: bwa (alignment via Burrows-Wheeler transformation)
Version: 0.7.17-r1188

$ bcftools --version-only
1.13+htslib-1.13+ds

$ busco -v 
BUSCO 5.2.2

$ STAR --version
2.7.10a

$ igv
...
```
![](../images/igv.png)