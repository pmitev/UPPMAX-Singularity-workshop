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