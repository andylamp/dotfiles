# Handling Samba v4

This brief guide will address how to serve volumes from a unix server to other clients (unix/windows/macos) using the
Samba v4 protocol. The server in this guide is assumed to run a Debian based distribution, such as Ubuntu and this guide
was tested on Ubuntu 19.04 / 19.10.

Further, since this guide is meant to be used in a server we will be using exclusively command line tools; there are GUI
ways to go about this, but they have proved in the past quite unreliable (at best).

## Preliminaries

First, we have to install the packages that deal with the Samba protocol itself - we can do so by using the following
line:

```bash
sudo apt install -y samba smbclient
```

## Configuring whole drive mounts

To setup our network shares, we need to first determine which drives we want to share; to do so we must list the
available drives by their `UUID`:

```bash
# list all drives using their UUID
sudo lsblk -f
```

This will result in a similar output like below

```bash
NAME   FSTYPE     LABEL                 UUID                                 FSAVAIL FSUSE% MOUNTPOINT
sda
├─sda1
└─sda2 ntfs       Drive 1               7CE03C4BE03C0DC0                      460,1G    84% /mnt/7CE03C4BE03C0DC0
sdb
└─sdb1 ntfs       Drive 2               34E89026E88FE508                      211,1G    89% /mnt/34E89026E88FE508
sdc
└─sdc1 ntfs       Spare 3               7A82CBBC82CB7B61                      276,8G    85% /mnt/7A82CBBC82CB7B61
sdd
└─sdd1 ntfs       Music                 505C835A5C833A2C                      335,5G    82% /mnt/505C835A5C833A2C
sde
└─sde1 ntfs       Media Drive           96FEF8B2FEF88C2D                        209G    89% /mnt/96FEF8B2FEF88C2D
```

Currently these drives are mounted but we are interested in their UUID as we will need to edit the `fstab` file in order
them to be auto-mounted. An example of an `fstab` entry on how to mount them in the above mount-points is shown below:

```bash
# fstab bits that allow mounts by UUID to the respective mount-points
/dev/disk/by-uuid/7CE03C4BE03C0DC0 /mnt/7CE03C4BE03C0DC0 auto nosuid,nodev,rw,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/34E89026E88FE508 /mnt/34E89026E88FE508 auto nosuid,nodev,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/7A82CBBC82CB7B61 /mnt/7A82CBBC82CB7B61 auto nosuid,nodev,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/505C835A5C833A2C /mnt/505C835A5C833A2C auto nosuid,nodev,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/96FEF8B2FEF88C2D /mnt/96FEF8B2FEF88C2D auto nosuid,nodev,nofail,x-gvfs-show 0 0

# if you want to force ntfs-3g driver you can use the following (ensure ntfs-3g package is installed first!)
/dev/disk/by-uuid/7CE03C4BE03C0DC0 /mnt/7CE03C4BE03C0DC0 ntfs-3g nosuid,nodev,rw,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/34E89026E88FE508 /mnt/34E89026E88FE508 ntfs-3g nosuid,nodev,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/7A82CBBC82CB7B61 /mnt/7A82CBBC82CB7B61 ntfs-3g nosuid,nodev,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/505C835A5C833A2C /mnt/505C835A5C833A2C ntfs-3g nosuid,nodev,nofail,x-gvfs-show 0 0
/dev/disk/by-uuid/96FEF8B2FEF88C2D /mnt/96FEF8B2FEF88C2D ntfs-3g nosuid,nodev,nofail,x-gvfs-show 0 0
```

If you cannot mount them in read/write mode and the drive uses an `NTFS` filesystem then it might be the case that it's
marked as "dirty"; this can be easily fixed. To achieve this we have to install `ntfs-3g` package (if not already
installed) which includes the `ntfsfix` utility that we are going to use to alleviate this problem.

```bash
# install ntfs-3g package
sudo apt install -y ntfs-3g
```

Then we can use `ntfsfix` using the following command, for each drive `UUID`, to fix the issues - we have to do this for
each one of the drives but below we are only showing an example applied to *one* drive.

```bash
# fix the ntfs partition of drive with UUID 7A82CBBC82CB7B61
sudo ntfsfix /dev/disk/by-uuid/7A82CBBC82CB7B61
```

Please ensure that each drive you want to be (auto-)mounted is present in the `fstab` before proceeding.

## Configure mounts within Samba

