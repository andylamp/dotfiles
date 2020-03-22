# sshd with ufw

To allow `sshd` from `ufw` we need to open the service port, normally `22`.
Now, assuming we have copied the `ufw` rule (one can be found [here][1]) for `sshd` in `/etc/ufw/applications.d/` we can enable it as such:

```bash
# allow sshd in ufw from specific domain (recommended)
sudo ufw allow from 192.168.178.0/24 to any app sshd
# allow sshd in ufw from any
sudo ufw allow sshd
```

To check that it has indeed been applied we can check using

```bash
# replace ssh/sshd-port with the port that sshd listens to, normally 22.
sudo ufw status verbose | grep <ssh/sshd-port>
# or by using 22 (this is for my own copy-paste).
sudo ufw status verbose | grep 22
```

[1]: ../shared/ufw-rules/sshd