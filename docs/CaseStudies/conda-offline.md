# Container for offline conda installation

Installing conda packages on a computer without Internet is somewhat challenging. One common approach is to `conda-pack` your environment, transfer the pack, then unpack it on the other computer - [link](https://hackmd.io/@pmitev/Python_Bianca#Using-conda). Or cache all required packages in a local channel that you can bring offline - [link](https://hackmd.io/@pmitev/Conda_install_offline).

Here we will demonstrate an easy way to cache the packages in the container, so you can easily install the same environment on a machine without Internet.

Here is a simple scenario. 

```bash
$ conda create -y -n test
$ conda install -y -n test python=3.8 pytorch torchvision torchaudio cudatoolkit=11.1 -c pytorch-lts -c nvidia
```

Here is a recipe to cache all necessary packages in the container.

```singularity
Bootstrap: docker
From: continuumio/miniconda3

%post
  export LC_ALL=C
  conda info

/bin/bash <<EOF
  conda create -y -n test
  conda install -y -n test python=3.8 pytorch torchvision torchaudio cudatoolkit=11.1 -c pytorch-lts -c nvidia
EOF

%runscript
  conda "$@"
```

```bash
$ sudo conda build conda.sif miniconda3.def
```

> The final container is 6.1 GB ...

Then, copy the container on the remote computer without Internet and run exactly the same installation commands `--offline`. Note the additional `--copy` option as well.

```bash
./wharf/conda.sif create -n pytorch-test --offline
./wharf/conda.sif install -n pytorch-test python=3.8 pytorch torchvision
torchaudio cudatoolkit=11.1 -c pytorch-lts -c nvidia --offline --copy
```

Here is another variant.
You can export your environment 
```bash
$ conda env export -n my_env > my_env.yaml
```


```singularity
Bootstrap: docker
From: continuumio/miniconda3

%files
  my_env.yaml /opt

%post
  export LC_ALL=C
  conda info
  conda env create -n test -f /opt/my_env.yaml

  conda env remove -n test

%runscript
  conda "$@"
```

Then on the target machine:
```bash
$ ./wharf/conda.sif env create -n my_env -f my_env.yaml --offline --copy
```