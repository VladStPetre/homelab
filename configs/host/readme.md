## Server Host

Create docker context
```commandline 
docker context create echo --description "Docker on G3 - host: echo" --docker "host=ssh://echo.local"```
```

set env variables from .env file
```commandline
set -a; . ./.env; set +a
```
Create docker secrets
```commandline
printf 'supersecretsecret' | docker secret create <secret-name> -
```
## Server Steps 

Setup env by running the following scripts:

- setup-docker.sh -> install docker, docker compose and creates main docker network
- setup-python.sh -> install python 3, pip and paho-mqtt deps
- install ser2net for zigbee device (See below)
- configure fstab for nfs mounting
- install ext-hdd mount from jellyfin/

### Optional:

For host where media stack is installed, run content of directory: ./ext-hdd-mount 


### Configure nfs from NAS
Add line to /etc/fstab
```commandline
# NAS NFS share
nas.local:/nfs-share  /mnt/nas  nfs  defaults,soft,nofail,noauto,x-systemd.automount,_netdev,timeo=25,x-systemd.idle-timeout=600,retrans=2  0  0
```

### Install and configure ser2net

Check the zigbee device id and paste if in the below config - 
```ls -l /dev/serial/by-id/```

```commandline
sudo apt-get install ser2net

sudo tee -a /etc/ser2net.yaml >/dev/null <<'YAML'
connection: &zha
    accepter: tcp,3333
    enable: on
    options:
      banner: *banner
      kickolduser: true
    connector: serialdev,/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20230807084107-if00,115200n81 ,nobreak,local
YAML

sudo systemctl enable --now ser2net
sudo systemctl start ser2net
sudo ss -lntp | grep 3333
```
