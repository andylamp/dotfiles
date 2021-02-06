![linters](https://github.com/andylamp/dotfiles/workflows/Shell%20Lint/badge.svg)

# (Somewhat) Portable dotfiles

This is a collection of scripts, notes, and tricks that I use to be mobile on Unix-like distributions. My day-to-day
work mostly revolves `Debian` based distributions (mostly `Ubuntu`) and `MacOS`, thus most of my `dotfiles` are catered
to this kind of distributions.

The change from `bash` from `ksh` in `MacOS` made things a bit patchy but I'll try to upload my `MacOS` `dotfile` once
it is peachy again.

Also, currently the `dotfile` script requires `git` to be already installed, but that should be fixed in future
revisions.

## Installing

To install the `dotscript` the only thing you need to run is [`bootstrap.sh`](bootstrap.sh) located in the top directory
which initiates the entire process. Server things happen, first we detect if the script is being run as `root` - this is
not supported and will return an error; if `sudo` actions are required then the script will prompt for it. It has to be
noted that you *need* to have `sudo` access in order to run the script. Secondly, we detect the kind and type of
operating system we are currently running and spawn the respective `dotscript` for that operating system.

Currently, the only fleshed-out `dotscript` is for [`Ubuntu`](ubuntu-distro/dot_script_ubuntu.sh) but I plan to
add [`MacOS`](macos/dot_script_macos.sh) fairly soon as well as [`Debian`](debian-distro/dot_script_debian.sh).

## What it does

It configures the following things:

- `ssh`: pub/private keys.
- [`kitty`](https://github.com/kovidgoyal/kitty) (terminal emulator): along with my conf.
- `homebrew`: install a decent package manager (only used in `MacOS`).
- `bash`: along with my conf.
- `ufw`: basically copies (my) common used rules to the rule application directory.
- `git`: commit `user` and `email`.
- `rust`: installs `nightly`.
- `rvm`: installs `rvm` and also the latest stable `ruby` for the system.

Some of these bits cannot be public and thus they reside in an encrypted archive which is fetched during execution.
Optionally, if the files are already present then this can be left empty but if the required variables are not set (as
explained later on), then the script will fail.

## Configuration

Before executing your *need* to set the parameters in [`config.sh`](notes/xrdp.md) - mainly the following

-`CFG_MINIMAL`: sets if we are going to install extra bits (currently: `rvm`, `rust`, `pipenv3`). -`CFG_IMP_URL`: sets
the url for the remote file that contains the private bits. -`CFG_IMP_DIR`: sets where the "important" directory is
(i.e. - where the extracted private bits are). -`CFG_IMP_CONF`: sets where the optional configuration is.

The parameters that are contained in the extracted (encrypted) file are explained below.

-`ssh` pub/private keys -`bash` config -optional `dotscript` configuration.

This optional configuration has to contain the following parameters:

- `CFG_EMAIL`: the email to use.
- `CFG_GIT_USER`: the `git` `username`.
- `CFG_GIT_EMAIL`: the `git` mail which normally is set to: `${CFG_EMAIL}`.
- `CFG_KITTY_THEME`: my `kitty` terminal theme, normally set to `Afterglow`.
- `CFG_KITTY_CONF`: my `kitty` terminal configuration location, normally set to: `${DOT_DIR}/shared/my_kitty.conf`
- `CFG_BASH_CONF`: my `shell` (`bash`) configuration, normally set to: `${DOT_DIR}/shared/important/my_bash.sh`
- `CFG_SSH_PUB`: my `ssh` public key location, normally set to: `${DOT_DIR}/shared/important/id_pub`
- `CFG_SSH_PRI`: my `ssh` private key location, normally set to: `${DOT_DIR}/shared/important/id_rsa`

Where `${DOT_DIR}` is the current `dotscript` path, as defined in [`bootstrap.sh`](bootstrap.sh). It has to be noted
that if any of the above variables are *not* set - the script will fail.

### ssh

Puts my public/private keys in place and sets the correct permissions in the `~/.ssh` directory.

### kitty

Installs the `kitty` terminal emulator if not present and copies my configuration along with my (preferred) theme

- `Afterglow`. My `kitty` can be public and located in [`my_kitty.conf`](shared/my_kitty.conf) if someone wants to check
  it out. **Note**: `kitty` is not installed in `MacOS`, as I am happy with vanilla terminal.

### bash

Installs my aliases and configures bash to load my personal configuration using a special `tag` trick, that allows me to
update only one file, if needed without touching `profle`. The method to do so is located
in [`bash_config.sh`](shared/bash_config.sh) but my actual `bash` config cannot be public at this time.

### ufw

Copies the `ufw` rules that I normally use - they are not many but I do not want to type them all the time.

### git

This is nothing really special, it sets up my commit `username` and `email`.

### rust

Installs `rust`-lang in its nightly mode since it is all the craze lately; although I dot use it much apart from toy
projects.

### rvm

Installs `rvm` ruby manager along with the latest stable `ruby` for my system.

## Notes

There are some interesting notes which I could not fit in automated scripts yet - at least without considerable effort.
These are the following (in alphabetical order):

- [`glances`](notes/glances.md): configuration for a very good monitoring program.
- [`gpg`](notes/gpg.md): notes on how to use `gpg` to encrypt/decrypt files - esp. multiple files or folders.
- [`samba`](notes/samba.md): share files to both `Unix` and `Windows`.
- [`unifi`](notes/unifi.md): Ubiquiti equipment management suite (for Ubiquiti switches, access points, cameras, and
  more).
- [`ufw`](notes/ufw.md): uncomplicated firewall configuration notes (apply rules, to/from restrictions).
- [`xrdp`](notes/xrdp.md): notes on how to install and use `xrdp` for remote access using the `rdp` protocol.
- [`sshd`](notes/sshd.md): notes on how to allow `sshd` on systems that use `ufw`.

## Utilities

Here I outline some utilities provided with the `dotfile` scripts in order to make your life easier.

### Pack files

This helper script is used to pack the private bits into a single (encrypted) archive using `gpg` - this utility can be
found [here](utils/pack.sh). The script expects either the directory to be given as an input - please ensure it is a *
absolute* path - like so:

```bash
./pack /path/to/my/important/dir
```

or assumes that the important bits will be located in `${SCRIPT_DIR}/../shared/important`; where `${SCRIPT_DIR}` is the
directory that the script is executed from. In which case it can be executed like so:

```bash
./pack
```

### Upload packed file to remote

The upload the remote script helps upload the packed archive in a distribution server that you have access and `sudo`
rights. It does so by using `scp` to copy the folder and then `sudo` to move it into a remote location where a
web-server (i.e.: `apache`, `nginx`) will serve it. You can run the [`upload_to_server.sh`](utils/upload_to_server.sh)
as is shown below.

```bash
./upload_to_server file.gpg url user
```

## License

These scripts are released under the terms and conditions of the MIT license.
