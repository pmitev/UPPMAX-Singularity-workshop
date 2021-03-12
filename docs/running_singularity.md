# Running Singularitry container

Let's practice a bit running one of the containers from the previous step.

## Run the Singularity container

Executing the container file itself or a remote build will start will execute the commands defined in the `%runscript` section. This is equivalent to run `singularity run ./lolcow.sif`

```
$ ./lolcow.sif 
_________________________________________
/ You will stop at nothing to reach your  \
| objective, but only because your brakes |
\ are defective.                          /
 -----------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```


```
$ singularity run ./lolcow.sif 
 _____________________________________
/ Don't relax! It's only your tension \
\ that's holding you together.        /
 -------------------------------------
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

## Getting a shell in the running container

``` bash
$ singularity shell ./lolcow.sif 
Singularity>
```

If you try to list the files in your home folder with `ls -l ~` you will see the content of your home folder. What about the root folder? List the content with `ls -l /` and compare the output from a different terminal. 

Singularity binds the user home folder, `/tmp` and some other by default. If you are running on a computer with more users accounts than your own (like on a computer cluster) compare the content of `ls -l /home` from within the container and outside. You should not be able to see the other users folders that are on the computer otherwise.

## Binding/mounting folders

Exit from the container with `exit`. Now start with 

XXXXXXXXXXX

### Execute program in the container
There is of course a way to start a different program than the default shell or the defined in the `%runscript` section.

``` bash
$ singularity exec ./lolcow.sif fortune
Beauty and harmony are as necessary to you as the very breath of life.

$ singularity exec  ./lolcow.sif host
FATAL:   "host": executable file not found in $PATH
```

Keep in mind that running in the container you should be able to find the program inside or in the folders you have binded to the container i.e. the system tools and programs remain isolated. 

!!! warning
    If you have setup `conda` or `pip` installations in you profile folder, they get available in the container. This  might conflict with the container setup which is unaware of programs installed in your home folder. To avoid such situations you might need to run singularity with `--cleanenv` option i.e. `singularity run -e ./lolcow.sif`
