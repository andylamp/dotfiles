# Cockpit

The [cockpit project][1] is a management software that runs within the context of a browser.
It can be used as a "cheap" alternative to proper IPMI/KVM solutions.

## Installation

To install this in a debian based system all you need to do is to run the following commands:

```bash
sudo apt-get -yy install cockpit
```

## UFW config

You will need to configure `ufw` in order to allow `cockpit` to be accessible over the network.
To do so, we need to first create an `ufw` rule that is normally placed in `/etc/ufw/applications.d/`.
The full definition of the rule follows:

```shell
[cockpit-web]
title=cockpit server management web interface
description=cockpit server management web interface port
ports=9090/tcp
```

Then, after creating the rule and copying it to the appropriate directory - we need to enable it as such:

```shell
# allow cockpit-web in ufw from specific domain (recommended)
sudo ufw allow from 10.10.1.0/24 to any app cockpit-web
# allow cockpit-web in ufw from any
sudo ufw allow cockpit-web
```

We can test that the rule is applied correct by using:

```shell
# replace <cockpit-web-port> with the port that cockpit-web listens to, normally 9090.
sudo ufw status verbose | grep <cockpit-web-port>
# or by using 22 (this is for my own copy-paste).
sudo ufw status verbose | grep 9090
```

## Cockpit service & start on boot

Cockpit service is installed by default upon installation; however, you need to enable it for it to start.
To do so, we can run the following command:

```shell
# this is to enable the service
sudo systemctl enable cockpit
# this is to start the service
sudo systemctl start cockpit
# this is to check its status
sudo systemctl status cockpit
```

In order to start `cockpit` upon boot - we need to enable the `cockpit.socket` service which is installed by default.
This can be performed by the following command:

```shell
# this is to enable the cockpit.socket service - enabled boot-up start
sudo systemctl enable cockpit.socket
# this is to start the service (it is also stated by the regular cockpit service as well)
sudo systemctl start cockpit.socket
# this is to check its status
sudo systemctl status cockpit.socket
```

## Config

Configuration documentation that cockpit project provides is very good; however, I immediately found a need to change
the session timeout period so here is how to do that.

```shell
# open settings
sudo vim /etc/cockpit/cockpit.conf
```

There we need to change the `IdleTimeout` variable from `15` to a larger value:

```shell
[Session]
IdleTimeout=640
```

[1]: https://cockpit-project.org/

[2]: https://cockpit-project.org/guide/latest/cockpit.conf.5.html