# Configs for self hosted server

## Windows vm

Under `/etc/libvirt/hooks` added some scripts to run when starting and ending windows VM. Currently, using GPU passthrough and CPU pinning so the host vm only has 2 cores left and everything else is assigned to the windows VM for game streaming. Also switching to `performance` CPU governor while running the VM

`martgame.xml` is a snapshot of the VM configuration. The important stuff to rememeber is CPU topology, pci GPU passthrough and network cards. 

`default.xml` includes static ip mappings and disabling dns.


## systemd unit files

These unit files are to mount 2 volumes from my NAS and combine them with mergerfs. Could not get away with just /etc/fstab due to network dependancies. In short, mounts both 3TB HDD volumes from the NAS in `/mnt/nas/data*`. Once this completes, the mergerfs service runs to combine them into one directory `/mnt/nas/pool`. This mergerfs target blocks the start of the docker service, which should ensure that all volumes are mounted before docker starts up again.

virtwold is a daemon that listens on the network device `enp42s0` for WOL packets from Moonlight to wake the windows VM. to start it `sudo systemctl enable virtwold-wol@enp42s0.service`

## docker config json

https://www.reddit.com/r/selfhosted/comments/1az6mqa/psa_adjust_your_docker_defaultaddresspool_size/

## mount libvirtd virtual drives

To extract data from the windows VM, instead of running a webserver inside the VM you can mount the .qcow2 file itself into linux using nbd.

https://wiki.archlinux.org/title/QEMU#Mounting_a_partition_from_a_qcow2_image

After mounting the drive into /mnt/windows, you can open the fileserver to serve it by editing the stack itself to include a windows directory.