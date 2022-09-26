# QEMU-utils

This is just another illustration for using tools in Singularity container.

Suppose, you want to upload an VM OS image to the cloud - in this example SNIC Science Cloud (SSC).
Ubuntu provides them [here](https://cloud-images.ubuntu.com/) and the format [available](https://cloud-images.ubuntu.com/jammy/20220921.1/) is `.img`. For one or another reason (_under heavy load compressed formats time out_), you need to convert it to `.raw` with:

```bash
$ qemu-img convert -p -f qcow2 -O raw focal-server-cloudimg-amd64.img  focal-server-cloudimg-amd64.raw
```
Now, you can certainly do this on your computer, but you will end up with ~ 640MB `.img` to download and  ~2GB `.raw` image that you need to upload. Depending on the Internet speed you have, this might be rather slow process.

If you have an account on UPPMAX and want to upload your image to the EAST region hosted by UPPMAX... yes, it is rather fast to do this operations remotely on Rackham. The problem is that `qemu-tools` are not available on Rackham...

```singularity
Bootstrap: docker
From: ubuntu:latest

%environment
  export LC_ALL=C

%post
  export DEBIAN_FRONTEND=noninteractive
  export LC_ALL=C

  apt-get update && apt-get -y dist-upgrade && apt-get install -y git wget qemu-utils

%runscript
  /usr/bin/bash "$@"
```
Here is a bash script that will do everything...
```bash
#!/bin/bash
CMD_qemu_cmd="singularity exec /crex/proj/nobackup/sbin/qemu-utils.sif qemu-img"

TMP_DIR=$(mktemp -d) && \
cd ${TMP_DIR} && echo "TMP_DIR: "${TMP_DIR} && \
wget https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img && \
${CMD_qemu_cmd} convert -p -f qcow2 -O raw focal-server-cloudimg-amd64.img  focal-server-cloudimg-amd64.raw && \
IMAGE_NAME=$(date -r focal-server-cloudimg-amd64.img +"Ubuntu 20.04 - %Y.%m.%d") && \
openstack image create --min-disk 20 --private --file focal-server-cloudimg-amd64.raw "${IMAGE_NAME}" && \
cd -
```

!!! note
    You need to have the `python-openstackclient` to be able to run the command `openstack image create ...`