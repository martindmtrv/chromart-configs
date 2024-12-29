# Configs for self hosted server

## Windows vm

TODO: remove me

Under `/etc/libvirt/hooks` added some scripts to run when starting and ending windows VM. Currently, using GPU passthrough and CPU pinning so the host vm only has 2 cores left and everything else is assigned to the windows VM for game streaming. Also switching to `performance` CPU governor while running the VM

`martgame.xml` is a snapshot of the VM configuration. The important stuff to rememeber is CPU topology, pci GPU passthrough and network cards. 

`default.xml` includes static ip mappings and disabling dns.


## systemd unit files

These unit files are to mount 2 volumes from my PC and combine them with mergerfs. Could not get away with just /etc/fstab due to docker dependancies. In short, mounts both 3TB HDD volumes from the PC in `/mnt/nas/data*`. Once this completes, the mergerfs service runs to combine them into one directory `/mnt/nas/pool`. This mergerfs target blocks the start of the docker service, which should ensure that all volumes are mounted before docker starts up again.

TODO: remove me

virtwold is a daemon that listens on the network device `enp42s0` for WOL packets from Moonlight to wake the windows VM. to start it `sudo systemctl enable virtwold-wol@enp42s0.service`

wakeonlan-enable.service

Runs ethtool on boot to ensure that the ethernet adapter sets wake on lan to enabled so we can boot the pc when it is off.

## docker config json

https://www.reddit.com/r/selfhosted/comments/1az6mqa/psa_adjust_your_docker_defaultaddresspool_size/

## docker daemon json

This allows us to use a local docker registry over http. This is on the local network only, so it is fine that it is not using HTTPS

## mount libvirtd virtual drives

To extract data from the windows VM, instead of running a webserver inside the VM you can mount the .qcow2 file itself into linux using nbd.

https://wiki.archlinux.org/title/QEMU#Mounting_a_partition_from_a_qcow2_image

After mounting the drive into /mnt/windows, you can open the fileserver to serve it by editing the stack itself to include a windows directory.

## /etc/fstab
This contains the mounting instructions for all the chromart drives. The 2 main HDD drives (formerly NAS drives) are mounted at /mnt/nas/drive*. 

We then make a bind mount from /mnt/nas/drive* to /mnt/nas/data* for backwards compatibility to the mergerfs pool. These are awaiting for the HDDs to mount successfully before they can run. This has nofail so in case the drives are busted we can still boot.

The mergerfs mount is a systemd unit file, and it requires /mnt/nas/data* to mount successfully before it starts. This blocks docker from starting too, so we don't boot containers if we are missing drives (to prevent data corruption).
