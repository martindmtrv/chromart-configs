# swapping drive in the NAS

If there is a bad drive, you need to swap it out. This can happen due to bad sectors or a defective drive.

## One bad drive - not dead

## 1. copy over data

In this scenario, there was a bad sector on one drive. There is still hope to recover data thankfully.

For this, stop all docker containers `d-stopall`, then proceed to rsync over all data from bad drive to the second drive.

eg. copying from `data1` to `data2`

```
sudo rsync -rhp --progress --exclude '#Recycle' data1/ data2
```

Alternatively you can try mergerfs.consolidate, though I have not yet tried this https://github.com/trapexit/mergerfs-tools?tab=readme-ov-file#mergerfsconsolidate

## 2. Disable mount for the bad drive

On Chromart, disable the bad drive mount job

If drive 2 is bad:

```
# stop the mergerfs
sudo systemctl stop mnt-mergerfs-pool.service

# remove bad drive mount
sudo systemctl disable mnt-nas-data2.mount
sudo systemctl stop mnt-nas-data2.mount

# restart mergerfs
sudo systemctl start mnt-mergerfs-pool.service
```

## 3. Remove bad drive and install new one

Turn off chromart and shutdown the NAS. Physically remove the bad drive.

You can hook it up to another PC with USB mount and perform a shred of this drive

bash history for mounting the RAID drive, it had a weird format initially

```
udo mount /dev/sdc4 usbfront/
sudo mount -t ext4 /dev/sdc4 usbfront/
df
mdadm --assemble --run /dev/md0 /dev/sdc4
sudo mdadm --assemble --run /dev/md0 /dev/sdc4
sudo umount /dev/sdc4
df
mdadm --assemble --run /dev/md0 /dev/sdc4
sudo mdadm --assemble --run /dev/md0 /dev/sdc4
cat /proc/mdstat
ls /dev/md* | grep md126
ls
sudo mount /dev/md126 usbfront/
cd usbfront/
ls
cd data1
ls
df
cd ../
ls
cd ..
ls
sudo umount usbfront 
df
lsblk
cat /proc/mdstat
mdadm --stop /dev/mb125
sudo mdadm --stop /dev/md125
sudo mdadm --stop /dev/md126
sudo mdadm --stop /dev/md127
ls /dev/md*
lsblk
sudo mount -t ext4 /dev/sdc4 usbfront/

```

```
sudo shred -v /dev/sdX
```

At this point you should do RMA to WD for warranty, or get a new drive.

## 4. Boot up the nas and reconfigure the bad volume

Now with the new drive installed, the NAS will complain that the bad volume is inacessible. You have to go to 

storage manager > volume > select volume > remove

This will go through some prompts to confirm you are removing a volume. BE SURE YOU ARE REMOVING THE CORRECT ONE.

Once this is done, you will have a blank volume.

## 5. enable NFS

Go to 

access control > shared folders > add a new folder.

Create the folder on the volume to replace the one that was removed.  Volume1 = data1, Volume2 = data2

Go to access rights for this new folder > NFS priviledges.

Add 192.168.1.150 with read and write access, and optionally wildcard access.

## 6. boot up chromart and re-enable service

Re-enable the bad mount

```
# make sure containers are stopped
d-stopall 

# stop the mergerfs
sudo systemctl stop mnt-mergerfs-pool.service

# enable replaced drive mount
sudo systemctl enable mnt-nas-data2.mount
sudo systemctl start mnt-nas-data2.mount

# restart mergerfs
sudo systemctl start mnt-mergerfs-pool.service

d-startall
```


## 7. rebalance the drives

This is optional but reccomended. We should rebalance the pool, since the new drive will be basically empty.

eg. after replacing we see this not balanced pool

```
192.168.1.160:/volume2/data2 2878704256 1735763584 1142924288  61% /mnt/nas/data2
192.168.1.160:/volume1/data1 2878704256     103552 2875438592   1% /mnt/nas/data1
1:2                          5757408512 1735867136 4018362880  31% /mnt/nas/pool
```

Start a tmux session and run the following, this will rebalance the pool. It may take a long time

```
d-stopall

sudo mergerfs.balance /mnt/nas/pool -E */st-sync/* -s 1000
```

https://github.com/trapexit/mergerfs-tools?tab=readme-ov-file#mergerfsbalance