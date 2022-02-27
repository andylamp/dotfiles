# Linux Volume Manager notes

This is a collection of notes that might help in the future when I have to deal with lvm
partition resizes.

## List groups and volumes

To list the logical groups in the system we can use:

```bash
$ sudo vgs
  VG         #PV #LV #SN Attr   VSize    VFree
  vg_boot      1   3   0 wz--n-   92.20g  12.99g
  vg_scratch   1   1   0 wz--n- <931.51g 186.30g
```

To list the logical volumes in the system:

```bash
$ sudo lvs
  LV      VG         Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  home    vg_boot    -wi-ao---- <38.26g
  root    vg_boot    -wi-ao----  40.00g
  swap    vg_boot    -wi-a----- 976.00m
  scratch vg_scratch -wi-ao---- 745.20g
```

## Expand a logical volume

Assuming we want to expand the following partition:

```bash
/dev/mapper/vg_boot-root        7.5G 7.5G     0 100% /
```

We can do so by performing the following commands:

```bash
lvextend -L + 10G vg_boot/root
```

The above command would add 10GB of storage to the `vg_boot` volume for the `root`
directory that resides inside it. However, this only allocates the data in it, but
does _not_ resize the actual file system so the changes are reflected. To do so, we
need to perform the following command:

```bash
resize2fs /dev/mapper/vg_boot-root
```

Which expands the file system to reflect the newly allocated storage in the volume.
