# Running Singlarity containers from online repositories

Here we will briefly show one example and later try to build our own container and share it online.

``` bash
$ singularity run docker://godlovedc/lolcow

INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
Getting image source signatures
Copying blob 9fb6c798fa41 done  
Copying blob 3b61febd4aef done  
Copying blob 9d99b9777eb0 done  
Copying blob d010c8cf75d7 done  
Copying blob 7fac07fb303e done  
Copying blob 8e860504ff1e done  
Copying config 73d5b1025f done  
Writing manifest to image destination
Storing signatures
...
2021/03/15 11:18:19  info unpack layer: sha256:3b61febd4aefe982e0cb9c696d415137384d1a01052b50a85aae46439e15e49a
2021/03/15 11:18:19  info unpack layer: sha256:9d99b9777eb02b8943c0e72d7a7baec5c782f8fd976825c9d3fb48b3101aacc2
2021/03/15 11:18:19  info unpack layer: sha256:d010c8cf75d7eb5d2504d5ffa0d19696e8d745a457dd8d28ec6dd41d3763617e
2021/03/15 11:18:19  info unpack layer: sha256:7fac07fb303e0589b9c23e6f49d5dc1ff9d6f3c8c88cabe768b430bdb47f03a9
2021/03/15 11:18:19  info unpack layer: sha256:8e860504ff1ee5dc7953672d128ce1e4aa4d8e3716eb39fe710b849c64b20945
INFO:    Creating SIF file...
 __________________________________
/ Someone is speaking well of you. \
|                                  |
\ How unusual!                     /
 ----------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

Let's run it again.
``` bash
$ singularity run docker://godlovedc/lolcow

INFO:    Using cached SIF image
 ___________________________
< You are as I am with You. >
 ---------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```
Note, that singularity, after contacting the repositories, realizes that the container is in the local cache and proceeds to run it. But where is it?

[More details...](https://sylabs.io/guides/3.7/user-guide/singularity_and_docker.html)

``` bash
$ singularity cache list

There are 1 container file(s) using 87.96 MiB and 8 oci blob file(s) using 99.09 MiB of space
Total space used: 187.04 MiB
```
!!! info
    Over time the cache will grow and might easily accumulate unnecessary "blobs". To clean the cache you can run.
    ``` bash
    $ singularity cache clean
    ```
    Here is how the cache might look like:
    ``` bash
    singularity cache clean --dry-run
    User requested a dry run. Not actually deleting any data!
    INFO:    Removing blob cache entry: blobs
    INFO:    Removing blob cache entry: index.json
    INFO:    Removing blob cache entry: oci-layout
    INFO:    No cached files to remove at /home/ubuntu/.singularity/    cache/library
    INFO:    Removing oci-tmp cache entry:     a692b57abc43035b197b10390ea2c12855d21649f2ea2cc28094d18b93360eeb
    INFO:    No cached files to remove at /home/ubuntu/.singularity/    cache/shub
    INFO:    No cached files to remove at /home/ubuntu/.singularity/    cache/oras
    INFO:    No cached files to remove at /home/ubuntu/.singularity/    cache/net
    ```

## More examples

```
$ singularity run docker://dctrud/wttr
```
![output](images/wttr.png)

### Tensorflow 
Let's have some tensorflow running. First `pull` the image from docker hub.

```
$ singularity pull docker://tensorflow/tensorflow:latest-gpu

INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
Getting image source signatures
...
```

If you have a GPU card, here is how easy you can get tensorflow running. Note the `--nv` option on the command line.

---

```
$ singularity exec --nv tensorflow_latest-gpu.sif python3

INFO:    Could not find any nv files on this host!
Python 3.6.9 (default, Oct  8 2020, 12:12:24) 
[GCC 8.4.0] on linux
Type "help", "copyright", "credits" or "license" for more information.
>>> import tensorflow as tf
2021-03-16 13:29:13.079079: I tensorflow/stream_executor/platform/default/dso_loader.cc:49] Successfully opened dynamic library libcudart.so.11.0
>>>
```

### metaWRAP - a flexible pipeline for genome-resolved metagenomic data analysis

Here is an example how to use the metaWRAP pipeline from the docker container - [installation instructions](https://github.com/bxlab/metaWRAP#docker-installation).

```
$ docker pull quay.io/biocontainers/metawrap:1.2--1
```
In this particular case it is as easy as:

```
$ singularity pull docker://quay.io/biocontainers/metawrap:1.2--1

INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
Getting image source signatures
...
```
This will bring the docker container locally and covert it to Singularity format.

Then, one can start the container and use it interactively.

```
$ ./metawrap_1.2--1.sif
WARNING: Skipping mount /usr/local/var/singularity/mnt/session/etc/resolv.conf [files]: /etc/resolv.conf doesn't exist in container

Singularity> metawrap --version
metaWRAP v=1.2
```

To run the tool from the command line (as you would use it in scripts) we need to add the call for the tool from Singularity.

Original commad in the cript:  
$ **metawrap** binning -o Lanna-straw_initial_binning_concoct -t 20 -a /proj/test/megahit_ass_Lanna-straw/final.contigs.fa --concoct --run-checkm /proj/test/Lanna-straw_reads_trimmed/*.fastq

The command now calls the tool from the Singularity container:  
$ ==singularity exec metawrap_1.2--1.sif== **metawrap** binning -o Lanna-straw_initial_binning_concoct -t 20 -a /proj/test/megahit_ass_Lanna-straw/final.contigs.fa --concoct --run-checkm /proj/test/Lanna-straw_reads_trimmed/*.fastq



!!! info "Pulling Singularity container from online or local library/repository"
    - **library://** to build from the [Container Library](https://    cloud.sylabs.io/library)  
    ` library://sylabs-jms/testing/lolcow`
    - **docker://** to build from [Docker Hub](https://hub.docker.com/    )  
    ` docker://godlovedc/lolcow`
    - **shub://** to build from [Singularity Hub](https://    singularityhub.com/)
    - path to a existing container on your local machine
    - path to a directory to build from a sandbox
    - path to a Singularity definition file

