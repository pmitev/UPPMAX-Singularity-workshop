# Installation

---
Detailed and well explained installation instructions at:  
<https://sylabs.io/guides/3.7/admin-guide/installation.html#installation-on-linux>

Installation on Windows or Mac  
<https://sylabs.io/guides/3.7/admin-guide/installation.html#installation-on-windows-or-mac>

> (PM) I have successfully installed Singularity under [WSL2](https://docs.microsoft.com/en-us/windows/wsl/install-win10), but can't guarantee that it will work in all cases.

## [TL;DR](https://www.urbandictionary.com/define.php?term=tl%3Bdr) 
For Ubuntu (Debian based) Linux distributions.

``` bash
# Install system dependencies
sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

# Install Go
export VERSION=1.14.12 OS=linux ARCH=amd64 && # Replace the values as needed \
  wget https://dl.google.com/go/go$VERSION.$OS-$ARCH.tar.gz && # Downloads the required Go package \
  sudo tar -C /usr/local -xzvf go$VERSION.$OS-$ARCH.tar.gz && # Extracts the archive \
  rm go$VERSION.$OS-$ARCH.tar.gz # Deletes the ``tar`` file

echo 'export GOPATH=${HOME}/go' >> ~/.bashrc && \
  echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc && \
  source ~/.bashrc

# Download Singularity from a release
export VERSION=3.7.0 && # adjust this as necessary \
    wget https://github.com/hpcng/singularity/releases/download/v${VERSION}/singularity-${VERSION}.tar.gz && \
    tar -xzf singularity-${VERSION}.tar.gz && \
    cd singularity

# Compile the Singularity source code
./mconfig && \
    make -C builddir && \
    sudo make -C builddir install
```

## Test the installation

<https://sylabs.io/guides/3.7/admin-guide/installation.html#testing-checking-the-build-configuration>

TL;DR

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

## Check the configuration

``` bash
singularity buildcfg
PACKAGE_NAME=singularity
PACKAGE_VERSION=3.7.0
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

!!! note
    There is a possibility to [install Singularity as user](https://sylabs.io/guides/3.7/admin-guide/installation.html#unprivileged-non-setuid-installation), providing that the requirements are satisfied. Make sure you have `go` or install it as user as well.