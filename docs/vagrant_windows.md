# Singularity under Windows
## Git Bash + VirtualBox + Vagrant

> Update: 2023.03.22  

Just few hints if you follow the official Singularity installation from [https://docs.sylabs.io/guides/latest/admin-guide/installation.html#windows](https://docs.sylabs.io/guides/latest/admin-guide/installation.html#windows)

1. Make sure you start `Git Bash` terminal.
2. 
```
$ mkdir vm-singularity-ce && cd vm-singularity-ce
$ export VM=sylabs/singularity-ce-3.8-ubuntu-bionic64 &&  vagrant init $VM
```
3. `$ vagrant up` - note the last lines that print what folder is shared between the Virtual Machine (VM) and your host computer.
```
$ vagrant up
...
    default: shared folder errors, please make sure the guest additions within the
    default: virtual machine match the version of VirtualBox you have installed on
    default: your host and reload your VM.
    default:
    default: Guest Additions Version: 6.1.22
    default: VirtualBox Version: 7.0
==> default: Mounting shared folders...
    default: /vagrant => C:/Users/username/vm-singularity
```
4. `$ vagrant ssh` will "ssh" to the virtual machine that runs Ubuntu 18.04.5 LTS with Singularity 3.8.0 pre-installed. Keep in mind that the VM has only ~1GB RAM, and ~16GB free space. Building large containers might be difficult. You can edit the `Vagrantfile` file to increase the RAM (look for `vb.memory = "1024"` line and edit the relevant lines).
5. Use the `/vagrant` folder to copy/transfer files between your host computer and the VM.
6. Do not forget to 
```
$ vagrant destroy && rm Vagrantfile
``` 
when you finish.

