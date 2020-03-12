# Adding unifi as a docker container

First of all make sure you have `docker` installed in your machine; to do this, we will use the popular unifi linux server image [here][1].

## Creating the image

I elect, almost always, to use `docker-compose`, which is a different utility and installed separately from normal `docker` - so please make sure it is also installed.
Creating a `yaml` for the image is relatively straightforward; below is my exact `yaml` I used for my `unifi-controller`:

```yaml
version: "3"
services:
  unifi-controller:
    image: linuxserver/unifi-controller
    container_name: unifi-controller
    environment:
      - PUID=1000
      - PGID=1000
      - MEM_LIMIT=2048M # increased max memory from 1G to 2G
    volumes:
      - /opt/unifi-controller/config:/config # note here!
    ports:
      - 3478:3478/udp
      - 10001:10001/udp
      - 8080:8080
      - 8081:8081
      - 8443:8443
      - 8843:8843
      - 8880:8880
      - 6789:6789
    restart: unless-stopped
```

Notable changes are that I mapped the configuration `config` to be mounted in my *local* directory `/opt/unifi-container/config`. 
Configuring it like this, it makes upgrading the actual controller, without losing the configuration, very easy.
To build the image and starting it we can use the following command:

```bash
docker-compose -f unifi-controller.yaml up
```

If we wish to just build it and perhaps start it later on we can use:

```bash
# build with no start
docker-compose -f unifi.yaml up --no-start
# then later on, to start it use
docker start unifi-controller
```

In order to make everything work as expected, even though the ports are bound correctly from `docker` to `localhost` it has to be noted that we need to *also* enable `ufw` rules for the `unifi` controller to work as expected.

## Configuring UFW

This can be done in two ways - we will only discuss *local* deployments which means that the controller is intended to discover AP's within the local network.

To do this we just have to create a file named [`unifi-local`][2] in `/etc/ufw/applications.d/` containing the following:

```
[unifi-local]
title=Unifi controller (Local)
description=Unifi Controller Ports in ufw (Local that includes discovery and AP-EDU ports)
ports=8080,8443,8880,8843,6789/tcp|3478,5656:5699,10001,1900/udp
```

Then we need to enable this from `ufw` by using:

```bash
sudo ufw allow unifi-local
```

That's it! You should be good to go! Enjoy your Ubiquiti AP's!

## Important!

After you've setup all of the related information you might not be able to discovery *any* equipment - this is due to the `dockerised` image as the host IP is not the same as the `docker` internal one. 
This is the case that even if the ports are bound correctly and everything looks right - the `inform` URL will be wrong as it would use an internal (to `docker`) IP of the controller that would not be known outside of the `docker`.
To alleviate this, you'd need to configure the `inform` address of the controller which can be changed from `Settings` -> `Controller Settings` -> `Advanced Configuration` -> `Controller Hostname/IP`.
You should set that to the either a resolvable name of your `docker` host or its *local* network IP address. 


[1]: https://hub.docker.com/r/linuxserver/unifi-controller
[2]: ../shared/ufw-rules/unifi-local