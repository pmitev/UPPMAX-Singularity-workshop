# Building without elevated privileges with `--fakeroot`

[Online manual](https://sylabs.io/guides/3.8/user-guide/fakeroot.html)

The fakeroot feature (commonly referred as rootless mode) allows an unprivileged user to run a container as a "**fake root**" user by leveraging [user namespace UID/GID mapping](http://man7.org/linux/man-pages/man7/user_namespaces.7.html).

A "**fake root**" user has almost the same administrative rights as root but only **inside the container** and the **requested namespaces**, which means that this user:

- can set different user/group ownership for files or directories they own
- can change user/group identity with su/sudo commands
- has full privileges inside the requested namespaces (network, ipc, uts)

!!! note
    Many computer centers, including UPPMAX, does not allow the use of "fake root" and attempt to build on Rackham will trigger the following error:
    ``` bash
    $ singularity build --fakeroot lolcow.sif Singularity.lolcow 
    FATAL:   could not use fakeroot: no mapping entry found in /etc/subuid for user
    ```