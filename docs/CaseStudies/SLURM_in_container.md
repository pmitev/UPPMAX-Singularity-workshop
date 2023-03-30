# SLURM capabilities in a container

> Case below specific for Rackham  
> Credits to Camille Clouard for the solution, adapted from the [original source](https://info.gwdg.de/wiki/doku.php?id=wiki:hpc:usage_of_slurm_within_a_singularity_container).


## Bind the necessary tools and libraries
On Rackham
```bash
singularity exec -B /usr/bin/sbatch,/usr/lib64/slurm,/etc/slurm,/run/munge,/usr/lib64/libmunge.so.2 container.sif  script.sh
```

Patch on the fly `userID` and `groupID` for the SLURM manager in `script.sh` before calling SLURM commands.

```bash
...
# Params to match SLURMon Rackham	
export LD_LIBRARY_PATH=/usr/lib64:$LD_LIBRARY_PATH
echo "slurm:x:151:151:Slurm:/:/sbin/nologin" >> /etc/passwd
echo "slurm:x:151:" >> /etc/group

/opt/slurm/bin/<slurm_command> <optional_arguments>
...
```