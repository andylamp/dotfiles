# GPG Notes

Handy notes if anyone has to deal with encryption/decryption using [`gnupg`][1].

# Encrypting files

## Encrypting a single file

If we want to encrypt a single file this is straightforward

```bash
# using symmetric (-c) - will output file.gpg and prompt for password
gpg -c file
# using symmetric (-c) - will output target.gpg and prompt for password
gpg -c file -o target.gpg
```

## Encrypting multiple files

However, at the time of this writing `gnupg` does not support encrypting multiple files using the `symmetric` (`-c`) option.
To alleviate this we can use some `tar` trickery as follows:

```bash
# first use tar to compress a directory then stream it to gpg which encrypts it
tar -cjv -C <directory> . | gpg -co outfile.gpg
``` 

# Decrypting files

Similarly to encrypting them - we have two cases, a single file or multiple.

## Decrypting a single file 
 
If we have encrypted a single file we can do the following:

```bash
# decrypt a file that was encrypted with (-c)
gpg -d file.gpg
```

## Decrypting multiple files

Again in the case of multiple files since `gpg` does not allow encrypting multiple files directly it is assumed, as above, that `tar` would be used. 
Hence, after decrypting we pipe the result to tar in order to be properly extracted as is shown below.

```bash
gpg -d outfile.gpg | tar -jx
```

## Force Forget cached passwords

We can force forget cached passwords by reloading the gpg agent - this can be done as follows:

```bash
echo RELOADAGENT | gpg-connect-agent
```

[1]: https://gnupg.org/