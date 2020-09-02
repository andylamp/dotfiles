# Set up pi-hole

This largely based on the guide provided [here][1], but tailored for my specific purposes.

# Configuring the image

```yaml 
version: "3"
# create the pihole service
services:
  pihole:
    container_name: pihole
    image: pihole/pihole:latest
    ports:
      - "53:53/tcp"
      - "53:53/udp"
      - "67:67/udp"
      - "8080:80/tcp"
      - "44380:443/tcp"
    environment:
      TZ: 'America/Chicago'
      # WEBPASSWORD: 'set a secure password here or it will be random'
    # Volumes store your data between container upgrades
    volumes:
       - './etc-pihole/:/etc/pihole/'
       - './etc-dnsmasq.d/:/etc/dnsmasq.d/'
    dns:
      - 127.0.0.1
      - 1.1.1.1
    # Recommended but not required (DHCP needs NET_ADMIN)
    #   https://github.com/pi-hole/docker-pi-hole#note-on-capabilities
    cap_add:
      - NET_ADMIN
    restart: unless-stopped
```

Of course

Now you can use [this][2] bash script compile it, build it, and launch it.

# Configuring ufw

[1]: https://hub.docker.com/r/pihole/pihole/
[2]: ./