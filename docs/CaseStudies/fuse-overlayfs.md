# fuse-overlayfs on Rackham

[https://github.com/containers/fuse-overlayfs](https://github.com/containers/fuse-overlayfs)

Here we will skip the explanation on what is and for what purpose you would need `fuse-overlayfs`, but will rather assume you badly need it to run on a computer or system which does not support it - like Rackham.

The recipy is extremely simple - just installing it from the package manager - in this case Ubuntu distribution.
```singularity
Bootstrap: docker
From: ubuntu:20.04

%environment
  export LC_ALL=C

%post
  export DEBIAN_FRONTEND=noninteractive
  export LC_ALL=C

  apt-get update && apt-get -y dist-upgrade && apt-get install -y fuse-overlayfs
 
%runscript
  /usr/bin/bash "$@"
```

Create the necessary folders for a test setup.
```bash
$ mkdir -p /tmp/lower /tmp/upper /tmp/workdir /tmp/merged
$echo "read-only text" > /tmp/lower/file.lower
```
Here is how it would work if it was available on the system.
```bash
# start the overlayfs 
fuse-overlayfs -o lowerdir=/tmp/lower,upperdir=/tmp/upper,workdir=/tmp/workdir /tmp/merged

# Stop/umount the overlayfs
umount /tmp/merged
```
Here is how you would run in with the Singularity container
```bash
$ singularity shell --fusemount "container:fuse-overlayfs -o lowerdir=/tmp/lower -o upperdir=/tmp/upper -o workdir=/tmp/workdir /tmp/merged" fuse-overlayfs.sif
```
