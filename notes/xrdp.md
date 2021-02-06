# Remote Desktop (rdp) on Unix

This can be quite a bit complicated depending on your setup and requirements. Mine were relatively simple, requiring
only a basic gnome session to be present.

## Installing xrdp

This is fairly straightforward - we install this package of any recent Ubuntu distribution as such:

```bash
sudo apt install -y xrdp
```

Of particular note, are distributions of the `18.xx` branch since they require the installation of another package to
work correctly. This package can be installed as is shown below.

```bash
sudo apt install -y xorgxrdp-hwe-18.04
```

## Configuring

After installation, we can use a valid `rdp` client (i.e. -- Windows RDP) to login to our machine. However, in order to
get a functional desktop we need to perform some other bits, as in the default configuration no window manager is
executed. To start a window manager we have to edit `startwm.sh` located in `/etc/xrdp/startwm.sh` - this can be done as
such:

```bash
sudo vim /etc/xrdp/startwm.sh
```

My complete `startwm.sh` file is included below, as it includes a fix for blank screen seen in [this][1] popular Github
issue of the `xrdp` project.

```bash
#!/bin/bash
# xrdp X session start script (c) 2015, 2017 mirabilos
# published under The MirOS Licence

#Improved Look n Feel Method
cat <<EOF > ~/.xsessionrc
export GNOME_SHELL_SESSION_MODE=ubuntu
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
export XDG_CONFIG_DIRS=/etc/xdg/xdg-ubuntu:/etc/xdg
EOF

unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR

if test -r /etc/profile; then
        . /etc/profile
fi

if test -r /etc/default/locale; then
        . /etc/default/locale
        test -z "${LANG+x}" || export LANG
        test -z "${LANGUAGE+x}" || export LANGUAGE
        test -z "${LC_ADDRESS+x}" || export LC_ADDRESS
        test -z "${LC_ALL+x}" || export LC_ALL
        test -z "${LC_COLLATE+x}" || export LC_COLLATE
        test -z "${LC_CTYPE+x}" || export LC_CTYPE
        test -z "${LC_IDENTIFICATION+x}" || export LC_IDENTIFICATION
        test -z "${LC_MEASUREMENT+x}" || export LC_MEASUREMENT
        test -z "${LC_MESSAGES+x}" || export LC_MESSAGES
        test -z "${LC_MONETARY+x}" || export LC_MONETARY
        test -z "${LC_NAME+x}" || export LC_NAME
        test -z "${LC_NUMERIC+x}" || export LC_NUMERIC
        test -z "${LC_PAPER+x}" || export LC_PAPER
        test -z "${LC_TELEPHONE+x}" || export LC_TELEPHONE
        test -z "${LC_TIME+x}" || export LC_TIME
        test -z "${LOCPATH+x}" || export LOCPATH
fi

if test -r /etc/profile; then
        . /etc/profile
fi

# alternative WM
# test -x /etc/X11/Xsession && exec /etc/X11/Xsession
# exec /bin/sh /etc/X11/Xsession
/usr/bin/gnome-session
```

I had to remove the any `~/.xsession` files in order to make everything work correctly as well as put these two very
important lines

```bash
unset DBUS_SESSION_BUS_ADDRESS
unset XDG_RUNTIME_DIR
```

Without these, I could not get a working gnome environment running using `xrdp` and `Xorg`.

## Resuming session(s)

To do this we need to tell `xrdp` to ask to use existing ports; to do that we need to edit `/etc/xrdp/xrdp.ini` and edit
our desired session type to `ask` for ports upon initiation as such:

```bash
[Xorg]
name=Xorg
lib=libxup.so
username=ask
password=ask
ip=127.0.0.1
port=ask-1
code=20
```

Note the `port` directive - it has `ask-1` meaning that it will either ask for port and if it is equal to `-1` it will
use either the default or new one. This will allow "easy resume" of sessions without each login generating a new one.

## Debug

We can find the port `xrdp` runs and which are the remote clients connected using the following command

```bash
andylamp@mezedaki:~/$ netstat -peant | grep 3389
(Not all processes could be identified, non-owned process info
 will not be shown, you would have to be root to see it all.)
tcp6       0      0 :::3389                 :::*                    LISTEN      125        30711      -
tcp6       0      0 192.168.178.63:3389     192.168.178.136:53737   ESTABLISHED 125        2107639    -
```

We can see that `xrdp` runs on port `3389` and we have one client connected to `mezedaki` at port `53737`.

## Shout-out

I do have to give a shout-out to [this][2] script which automates a lot of stuff and reading it helped me understand
how `xrdp` is set up.

[1]: https://github.com/neutrinolabs/xrdp/issues/1358

[2]: https://www.c-nergy.be/downloads/xrdp-installer-1.1.zip
