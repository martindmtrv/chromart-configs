cpupower frequency-set --governor performance
systemctl set-property --runtime -- user.slice AllowedCPUs=0,8
systemctl set-property --runtime -- system.slice AllowedCPUs=0,8
systemctl set-property --runtime -- init.scope AllowedCPUs=0,8