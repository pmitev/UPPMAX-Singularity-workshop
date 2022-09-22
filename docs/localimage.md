# Building from Singularity image

Briefly, one can use Singularity image as `Bootstrap` to build new i.e. to modify the original source image by adding new packages, programs or modifying setting.

```singularity
Bootstrap: localimage
From: /path/to/container/file/or/directory
```

!!! Note
    When building from a local container, all previous definition files that led to the creation of the current container will be stored in a directory within the container called `/.singularity.d/bootstrap_history`. SingularityCE will also alert you if environment variables have been changed between the base image and the new image during bootstrap.

[Related documentation online...](https://docs.sylabs.io/guides/latest/user-guide/appendix.html#build-localimage)