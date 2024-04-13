# Level13
In our home directory, we find a `level13` executable owned by `flag13`. Upon execution:
```
level13@SnowCrash:~$ ./level13
UID 2013 started us but we we expect 4242
```

The program is checking to see if our UID is 4242. In `gdb`, we see the comparison happens at `main+14` and then the jump happens at `main+19`. The jump instruction takes us to `main+63` if the UID check is successful. Let's just jump there manually...

```
gdb level13
b main
r
jump *main+63
```
```
Continuing at 0x80485cb.
your token is 2A31L79asukciNyi8uppkEuSx
```

Ezpz. `su level14`