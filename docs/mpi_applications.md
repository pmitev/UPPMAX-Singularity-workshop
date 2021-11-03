# Singularity and MPI applications

The Singularity documentation is excellent starting point - [link](https://sylabs.io/guides/3.8/user-guide/mpi.html)

The C3SE Singularity has really nice summary that is included bellow - [source](https://www.c3se.chalmers.se/documentation/applications/containers-advanced/#running-singularity-with-mpi-across-multiple-nodes)

## **Running singularity with MPI across multiple nodes**
- There are four main components involved in a containerised MPI-based application:  
:   1.The executable MPI program (e.g. a.out)  
    2.The MPI library  
    3.MPI runtime, e.g. mpirun  
    4.Communication channel, e.g. SSH server

- Depending on how to containerise those elements, there are two general approaches to running a containerised application across a multi-node cluster:  
:   1.Packaging the MPI program and the MPI library inside the container, but keeping the MPI runtime outside on the host  
    2.Packaging the MPI runtime also inside the container leaving only the communication channel on the host

## **Host-based MPI runtime**
In this approach, the mpirun command runs on the host: `$ mpirun singularity run myImage.sif myMPI_program`

mpirun does, among other things, the following: * Spawns the ORTE daemon on the compute nodes * Launches the MPI program on the nodes * Manages the communication among the MPI ranks

This fits perfectly with the regular workflow of submitting jobs on the HPC clusters, and is, therefore, the recommended approach. There is one thing to keep in mind however:  
The MPI runtime on the host needs to be able to communicate with the MPI library inside the container; therefore,  
:   i) there must be the same implementation of the MPI standard (e.g. OpenMPI) inside the container, and,  
    ii) the version of the two MPI libraries should be as close to one another as possible to prevent unpredictable behaviour (ideally the exact same version).

## **Image-based MPI runtime**
- In this approach, the MPI launcher is called from within the container; therefore, it can even run on a host system without an MPI installation (your challenge would be to find one!):  
 `$ singularity run myImage.sif mpirun myMPI_program`
- Everything works well on a single node. There's a problem though: as soon as the launcher tries to spawn into the second node, the ORTED process crashes. The reason is it tries to launch the MPI runtime on the host and not inside the container.
- The solution is to have a launch agent do it inside the container. With OpenMPI, that would be:  
`$ singularity run myImage.sif mpirun --launch-agent 'singularity run myImage.sif orted' myMPI_program`