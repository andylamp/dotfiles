# iPerf3

[iPerf3][1] utility is designed to test the connection speed between two hosts, even if a bit [unreliable at times][2],
it is an invaluable tool for gauging the rough performance of the network. This is meant as a rough collection of my
notes on the matter for future reference, rather than a complete guide.

## Measuring speed

In order to measure the speed we need to do two things:

1. Run the `iperf3` server using: `iperf3 -s`
1. Then, after the server is up execute at the client `iperf3 -c <hostname>`

There are three scenarios that we would like to test, these are the following:

1. Memory to memory
1. Memory to disk
1. Disk to memory

These tests assume that the server port which `iperf3` will listen to is open and accessible prior to this.
For more details please head over at the bottom of the page where we discuss `ufw` configuration.

### Memory to memory

This is the most common use-case for speed-tests and can be performed as follows; first we run the following command
on the server:

```shell
# server-side:
iperf3 -s
```

Then after starting the server, we run the following to the client:

```shell
# client-side:
iper3 -c <hostname>
# multi-threaded client-side:
iperf3 -c <hostname> -P <threads>
```

### Memory to disk

This is another common use-case where the server ingests and stores everything to a file.

Server side:

```shell
# server-side:
iperf3 -s -F <outfile>
```

Then after starting the server (and ensuring) `5201` port is open to it, we run the following to the client:

```shell
# client-side:
iper3 -c <hostname>
# multi-threaded client-side:
iperf3 -c <hostname> -P <threads>
```

### Disk to memory

Finally, we have the disk to memory where the sever ingests data in-memory coming from the client read by a file on
disk. To do this, we run the following commands.

Server side:

```shell
# server-side:
iperf3 -s
```

Client side:

```shell
# client-side:
iper3 -c <hostname> -F <infile>
# multi-threaded client-side:
iperf3 -c <hostname> -P <threads> -F <infile>
```

## Configuring ufw

Obviously, in order to test it with a server we need to allow through the firewall - normally iperf3 in server mode
uses port `5201` and can be written as an `ufw` rule as follows:

```shell
[iperf3-server]
title=iperf3 server
description=iperf3 server port
ports=5201/tcp|5201/udp
```

The `ufw` rules are normally placed under: `/etc/ufw/applications.d/`. Having the rule created, we also need to allow it
through `ufw`; please note that the name in the brackets `[<name>]` *matters* and is the actual rule name which you need
to use when applying it.

```shell
# allow iperf3-server in ufw from specific domain (recommended)
sudo ufw allow from 10.10.1.0/24 to any app iperf3-server
# allow iperf3-server in ufw from any
sudo ufw allow iperf3-server
```

Test that it was correctly applied we can use the following commands:

```shell
# replace <iperf3-server-port> with the port that iperf3-server listens to, normally 5201.
sudo ufw status verbose | grep <iperf3-server-post>
# or by using 5201 (this is for my own copy-paste).
sudo ufw status verbose | grep 5201
```

[1]: https://iperf.fr/

[2]: https://www.reddit.com/r/homelab/comments/g53kew/slow_iperf3_result_on_10gb_network_between_a/