# Configs for self hosted server

## Windows vm

Under `/etc/libvirt/hooks` added some scripts to run when starting and ending windows VM. Currently, using GPU passthrough and CPU pinning so the host vm only has 2 cores left and everything else is assigned to the windows VM for game streaming. Also switching to `performance` CPU governor while running the VM

`martgame.xml` is a snapshot of the VM configuration. The important stuff to rememeber is CPU topology, pci GPU passthrough and network cards. 

`default.xml` includes static ip mappings and disabling dns.