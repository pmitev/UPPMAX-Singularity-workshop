# Try to compile Singularity recipe

Here is a real life example - you want to run `gapseq` tool with Singularity.
<https://gapseq.readthedocs.io/en/latest/install.html>  
> `gapseq` is a program for the prediction and analysis of metabolic pathways and genome-scale networks.

- Create new folder for this project.
- Use the Ubuntu installation instructions.

``` bash linenums="1"
sudo apt install ncbi-blast+ git libglpk-dev r-base-core exonerate bedtools barrnap bc
R -e 'install.packages(c("data.table", "stringr", "sybil", "getopt", "reshape2", "doParallel", "foreach", "R.utils", "stringi", "glpkAPI", "CHNOSZ", "jsonlite"))'
R -e 'if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager"); BiocManager::install("Biostrings")'
git clone https://github.com/jotech/gapseq && cd gapseq
```


- Do not install the SBML tool (_not in the above instructions anyway_).
- Think (discuss) where to clone the GitHUB repository from line 4.  
  Note that this particular tool downloads external data into the repository structure, which does not work if you include add the repository in the container itself (the common container format is read-only). Thus, the cloning of the repository should be done in your home or project folder where you can run the program with the long syntax i.e.
  ``` bash
  $ singularity exec ../gapseq.sif ./gapseq doall toy/ecoli.fna.gz
  ```
- Start the build and save the output to a file to track down potential errors 
  ``` bash
  $ sudo singularity build ... |& tee build.log
  ```
- Clone the git repository - line 4
  ``` bash
  $ git clone https://github.com/jotech/gapseq && cd gapseq
  ```
- Test the container by running the tool that will start the `gapseq` tool from the github repository.
  ```
  $ singularity exec ../gapseq.sif ./gapseq
  ``` 
  

??? note "output"
    ``` 
    $ singularity exec ../gapseq.sif ./gapseq
       __ _  __ _ _ __  ___  ___  __ _ 
      / _` |/ _` | '_ \/ __|/ _ \/ _` |
     | (_| | (_| | |_) \__ \  __/ (_| |
      \__, |\__,_| .__/|___/\___|\__, |
      |___/      |_|                |_|
    
    Informed prediction and analysis of bacterial metabolic pathways     and genome-scale networks
    
    Usage:
      gapseq test
      gapseq (find | find-transport | draft | fill | doall | adapt) (..    .)
      gapseq doall (genome) [medium] [Bacteria|Archaea]
      gapseq find (-p pathways | -e enzymes) [-b bitscore] (genome)
      gapseq find-transport [-b bitscore] (genome)
      gapseq draft (-r reactions | -t transporter -c genome -p     pathways) [-b pos|neg|archaea|auto]
      gapseq fill (-m draft -n medium -c rxn_weights -g rxn_genes)
      gapseq adapt (add | remove) (reactions,pathways) (model)
    
    Examples:
      gapseq test
      gapseq doall toy/ecoli.fna.gz
      gapseq doall toy/myb71.fna.gz dat/media/TSBmed.csv
      gapseq find -p chitin toy/myb71.fna.gz
      gapseq find -p all toy/myb71.fna.gz
      gapseq find-transport toy/myb71.fna.gz
      gapseq draft -r toy/ecoli-all-Reactions.tbl -t toy/    ecoli-Transporter.tbl -c toy/ecoli.fna.gz -p toy/    ecoli-all-Pathways.tbl
      gapseq fill -m toy/ecoli-draft.RDS -n dat/media/ALLmed.csv -c     toy/ecoli-rxnWeights.RDS -g toy/ecoli-rxnXgenes.RDS
      gapseq adapt add 14DICHLORBENZDEG-PWY toy/myb71.RDS
    
    Options:
      test            Testing dependencies and basic functionality of     gapseq.
      find            Pathway analysis, try to find enzymes based on     homology.
      find-transport  Search for transporters based on homology.
      draft           Draft model construction based on results from     find and find-transport.
      fill            Gap filling of a model.
      doall           Combine find, find-transport, draft and fill.
      adapt           Add or remove reactions or pathways.
      -v              Show version.
      -h              Show this screen.
      -n              Enable noisy verbose mode.
    ```

- Try to run `singularity exec ../gapseq.sif ./gapseq test`. Did it pass the tests? What is wrong? The output below shows an output with solved R packages tests. The second problem is related to the repository itself.

??? note "output"
    ```
    $ singularity exec ../gapseq.sif ./gapseq test
    gapseq version: 1.1 7c25ca2
    linux-gnu
    #74-Ubuntu SMP Wed Jan 27 22:54:38 UTC 2021 
    
    #######################
    #Checking dependencies#
    #######################
    GNU Awk 5.0.1, API: 2.0 (GNU MPFR 4.0.2, GNU MP 6.2.0)
    sed (GNU sed) 4.7
    grep (GNU grep) 3.4
    This is perl 5, version 30, subversion 0 (v5.30.0) built for     x86_64-linux-gnu-thread-multi
    tblastn: 2.9.0+
    exonerate from exonerate version 2.4.0
    bedtools v2.27.1
    barrnap 0.9 - rapid ribosomal RNA prediction
    R version 3.6.3 (2020-02-29) -- "Holding the Windsock"
    R scripting front-end version 3.6.3 (2020-02-29)
    git version 2.25.1
    
    Missing dependencies: 0
    
    
    
    #####################
    #Checking R packages#
    #####################
    data.table 1.14.0 
    stringr 1.4.0 
    sybil 2.1.5 
    getopt 1.20.3 
    reshape2 1.4.4 
    doParallel 1.0.16 
    foreach 1.5.1 
    R.utils 2.10.1 
    stringi 1.5.3 
    glpkAPI 1.3.2 
    BiocManager 1.30.10 
    Biostrings 2.54.0 
    jsonlite 1.7.2 
    CHNOSZ 1.4.0 
    
    Missing R packages:  0 
    
    ##############################
    #Checking basic functionality#
    ##############################
    Optimization test: OK 
    Command line argument error: Argument "query". File is not     accessible:  `/opt/gapseq/src/../dat/seq/Bacteria/rev/1.2.4.1.    fasta'
    Blast test: FAILED
    
    Passed tests: 1/2
    ```
    
Here is a working recipe for the exercise:  
<https://github.com/pmitev/UPPMAX-Singularity/tree/main/gapseq>