# Simple build to exercise

Let's start with something easy and fast to build - Install the [figlet](http://www.figlet.org/examples.html) app in container.

```
$ figlet UPPMAX
 _   _ ____  ____  __  __    _    __  __
| | | |  _ \|  _ \|  \/  |  / \   \ \/ /
| | | | |_) | |_) | |\/| | / _ \   \  / 
| |_| |  __/|  __/| |  | |/ ___ \  /  \ 
 \___/|_|   |_|   |_|  |_/_/   \_\/_/\_\

 $ figlet -f slant UPPMAX
   __  ______  ____  __  ______   _  __
  / / / / __ \/ __ \/  |/  /   | | |/ /
 / / / / /_/ / /_/ / /|_/ / /| | |   / 
/ /_/ / ____/ ____/ /  / / ___ |/   |  
\____/_/   /_/   /_/  /_/_/  |_/_/|_|
```

Let's use Ubuntu from Docker to install the package.
??? note "Singularity.figlet"
    ```
    Bootstrap: docker
    From: ubuntu:20.04
    ```

- It is not necessary right now, but it is good to inform the package manager that we are not in a interactive session by `export DEBIAN_FRONTEND=noninteractive`
- We need only to install the figlet package by apt-get. Do not forget to `apt-get update` first, since the package index is empty.
- `apt-get install -y figlet` - use `-y` to avoid the confirmation when installing packages
- In what section we add these commands?
- Let's clean a bit with `apt-get clean`

??? note "Singularity.figlet"
    ```
    Bootstrap: docker
    From: ubuntu:20.04

    %post
      export DEBIAN_FRONTEND=noninteractive

      apt-get update
      apt-get install -y figlet
      apt-get clean
    ```

- Let's define what to run when we run the container itself.

??? note "Singularity.figlet"
    ```
    Bootstrap: docker
    From: ubuntu:20.04

    %post
      export DEBIAN_FRONTEND=noninteractive

      apt-get update
      apt-get install -y figlet
      apt-get clean
    
    %runscript
      figlet $@
    ```

- Build the recipe

??? note "build"
    ```
    $ sudo singularity build figlet.sif Singularity.figlet
    ```