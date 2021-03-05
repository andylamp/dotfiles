# ZFS notes

This note describes how to create a [zfs][1] pool with some minor tweaks that I did with mine. Why `zfs`? For start,
see [here][5]. It is meant to be a reference mostly to me, rather than anyone else - so do not treat it as a
comprehensive manual.

## Installing zfs

This applies to `debian` based distributions; in which you can use the following command in order to install `zfs`:

```shell
sudo apt install -yy zfsutils-linux
```

After installation, you can make a sanity check to see that it is indeed installed as follows:

```shell
# now to check if its correctly installed
whereis zfs
# you could get something like this as an output
andylamp@nas-home:~$ whereis zfs
zfs: /usr/sbin/zfs /etc/zfs /usr/share/man/man8/zfs.8.gz
```

## Creating a pool

This is where most of the hard choices need to be made - generally speaking you cannot add capacity to a `zpool`
by expanding it. Another choice that needs to be made is what type of pool to use, I personally always use `raidz2`,
which can also be thought as the `zfs` RAID6. In a nutshell it provides a good balance of speed but also allows me
to lose two whole disks before I lose any data.

In my search for these choices, I poked around the web and found quite a few helpful resources.
To name a few with brief description of context are:

- [Discussion about performance, capacity, and integrity][2],
- [Creation of the pool][3],
- [Calculation of loss][4].

After reading (or not) the material provided, we can then list the available disks that can be put in a `pool`.
For me, all of my platter-disks are the ones I want to use for my pool, which we can list as follows:

```shell
andylamp@nas-home:~$ sudo fdisk -l /dev/sd* | grep "Disk /dev"
Disk /dev/sda: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sdb: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sdc: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sdd: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sde: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sdf: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sdg: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
Disk /dev/sdh: 12,75 TiB, 14000519643136 bytes, 27344764928 sectors
```

Now to create the pool, we need to invoke the `zpool` command; briefly its syntax for the pool creation is:

```shell
# default command to create the pool
sudo zpool create <pool_name> <raid_type> /dev/sda ... /dev/sdn
# this is to specific a mount point for the pool instead of the /<pool_name>
sudo zpool create -m <mount_point> <pool_name> <raid_type> /dev/sda ... /dev/sdn
```

Now in order to create the `zpool` using the drives above, we can do so with the following command:

```shell
# now create a z2 (aka RAID6) pool, the name is liberal.
sudo zpool create gavatha raidz2 /dev/sda /dev/sdb /dev/sdc /dev/sdd /dev/sde /dev/sdf /dev/sdg /dev/sdh
```

After creating the pool, we can check its status as follows:

```shell
andylamp@nas-home:~$ zpool status
  pool: gavatha
 state: ONLINE
  scan: none requested
config:

    NAME        STATE     READ WRITE CKSUM
    gavatha     ONLINE       0     0     0
      raidz2-0  ONLINE       0     0     0
        sda     ONLINE       0     0     0
        sdb     ONLINE       0     0     0
        sdc     ONLINE       0     0     0
        sdd     ONLINE       0     0     0
        sde     ONLINE       0     0     0
        sdf     ONLINE       0     0     0
        sdg     ONLINE       0     0     0
        sdh     ONLINE       0     0     0

errors: No known data errors
```

Another useful command is `zpool list`, which lists the pools in our system:

```shell
# we list the pools available
andylamp@nas-home:~$ zpool list
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
gavatha   102T  1,76M   102T        -         -     0%     0%  1.00x    ONLINE  -
```

## Tuning pool parameters

Now, this is not something I came up with, but is here for future reference. After poking around we can set tune its
parameter; it is advised that you do this **before** actually creating/copying any files in the pool. The syntax of the
tune command is as follows:

```shell
# set parameter to pool and all not locally set sub-pools
zfs set <parameter>=<value> <pool>
# set parameter for a specific sub-pool
zfs set <parameter>=<value> <pool>/<subpool>
```

- `xattr=sa`, default `xattr=on`
- `acltype=posixacl`, default `acltype=off`: this is to support ACL permissions for files, I only want to use `poxix`
  compliant options, where possible.
- `compression=lz4`, default `compression=off`: this is to enable compression, if your CPU is decent it should pose no
  performance penalty. I **highly** suggest that you turn this on, if you have the horsepower.
- `atime=off`, default `?`: This tags each file whenever it is read; it's useless for me, and a moot performance
  penalty, so I always turn if off.
- `relatime=off`, default `?`: Similar to the previous flag, this is an optimised version of `atime`; again, I always
  disable it.

Now the application of these commands is presented for the convenient copy-pasta:

```shell
sudo zfs set xattr=sa gavatha
sudo zfs set acltype=posixacl gavatha
sudo zfs set compression=lz4 gavatha
sudo zfs set atime=off gavatha
sudo zfs set relatime=off gavatha
```

[1]: https://en.wikipedia.org/wiki/ZFS

[2]: https://calomel.org/zfs_raid_speed_capacity.html

[3]: https://www.svennd.be/create-zfs-raidz2-pool/

[4]: https://wintelguy.com/zfs-calc.pl

[5]: https://serverfault.com/questions/1017443/how-beneficial-are-self-healing-filesystems-for-general-usage?noredirect=1&lq=1