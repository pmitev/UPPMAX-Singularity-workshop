!!! info "Information"
    Singularity project is officially [moving into the Linux Foundation](https://www.linuxfoundation.org/press-release/new-linux-foundation-project-accelerates-collaboration-on-container-systems-between-enterprise-and-high-performance-computing-environments/). As part of this move, and to differentiate from the other like-named projects and commercial products, we will be renaming the project to "[**Apptainer**](https://apptainer.org/)". [_source_](https://apptainer.org/news/community-announcement-20211130/)

!!! note "Disclaimer"
    During the last 2021 year, the installation instructions changed more frequent than the workshop was given... Always check with the original instructions on how to install Singularity/Apptainer. For the purpose of this workshop, we will try to adapt to the the new free derivative as soon it becomes stable [https://github.com/apptainer/apptainer](https://github.com/apptainer/apptainer).

    Until then the content bellow will remain unchanged, to avoid unnecessary modifications.

    If you have already installed Singularity version, newer than 3.7, it should be sufficient for the workshop.

## Singularity installation via package manager (_if available_) : Linux

Currently, for supported Ubuntu and CentOS distributions, it is also possible to install Singuarity via the system package manager [link](https://github.com/sylabs/singularity/releases)
``` bash
# Ubuntu 24.04
wget https://github.com/sylabs/singularity/releases/download/v4.2.2/singularity-ce_4.2.2-noble_amd64.deb
sudo apt install ./singularity-ce_4.2.2-noble_amd64.deb

# RHEL/CentOS/AlmaLinux/Rocky 9
wget https://github.com/sylabs/singularity/releases/download/v4.2.2/singularity-ce-4.2.2-1.el9.x86_64.rpm
sudo yum install ./singularity-ce-4.2.2-1.el9.x86_64.rpm
```

### Installation for Windows or Mac
[https://sylabs.io/guides/latest/admin-guide/installation.html#installation-on-windows-or-mac](https://sylabs.io/guides/latest/admin-guide/installation.html#installation-on-windows-or-mac){target=_blank}

> (PM) I have successfully installed Singularity under [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10){target=_blank}, but can't guarantee that it will work in all cases.  
> Look at this [page](./vagrant_windows.md) for tips on the typical Windows installation (MacOS is rather similar).

---

### Apptainer installation
- [Install from pre-built packages](https://apptainer.org/docs/admin/1.3/installation.html#install-from-pre-built-packages)
- [Installation on Windows or Mac](https://apptainer.org/docs/admin/1.3/installation.html#installation-on-windows-or-mac)

!!! note
    There is a possibility to [install Apptainer as unprivileged user](https://apptainer.org/docs/admin/1.3/installation.html#install-unprivileged-from-pre-built-binaries), providing that the requirements are satisfied.

## Testing the installation

[https://sylabs.io/guides/latest/admin-guide/installation.html#testing-checking-the-build-configuration](https://sylabs.io/guides/latest/admin-guide/installation.html#testing-checking-the-build-configuration){target=_blank}

``` bash
 singularity 
Usage:
  singularity [global options...] <command>

Available Commands:
  build       Build a Singularity image
  cache       Manage the local cache
  capability  Manage Linux capabilities for users and groups
  config      Manage various singularity configuration (root user only)
  delete      Deletes requested image from the library
  exec        Run a command within a container
  inspect     Show metadata for an image
  instance    Manage containers running as services
  key         Manage OpenPGP keys
  oci         Manage OCI containers
  plugin      Manage Singularity plugins
  pull        Pull an image from a URI
  push        Upload image to the provided URI
  remote      Manage singularity remote endpoints, keyservers and OCI/Docker registry credentials
  run         Run the user-defined default command within a container
  run-help    Show the user-defined help for an image
  search      Search a Container Library for images
  shell       Run a shell within a container
  sif         siftool is a program for Singularity Image Format (SIF) file manipulation
  sign        Attach digital signature(s) to an image
  test        Run the user-defined tests within a container
  verify      Verify cryptographic signatures attached to an image
  version     Show the version for Singularity

Run 'singularity --help' for more detailed usage information.
```

## Checking the configuration

``` bash
singularity buildcfg
PACKAGE_NAME=singularity
PACKAGE_VERSION=3.10.2
BUILDDIR=/root/singularity/builddir
PREFIX=/usr/local
EXECPREFIX=/usr/local
BINDIR=/usr/local/bin
SBINDIR=/usr/local/sbin
LIBEXECDIR=/usr/local/libexec
DATAROOTDIR=/usr/local/share
DATADIR=/usr/local/share
SYSCONFDIR=/usr/local/etc
SHAREDSTATEDIR=/usr/local/com
LOCALSTATEDIR=/usr/local/var
RUNSTATEDIR=/usr/local/var/run
INCLUDEDIR=/usr/local/include
DOCDIR=/usr/local/share/doc/singularity
INFODIR=/usr/local/share/info
LIBDIR=/usr/local/lib
LOCALEDIR=/usr/local/share/locale
MANDIR=/usr/local/share/man
SINGULARITY_CONFDIR=/usr/local/etc/singularity
SESSIONDIR=/usr/local/var/singularity/mnt/session
PLUGIN_ROOTDIR=/usr/local/libexec/singularity/plugin
SINGULARITY_CONF_FILE=/usr/local/etc/singularity/singularity.conf
SINGULARITY_SUID_INSTALL=1
```

