```
      .                               .      .;
    .'                              .'      .;'
   ;-.    .;.::..-.    . ,';.,';.  ;-.     .;  .-.
  ;   ;   .;   ;   :   ;;  ;;  ;; ;   ;   :: .;.-'
.'`::'`-.;'    `:::'-'';  ;;  ';.'`::'`-_;;_.-`:::'
                     _;        `-'
```

## Scalable Disk File Systems

| System | Raspbian Packages           | Partition       | Mount           |
| ------ | --------------------------- | --------------- | --------------- |
| BtrFS  | `btrfs-progs btrfs-tools`   | `/dev/sda2`     | `/mnt/btr`      |
| EXT4   | `e2fsprogs`                 | sd card         | `/`             |
| XFS    | `xfsprogs xfsdump`          | `/dev/sda[1,5]` | `/mnt/xfs[-x]   |
| ZFS    | `zfs-dkms ~zfsutils-linux~` | `/dev/sda[3,4]` | `/mnt/zfs[-x]`  |

*Note*: data hosts a 64 GB USB stick, with a 16 GB partition (`/dev/sda5`)
        committed to the NFS share. Mount points marked `-x`, *e.g.*
        `/mnt/xfs-x`, are intended for export over the wired.

## Distributed File Systems

| System    | Raspbian Packages                   | Mount        |
| --------- | ----------------------------------- | ------------ | 
| BeeGFS    | [git.beegfs.com][bgit]              | `data/zfs-x` | 
| GFS2      | `gfs2-utils`                        |              |
| GlusterFS | `glusterfs-client glusterfs-server` | `/mnt/xfs`   |
| Lustre    | `linux-patch-lustre lustre-source`  | `/mnt/zfs1`  |
| NFS       | `nfs-common nfs-kernel-server`      | `data/xfs-x` |
| OrangeFS  | [docs.orangefs.com][ofsd]           |              |


[bgit]: https://git.beegfs.com/pub
[lgit]: git://git.hpdd.intel.com/fs/lustre-release.git
[ofsd]: http://docs.orangefs.com/