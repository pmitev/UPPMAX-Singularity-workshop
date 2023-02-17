# Building without elevated privileges with `--fakeroot`

[Online manual](https://sylabs.io/guides/3.8/user-guide/fakeroot.html)

The fakeroot feature (commonly referred as rootless mode) allows an unprivileged user to run a container as a "**fake root**" user by leveraging [user namespace UID/GID mapping](http://man7.org/linux/man-pages/man7/user_namespaces.7.html).

A "**fake root**" user has almost the same administrative rights as root but only **inside the container** and the **requested namespaces**, which means that this user:

- can set different user/group ownership for files or directories they own
- can change user/group identity with su/sudo commands
- has full privileges inside the requested namespaces (network, ipc, uts)

!!! note
    Many computer centers, do not allow the use of "fake root" and attempt to build  trigger the following error:
    ``` text

    $ singularity build --fakeroot lolcow.sif lolcow.def 
    FATAL:   could not use fakeroot: no mapping entry found in /etc/subuid for user
    ```

    **UPDATE 2022.10.19:** Alvis and UPPMAX support building Singularity containers with `apptainer / singularity`
    ```
    $ apptainer build lolcow.sif lolcow.def 
    INFO:    Detected Singularity user configuration directory
    INFO:    User not listed in /etc/subuid, trying root-mapped namespace
    INFO:    The %post section will be run under fakeroot
    INFO:    Starting build...
    ...
    INFO:    Adding environment to container
    INFO:    Adding runscript
    INFO:    Creating SIF file...
    INFO:    Build complete: lolcow.sif
    ```

### Handy environmental variables for use on HPC clusters
> Environmental variables that will help you to redirect potentially large folders to alternative location - keep in mins your `$HOME` folder is relatively small in size.

```bash
export PROJECT=project_folder

export SINGULARITY_CACHEDIR=/proj/${PROJECT}/nobackup/SINGULARITY_CACHEDIR
export SINGULARITY_TMPDIR=/proj/${PROJECT}/nobackup/SINGULARITY_TMPDIR

export APPTAINER_CACHEDIR=/proj/${PROJECT}/nobackup/SINGULARITY_CACHEDIR
export APPTAINER_TMPDIR=/proj/${PROJECT}/nobackup/SINGULARITY_TMPDIR

mkdir -p $APPTAINER_CACHEDIR $APPTAINER_TMPDIR
```

### Documentation about  Singularity / Apptainer on different HPC centers:  

- [C3SE](https://www.c3se.chalmers.se/)
    - [Alvis](https://www.c3se.chalmers.se/about/Alvis/) - [https://www.c3se.chalmers.se/documentation/applications/containers/](https://www.c3se.chalmers.se/documentation/applications/containers/)
- [PDC](https://www.pdc.kth.se/)
    - [Dardel](https://www.pdc.kth.se/hpc-services/computing-systems) - [https://www.pdc.kth.se/software/software/singularity/index_general.html](https://www.pdc.kth.se/software/software/singularity/index_general.html)
- [HPC2N](https://www.hpc2n.umu.se/)
    - [https://www.hpc2n.umu.se/resources/software/singularity](https://www.hpc2n.umu.se/resources/software/singularity)