There are two types of mounts that we can one, *public* (open) and *private* (password protected) all of which will be
configured from `/etc/samba/smb.conf`.

### Public mounts

To configure a public mount, first we need to prepare a directory (or drive) in order to be able to be read and edited
by all. This can be achieved if we are using a directory as follows:

```bash
# only if we are doing a directory
sudo mkdir -p /opt/public-mount
sudo chown nobody:nogroup /opt/public-mount
sudo chmod 777 /opt/public-mount
```

Or, if want to mount an entire drive:

```bash
sudo chown nobody:nogroup /mnt/7A82CBBC82CB7B61
sudo chmod 777 /mnt/7A82CBBC82CB7B61
```

I highly recommend that you do *not* share entire drives like this but only directories.

Then we need to edit the `smb.conf` file to reflect our new mount as such:

```bash
# in smb conf for public mount
[public-mount]
    comment = Public Mount
    path = /opt/public-mount
    browsable = yes
    guest ok = yes
    read only = no
    create mask = 755
```

This says to `Samba` that the directory `/opt/public-mount` will be mounted as `public-mount` and will be browsable and
editable by all while each folder/file created will have a (unix) permission mask of `755`. You will be able to access
it using through a samba client using `smb://server-ip/public-mount` or in Windows `//server-ip/public-mount`.

### Private mounts (recommended)

Now we will deal on how to create *private* Samba mounts, which is the *recommended* option in most cases. Assuming we
have the mount points as before we can easily share a whole drive by editing `smb.conf` as follows.

```bash
# in smb conf for private mount
[private-drive]
    comment = Private Mount
    path = /mnt/7A82CBBC82CB7B61
    browsable = no
    guest ok = no
    read only = no
    create mask = 755
```

#### Configuring a user with password

As mentioned previously, this says to `samba` that the directory `/opt/public-mount` will be mounted as `public-mount`
and will be browsable and editable by authenticated users while each folder/file created will have a (unix) permission
mask of `755`. Now, since `Samba` does not use unix passwords we need to create a unix password for each user that we
want to provide access; this can be done using the following command.

```bash
sudo smbpasswd -a <user>
```

Each authenticated user will now be able to access it using through a samba client using `smb://server-ip/private-drive`
or in Windows `//server-ip/private-drive`.

## Configuring UFW

This can be done in two ways - we will only discuss *local* deployments which means that our Samba v4 is intended to
serve folders and mounts within the local network.

To do this we just have to create a file named [`samba4`][1] in `/etc/ufw/applications.d/` containing the following:

```ufw
[samba4]
title=Samba 4
description=Samba 4 protocol ports
ports=53|88|135/tcp|137/udp|138/udp|139/tcp|389|445/tcp|464|636/tcp|1024:5000/tcp|3268/tcp|3269/tcp|5353
```

Then we need to enable this from `ufw` by using:

```bash
# this allows all ports from any ip and network
sudo ufw allow sambda4
# this allows all ports from any ip in my local network range (192.168.178.xxx)
sudo ufw allow from 192.168.178.0/24 to any app samba4
```

## Debugging hints

The following two commands are very handy if you need to pick your way into what is going on (or wrong).

```bash
# tests and lists the samba mounts in //remote-system - can either be used in anon or login mode.
smbclient -L //remote-system
```

```bash
# tests if the smb.conf is valid and -s suppresses prompts after each service definition (i.e. - mount point)
testparm -s
```

```bash
# retrieve the status, version, and source of installed samba packages.
dpkg-query -W -f='${Package} ${Version} ${Source} ${Status}\n' | grep samba
```

## Windows hosts debugging hints

The following tips can be used when a Windows host has trouble connecting to the `CIFS` mount provided by `samba`

### Drives disappear or cannot connect

This can mean a lot of things, however the immediate thing that should happen is to check if the share works on other
machines or operating systems (e.g. `MacOS`).

If this does *not* work, then disconnect/remove the drives by going over to `regedit`

```regedit
\HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2
```

There you will find all the mounts that are mapped to be shown through Windows Explorer - delete the ones that are from
the problematic share and re-map them. As far as I am aware there no easier way to do this; thankfully, to apply the
changes no full machine is required - just restarting the Windows Explorer will do the trick.

## Final touches

Please after every change in either configuration or users perform a `Samba` service restart using the below command:

```bash
sudo systemctl restart smbd.service nmbd.service
```

[1]: ../shared/ufw-rules/samba4