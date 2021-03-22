# Inspecting the metadata of the container

[Online documentation](https://sylabs.io/guides/3.7/user-guide/cli/singularity_inspect.html)

``` bash
$ singularity inspect [inspect options...] <image path>
```
Inspect will show you labels, environment variables, apps and scripts associated with the image determined by the flags you pass.

## Let's inspect our containers.
`-d` - show the Singularity recipe file that was used to generate the image

```
$ singularity inspect -d lolcow.sif

BootStrap: docker
From: ubuntu:16.04

%post
  apt-get -y update
  apt-get -y install fortune cowsay lolcat

%environment
  export LC_ALL=C
  export PATH=/usr/games:$PATH

%runscript
  fortune | cowsay | lolcat
```

`-e` - show the environment settings for the image
```
$ singularity inspect -e lolcow.sif

=== /.singularity.d/env/10-docker2singularity.sh ===
#!/bin/sh
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

=== /.singularity.d/env/90-environment.sh ===
#!/bin/sh
# Custom environment shell code should follow


  export LC_ALL=C
  export PATH=/usr/games:$PATH
```
`-r` - show the runscript for the image
```
$ singularity inspect -r lolcow.sif

#!/bin/sh

  fortune | cowsay | lolcat
```

!!! note
    Do not assume that the content of the script will give you all the information. Just test with an image you have downloaded from docker://

??? info "docker://"
    ```
    singularity inspect -d wttr.sif

    bootstrap: docker
    from: dctrud/wttr
    ```
    Check the runscript.