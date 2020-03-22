# ssh with ufw

To allow `ssh` from `ufw` we need to open the service port, normally `22`.
Now, assuming we have copied the `ufw` rule (one can be found [here][1]) for `ssh` in `/etc/ufw/applications.d/` we can enable it as such:

```bash
# allow ssh in ufw from specific domain (recommended)
sudo ufw allow from 192.168.178.0/24 to any app ssh
# allow ssh in ufw from any
sudo ufw allow ssh
```

To check that it has indeed been applied we can check using

```bash
# replace ssh-port with the port that ssh listens to, normally 22.
sudo ufw status verbose | grep <ssh-port>
# or by using 22 (this is for my own copy-paste).
sudo ufw status verbose | grep 22
```

[1]: ../shared/ufw-rules/ssh