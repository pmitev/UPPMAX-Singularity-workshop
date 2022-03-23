# Indirect executable calls

The common approach for Singularity is to have single entry point defined by `%runscript` or by `%app`. This is not so convenient for daily use... So, here is a minimal example on how to implement a well known trick to use single executable for multiple commands (see for example the [BusBox](https://busybox.net/screenshot.html) project).



``` singularity
Bootstrap: docker
From: ubuntu:20.04

%post
  # let's add some executable in /usr/local/bin
  ln -s /usr/bin/cat  /usr/local/bin/cat
  ln -s /usr/bin/date /usr/local/bin/date

%runscript
  if [ -x /usr/local/bin/$SINGULARITY_NAME ]; then
    exec $SINGULARITY_NAME "$@"
  else
    /bin/echo -e "This Singularity image does not provide a single entrypoint.\nPlease use make soft links to the container to one of the available executables in /usr/local/bin i.e.\n  ln -s $SINGULARITY_NAME date"
    exec ls -1 /usr/local/bin
  fi
EOF
```

Build the recipe and make two soft links to the image:
``` bash
sudo singularity build cmd.sif Singularity.cmd

ln -s cmd.sif cat
ln -s cmd.sif date
``` 

Here is what happens. Compare the output by running `date` on your computer and by running the soft link by `./date`.

``` bash
# local system call
date
Wed 23 Mar 2022 09:23:40 AM CET

# here we run the container that picks the name from the soft link
./date
Wed Mar 23 08:23:42 Europe 2022
```

Note, that the time zone in the container is different from the one on your/my computer. I have my computer in CET (Central European Time) and the container defaults to "Europe" and one hour later than CET. 

Here is one more example, by runing the container on a CentOS computer.

``` bash
$rackham3: cat /etc/os-release 
NAME="CentOS Linux"
VERSION="7 (Core)"
ID="centos"
ID_LIKE="rhel fedora"
VERSION_ID="7"
PRETTY_NAME="CentOS Linux 7 (Core)"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:centos:centos:7"
HOME_URL="https://www.centos.org/"
BUG_REPORT_URL="https://bugs.centos.org/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"

$rackham3: ./cat /etc/os-release 
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 20.04.4 LTS"
VERSION_ID="20.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=focal
UBUNTU_CODENAME=focal
```

The first call is regular `cat` on the computer and the second is calling `cat` inside the container.