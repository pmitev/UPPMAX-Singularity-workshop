# Running MariaDB server with Singularity

!!! note
    Before we even start, there is a better way to do this nowadays with this excellent and specially designed tool [DBdeployer](https://www.dbdeployer.com/).

Anyway, here is how this could be done with singularity.

Original source: [https://github.com/sylabs/examples/tree/master/database/mariadb](https://github.com/sylabs/examples/tree/master/database/mariadb)

1. Extract/copy `/etc/mysql/my.cnf` and edit the user, so it could run as specified user.
2. Build the Singularity container.
```singularity
Bootstrap: docker
From: mariadb:10.3.9

# https://github.com/sylabs/examples/tree/master/database/mariadb

%post
  export DEBIAN_FRONTEND=noninteractive
  export LC_ALL=C

  apt update && apt -y install vim 
  # replace `your-name` with your username, run `whoami` to see your username
  #YOUR_USERNAME="your-name"

  #sed -ie "s/^#user.*/user = ${YOUR_USERNAME}/" /etc/mysql/my.cnf
  #chmod 1777 /run/mysqld

%runscript
exec "mysqld" "$@"

%startscript
exec "mysqld_safe"
```
3. Start the server
```bash
$ singularity shell --writable-tmpfs -B db/:/var/lib/mysql  -B my.cnf:/etc/mysql/my.cnf mariadb.sif
```
Alternatively, you can make the configuration file writable by using overlays.
```bash
# add overlay
singularity overlay create --size 64 --create-dir /etc/mysql mariadb.sif

# start shell
singularity shell --writable-tmpfs -B db/:/var/lib/mysql mariadb.sif
# Edit the user inplace
sed -ie "s/^#user.*/user = NEWUSER/" /etc/mysql/my.cnf
```