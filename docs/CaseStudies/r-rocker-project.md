# [Rocker project](https://rocker-project.org/)
Running Rstudio server in a Singularityi/Apptainer container

[https://rocker-project.org/use/singularity.html](https://rocker-project.org/use/singularity.html)

The project builds and shared docker containers but with support to covert and run it with Singularity/Apptainer. Look for more details on the project web page.

```bash
# Pull the container locally for convinience
singularity pull docker://rocker/rstudio:4.4.2

# Run the container
singularity exec \
   --scratch /run,/var/lib/rstudio-server \
   --workdir $(mktemp -d) \
   rstudio_4.4.2.sif \
   rserver --www-address=127.0.0.1 --server-user=$(whoami)
```

This will run rserver in a Singularity container. The `--www-address=127.0.0.1` option binds to localhost (the default is `0.0.0.0`, or all IP addresses on the host). listening on `127.0.0.1:8787`.

!!! note
    If you run on a remote machine, like computer center, the most efficient way to open the remte server is to use ssh port forwarding, for example 
    ```bash
    ssh -L 8787:localhost:8787  userID@remote.computer.se
    ```
    Quite often, you will run the R studio server in an interactive session/reserved compute node. Then you need to redirect to that node.
    ```bash
    ssh -L 8787:comp_node_xx:8787  userID@remote.computer.se
    ```
    Finally, it might happen that another user is using the same `8787` port. Take a random number above 1024 and add this option `--www-port=9090` at the end of the  `singularity exec ... ` line, where `9090` is the port we have chosen in this example.

Look for more details on the web page on how to protect the server with password or submit a SLURM job.