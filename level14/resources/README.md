# Level14
There are no useful looking files in our home directory this time around. Suppose that means it's time to dive straight into the `getflag` executable with gdb!

Over 1000 bytes worth of instructions... let's grab the executable and decompile it on dogbolt with Ghidra and Hex-Rays instead to have something a little more readable.

```c
fwrite("Check flag.Here is your token : ", 1u, 0x20u, stdout);
      v4 = getuid();
      if ( v4 == 3006 )
      {
        v15 = stdout;
        v16 = ft_des("H8B8h_20B4J43><8>\\ED<;j@3");
        fputs(v16, v15);
        goto LABEL_49;
      }
```

In this snippet, we see an example of `getflag` that prepares to print out the flag for each level.

We see many calls to the `ft_des` function throughout the `main`, with what seems to be a hash as the argument for each call.

We then tried to jump directly to the part that shows the flag and skip the comparison, exactly as we did in `level13`.

```asm
   0x08048be6 <+672>:   mov    %eax,(%esp)
   0x08048be9 <+675>:   call   0x80484c0 <fwrite@plt>
   0x08048bee <+680>:   jmp    0x8048e2f <main+1257>
   0x08048bf3 <+685>:   mov    0x804b060,%eax
   0x08048bf8 <+690>:   mov    %eax,%ebx
   0x08048bfa <+692>:   movl   $0x80490b2,(%esp)
   0x08048c01 <+699>:   call   0x8048604 <ft_des>
   0x08048c06 <+704>:   mov    %ebx,0x4(%esp)
   0x08048c0a <+708>:   mov    %eax,(%esp)
   0x08048c0d <+711>:   call   0x8048530 <fputs@plt>
   0x08048c12 <+716>:   jmp    0x8048e2f <main+1257>
   0x08048c17 <+721>:   mov    0x804b060,%eax
   0x08048c1c <+726>:   mov    %eax,%ebx
   0x08048c1e <+728>:   movl   $0x80490cc,(%esp)
   0x08048c25 <+735>:   call   0x8048604 <ft_des>
```

In this snippet, we can see the beginning of the repetitive logic for calling `ft_des` for each flag. At `*main+680` we see the jump to the end of the function to exit the program. Let's try jumping manually to the instruction directly after this instead, just ahead of the `ft_des` call.

```
gdb getflag
b main
r
jump *main+685
```
We see the output `x24ti5gi3x0ol2eh4esiuxias`. That's the flag for `level00`! Let's just find the final call to `ft_des` and we'll have the flag. Repeat the instructions before, replacing `*main+685` with `*main+1183` and there's the flag!

I bet you could make a script to get every flag for this whole project...