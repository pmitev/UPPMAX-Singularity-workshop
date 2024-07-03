# On the subject of reproducibility

There is a good [introduction to the problems of reproducibility on the Anaconda blog](https://www.anaconda.com/blog/8-levels-of-reproducibi) where 8 levels of reproducibility are defined.

- Level -1 (not reproducible)
- Level 0 (reproducible only by you, today)
- Level 1 (reproducible by others with guidance)
- Level 2 (reproducible today, by anyone with Internet access)
- Level 3 (reproducible indefinitely, by anyone with Internet access)
- Level 4 (reproducible indefinitely, without depending on the Internet)
- Level 5 (reproducible with Docker)
- Level 6 (reproducible with a virtual machine)
- Level 7 (reproducible on untouched hardware)

Briefly

- **conda** can reach level 3, perhaps level 4 with some archiving.
- **docker** is mentioned on level 5, I would say very close to 6 with some platform dependent restrictions...

## Where Singularity/Apptainer containers stand
**Singularity**, in principle, can reach docker's level for particular project that does not require elevated privileges and the same platform dependent restrictions. Essentially, the container build is reproducible as reproducible are the tools used for the build, with the advantage of complete, immutable, and shareable snapshot of the environment setup.  

Here is the place to mention a common situation, when Internet is not available (*resources with sensitive data and restricted Internet access*) and such snapshots (*containers, images, etc.*) are rather common and easy solution. Quite often, code repositories disappear, change location (`pip2`) or become obsolete (ex. `python2`). Having the container, does not solve the reproducibility issue but you are on way better footing with, possibly, still working project or tool.

## Danger !!!
The **default Singularity "mode"** integrates with your data. This is much closer as concept to conda or python environments - you have isolated setup of the tool but you still have access to the other tools on the machine.

One of the most common problems is **mixing the user's python modules** in `$HOME/.local/...` which by default will be available in the Singularity container and used if matching the python version!!!  
Simple precaution is to add:
```singularity
%environment
  export PYTHONNOUSERSITE=True
```
which will instruct python to ignore these modules.

**The problem is identical for `R`, `conda`, and other tools** that store users modules or libraries in the user's home folder.

Docker's default behavior is to run isolated and usually is not affected by this problem. The equivalent to this is to run singularity with `--no-home` [option](https://docs.sylabs.io/guides/latest/user-guide/bind_paths_and_mounts.html#using-no-home-and-containall-flags) which will create temporary `$HOME` directory in memory to keep programs running and you will still have access to the current working directory.

**Consider, building a container that can run with `--contain`** [option](https://docs.sylabs.io/guides/latest/user-guide/bind_paths_and_mounts.html#using-no-home-and-containall-flags) as good practices (*you do not have to, but in practice the container should be able to run without your specific settings - after all you want to share or run the container on another machine*). This is rather restrictive, since it looses all the conveniences, like shell environmental variables, which in tern will disable X11 graphics. For example, to achieve the Docker isolation ,`nextflow` workflow is running containers like this 

`#!python nxf_launch() {
    set +u; env - PATH="$PATH" ${TMP:+SINGULARITYENV_TMP="$TMP"} ${TMPDIR:+SINGULARITYENV_TMPDIR="$TMPDIR"} ${NXF_TASK_WORKDIR:+SINGULARITYENV_NXF_TASK_WORKDIR="$NXF_TASK_WORKDIR"} singularity exec --no-home --pid --bind /crex/proj/naissXXXX-XX-XX/folder/:/crex/proj/naissXXXX-XX-XX/folder/ /crex/proj/nobackup/NXF_SINGULARITY_CACHEDIR/maestsi-metontiime-latest.img /bin/bash -ue /crex/proj/nobackup/RT-support/Nextflow-test/work/ab/a179275afe402383046320e2da3417/.command.sh
}`

Note the `--no-home` option and the explicit `--bind`. This is also an excellent approach to test the requirements for your tools. Example: some conda environments setups depend on `ffmpeg` but mistakenly not listed as users usually have the tool provided by the OS.


## Few hints that helps recreating/rebuilding your container.
- Try to install tools following the **best practices** for the corresponding tool.
- Do not be shy to **add comments** in the definition file.
- Singularity keeps copy of the definition file `singularity inspect -d container.sif`. It is rather tedious work to specify all versions of the packages you install with conda, pip, apt, yum, etc. Instead, **keep track of the build process**
`sudo singularity build container.sif definition.def |& tee build.log` - you or your colleagues might find later this information invaluable to help fix broken rebuild routines.

## Additional efforts
- Consider **performing test runs** during the build and keep the logs for future reference (part of the good practices).
- Often, licenses restrict code distribution - for your safety, **consider keeping a copy** of the tool locally as an alternative to the on-line source.
- As **final resort**, your containers might be used as source for new build as temporary fix.

## Why not talk more about reproducibility here?
The subject is rather complex and problems with reproducibility might extend even beyond software installation.

Chemists bitten by Python scripts: How different OSes produced different results during test number-crunching - [source](https://www.theregister.com/2019/10/15/bug_python_scripts/)

Excerpt:
> When Luo ran these "Willoughby–Hoye" scripts, he got different results on different operating systems. For macOS Mavericks and Windows 10, the results were as expected (173.2); for Ubuntu 16 and macOS Mojave, the result differed (172.4 and 172.7 respectively). They may not sound a lot but in the precise world of scientific research, that's a lot.

> The reason, it turns out, is not specific to Python; rather it's that the underlying system call to read files from a directory leaves the order in which files get read up to the OS's individual implementation. That's why sort order differs in different environments.

Here is a bit simplified illustration of the problem from summing the values in 4 files in different order caused by the different localization in the shell.

```bash
LC_ALL=en_US.UTF-8
a.dat 1.e-8
A.dat 1.e+8
b.dat 1.e-8
B.dat 1.e+8
200000000.00000002980232238769531250

$LC_ALL=C
A.dat 1.e+8
B.dat 1.e+8
a.dat 1.e-8
b.dat 1.e-8
200000000.00000000000000000000000000
```