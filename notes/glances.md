# Glances monitoring

Glances is great task manager replacement tool (and much more) - it's my preferred way to get a summary of my system resources with ease.
Since I have only used this in `Unix` based machines I cannot comment how well it works on Windows.

# Installing it

To install it you can either use your distribution package manager (in this case `Ubuntu`) and install it as such:

```bash
sudo apt -y install glances
```

This is the easiest way to install it with minimal effort but do note that you will probably install a version that is not up-to-date with the latest and greatest...
If you want that you would have to install it through this script:

```bash
curl -L https://bit.ly/glances | /bin/bash
```

or through `pypi`, as such:

```bash
# if you are using python 2 (or have pip as default for python 3)
pip install glances
# or if you want to install it for python 3 by default.
pip3 install glances
```

Another great add on is to add `bottle` which is used to display `glances` over the web; it can be installed as such (in `Ubuntu`):

```bash
sudo apt install -y python3-bottle
```

# Launching

To launch glances, locally you can to this:

```bash
glances
``` 

or if you want to launch glances as a service, which you can access through the web, you can do the following:

```bash
glances -w
```

Please note that there are some encoding problems and it is highly suggested to use the following command to launch instead:

```bash
LC_ALL=en_US.UTF-8 glances -w &
```

For convenience, you can set them up as `aliases` if you have it installed as such:

```bash
# check if glances are installed, if so put my aliases
if [[ -x "$(command -v glances)" ]]; then
  # start regular glances
  alias g="glances"
  # start web server for glances
  alias gw="LC_ALL=en_US.UTF-8 glances -w &"
fi
```

# Layout

TBD

# HDDs (and, some, SDDs) temperature monitoring

To monitor the hard disk temperatures `glances` uses `hddtemp` utility (note: this one, not this as this one is a client).
In order to the temperatures to show `hddtemp` has to be running as a `daemon` in `localhost` - as such:

```bash
sudo hddtemp -d <disks>
```

Note the `sudo` - it is unfortunately required; otherwise you would get an error or invalid measurements.
One handy function that I use in my scripts is the following

```bash
# hdd temperature utility as a daemon
hddtempd() {
  # find block devices
  sds=$(lsblk --nodeps -n -o name | grep "sd" | tr '\n' ',' | sed 's/sd//g;s/\(.*\).$/{\1}/')
  if [[ ${?} -ne 0 ]]; then
    cli_error "Error, enumerating block devices failed - cannot continue."
    exit 1
  fi
  cli_info "Starting hddtemp as a dearmon for block devices: sd${sds}."
  sudo hddtemp -d /dev/sd${sds}
  if [[ ${?} -ne 0 ]]; then
    cli_error "Error, non-zero code encountered when starting hddtemp daemon."
  else
    cli_info "hddtemp daemon start for devices: sd${sds}."
  fi
}
```

Which can be used to start the daemon once the computer boots for all available block devices. 
Please be aware that it does not do any error checking to see if the block device is supported by `hddtemp` itself - I assume it does!