# Creating a system service

## Create a sysservice file
sudo nano /etc/systemd/system/[service name].service

## Add contents to sysservice file
``
[Unit]
Description={service description}
After=network.target    ## SEE COMMENTS 1

[Service]
ExecStart={/Path/To/Binary} {Optional launch options}
Restart=no   ## SEE COMMENTS 2
User=root
ExecStop={Shutdown commands}

[Install]
WantedBy=multi-user.target
``

## reload sysconfig
sudo systemctl daemon-reload

## Start service
sudo systemctl start [service name]


## Check status
sudo systemctl status [service name]

## Enable start at boot time
sudo systemctl enable [service name]

# COMMENTS

## 1.
Ensures service doesn't start before network services are up

## 2. 
Other variants:
- Restart=no 
    - systemd will not attempt to restart the service if it fails.

- Restart=on-failure
    - systemd will only attempt to restart the service if it fails with an exit status other than 0.
    
- Restart=on-abnormal
    - systemd will attempt to restart the service if it fails with an abnormal exit status (such as a segmentation fault).
    
- Restart=on-success
    - systemd will never attempt to restart the service, even if it exits with a non-zero status.
