# Converting Docker image to Singularity container

## 1. run "directly" from DockerHub

This is most common situation, already mentioned.  
You can directly run the container. The content of the Docker image will be pulled and cached localy.
```bash
$ singularity run docker://godlovedc/lolcow
```

## 2. pull/build from DockerHub

With `pull` the singularity name gets automatically assigned, in this example to "lolcow_latest.sif". Note, this operation does not need `sudo`.

```bash
$ singularity pull docker://godlovedc/lolcow

INFO:    Converting OCI blobs to SIF format
INFO:    Starting build...
...
INFO:    Creating SIF file...

# name gets automatically assigned to "lolcow_latest.sif"
```

```bash
$ singularity build lolcow.sif docker://godlovedc/lolcow

Starting build...
Getting image source signatures
Copying blob 9fb6c798fa41 done  
Copying blob 3b61febd4aef done
...
INFO:    Creating SIF file...
INFO:    Build complete: lolcow.sif
```

## 3. Building from docker image on your computer
The examples bellow assume you have permission to run docker.

```bash
# Build the docker image
$ docker build -t local/my_container .

# build from local docker repository
$ sudo singularity build my_container.sif docker-daemon://local/my_container
```

## 4. Using Docker image saved in a .tar file

```bash
# Save the docker container from your computer to a .tar file
$ docker save image_id -o local.tar

# Build from a docker-archive
#$ singularity build local_tar.sif docker-archive://local.tar
$ singularity build local_tar.sif local.tar
```
