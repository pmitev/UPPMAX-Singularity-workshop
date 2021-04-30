# Building simple container

Let's start with a simple example.  
For the  more complicated we will try to use a bit more interactive approach using `--sandbox` option.

Here we simply install the [Paraview](https://www.paraview.org/) program in virtual environment conveniently provided by the Ubuntu distribution via the docker hub repository.

`Singularity.paraview`
``` singularity
Bootstrap: docker
From: ubuntu:20.04

%post
  export DEBIAN_FRONTEND=noninteractive
  
  apt-get update && apt-get -y dist-upgrade && \
  apt-get install -y paraview && \
  apt-get clean

%runscript
  paraview $@
```

``` bash
$ sudo singularity build paraview.sif Singularity.paraview
```

This will download 301 MB and install 500 new packages... It might take some time to complete, but once you are done you will have a container that will run almost everywhere - there is always a catch.

Instead of paraview, modify the definition file to install and run your, not necessarily graphical, program. Few tips: `gnuplot`, `grace`, `blender`, `povray`, `rasmol`, `gromacs-openmpi`  ...

## Building interactively in a sandbox.

Unless you know exactly which programs and commands you need to install it might be rather tricky to assemble a recipe that will work. If every change requires rebuilding it becomes rather tedious work. Instead, we can try to build a container as we would do it interactively on the command line.

For this purpose, we will use `--sandbox` option which keeps the file structure intact. A regular build will create this folder structure in the `/tmp` then at the end will wrap everything in a single compressed **read-only** file by `mksquasfs` and delete the folder...
The so-called sandbox is writable (by root) and accessible as regular folder (by root).

This is extremely convenient for testing purposes. The sandbox folder could be later converted to a regular container - but please do not do it unless you have a good reason why you are breaking all the reproducible features of the container. Instead, during the interactive build, take notes by editing the definition file and build from scratch when you think you are ready.

Let's try this with something which might or might not  work - install jupyter with `jupyter_contrib_nbextensions` and `jupyter_nbextensions_configurator` via `pip`.

Select location where you will create the new container-folder - in this case jupyter-sb

``` bash
$ sudo singularity build --sandbox jupyter-sb docker://ubuntu:20.04

INFO:    Starting build...
Getting image source signatures
Copying blob 5d3b2c2d21bb skipped: already exists  
Copying blob 3fc2062ea667 skipped: already exists  
Copying blob 75adf526d75b [--------------------------------------] 0.0b / 0.0b
Copying config 591d30d91a done  
Writing manifest to image destination
Storing signatures
2021/03/15 13:17:49  info unpack layer: sha256:5d3b2c2d21bba59850dac063bcbb574fddcb6aefb444ffcc63843355d878d54f
2021/03/15 13:17:51  info unpack layer: sha256:3fc2062ea6672189447be7510fb7d5bc2ef2fda234a04b457d9dda4bba5cc635
2021/03/15 13:17:51  info unpack layer: sha256:75adf526d75b82eb4f9981cce0b23608ebe6ab85c3e1ab2441f29b302d2f9aa8
INFO:    Creating sandbox directory...
INFO:    Build complete: jupyter

# List the current folder - note that the jupyter-sb is owned by root
$ ls -l

total 4
drwxr-xr-x 18 root root 4096 Mar 15 13:17 jupyter-sb
```

This pulls `docker://ubuntu:20.04` image and build new singularity container in sandbox in folder `jupyter-sb` and we add two lines in the new recipe...
``` singularity
Bootstrap: docker
From: ubuntu:20.04
```



Let's "jump inside" the container (ignore the warning)

``` bash
$ sudo singularity shell --writable jupyter-sb

WARNING: Skipping mount /etc/localtime [binds]: /etc/localtime doesn't exist in container
Singularity>
```
Now, you are in the shell inside the container. Keep in mind that you are running as root at this point!

``` bash
$ cat /etc/os-release 

NAME="Ubuntu"
VERSION="20.04.2 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.2 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

To be consistent, run `export DEBIAN_FRONTEND=noninteractive` (_otherwise you will be asked to provide localization interactively during the package installation_) and add this line to the `%post` section of the recipe.

``` bash
Singularity> export DEBIAN_FRONTEND=noninteractive

Singularity> apt-get update
Singularity> apt-get install -y locales python3-dev  python3-pip python3-tk build-essential bash-completion
```

Then the recipe becomes...
``` singularity
Bootstrap: docker
From: ubuntu:20.04

%post
  export DEBIAN_FRONTEND=noninteractive

  apt-get update
  apt-get install -y locales python3-dev  python3-pip  python3-tk build-essential bash-completion
```
We are ready for `pip`

``` bash
Singularity> /usr/bin/env python3 -m pip install --upgrade pip

Singularity> /usr/bin/env python3 -m pip install jupyter

Singularity> /usr/bin/env python3 -m pip install jupyter_contrib_nbextensions
Singularity> jupyter contrib nbextension install --system
Singularity> jupyter nbextension enable codefolding/main

Singularity> /usr/bin/env python3 -m pip install jupyter_nbextensions_configurator
Singularity> jupyter nbextensions_configurator enable --system
```
Add the commands in the relevant section.  
Now, let's try to run the jupyter notebook. 

``` bash 
Singularity> jupyter notebook --ip 0.0.0.0 --no-browser

[I 13:46:05.654 NotebookApp] Writing notebook server cookie secret to /root/.local/share/jupyter/runtime/notebook_cookie_secret
[I 13:46:05.946 NotebookApp] [jupyter_nbextensions_configurator] enabled 0.4.1
[C 13:46:05.946 NotebookApp] Running as root is not recommended. Use --allow-root to bypass.
```
It complains but it seems that it will work.  
Exit from the container `exit`. Add `%runscrip`. Try to build the recipe you have assembled by now.

??? note "Singularity.jupyter"
    ``` singularity
    Bootstrap: docker
    From: ubuntu:20.04
    
    %post
      export DEBIAN_FRONTEND=noninteractive
    
      apt-get update
      apt-get install -y locales python3-dev  python3-pip  python3-tk build-essential bash-completion
      rm -rf /var/lib/apt/lists/*
    
      /usr/bin/env python3 -m pip install --no-cache-dir --upgrade pip
    
      /usr/bin/env python3 -m pip install --no-cache-dir jupyter

      /usr/bin/env python3 -m pip install --no-cache-dir  jupyter_contrib_nbextensions
      jupyter contrib nbextension install --system
      jupyter nbextension enable codefolding/main
    
      /usr/bin/env python3 -m pip install --no-cache-dir jupyter_nbextensions_configurator
      jupyter nbextensions_configurator enable --system
    
    %runscript
      jupyter notebook --ip 0.0.0.0 --no-browser
    ```
    ``` bash
    $ sudo singularity build jupyter.sif Singularity.jupyter
    ```

    Note, the added line `rm -rf /var/lib/apt/lists/*` and options `--no-cache-dir` to clean or skip remaining cached files.

When it is done, try to run it with `./jupyter.sif`. Does it work? Can you open the address with the browser? Yes, you can install whatever packages you want and they will be available and preset in the container.

Keep in mind that you have installed all packages with pip in the container at system level and they will be available to any user running the container. **Important**! If you or somebody else who will use the container have packages installed in their home folder i.e. `pip install --user package` they will come on top of everything - for god or bad...

When you are done experimenting, and your recipe builds and works, do not forget to delete the sandbox. Be careful, you will need run `rm -r` with `sudo`. Slow down. Check twice when you run

``` bash
$ sudo rm -r jupyter-sb
```