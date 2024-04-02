Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2009(level09) gid=2009(level09) groups=2009(level09),100(users)
/home/user/level09
total 24
dr-x------ 1 level09 level09  140 Mar  5  2016 .
d--x--x--x 1 root    users    340 Aug 30  2015 ..
-r-x------ 1 level09 level09  220 Apr  3  2012 .bash_logout
-r-x------ 1 level09 level09 3518 Aug 30  2015 .bashrc
-rwsr-sr-x 1 flag09  level09 7640 Mar  5  2016 level09
-r-x------ 1 level09 level09  675 Apr  3  2012 .profile
----r--r-- 1 flag09  level09   26 Mar  5  2016 token
```

Comme pour le précédent level:

J'observe deux spécificités, `level09`, dont le `setuid` est `flag09`, et `token` avec comme propriétaire `flag09` également.

A l'accoutumé, je lis et tente d'exécuter les fichiers qui me sont proposés :

```
$ cat token
f4kmm6p|=�p�n��DB�Du{��
$ ./level09
You need to provied only one arg.
```

Evidemment, j'essaye : 

```
$ ./level09 token
tpmhr

$ ./level09 f4kmm6p|=�p�n��DB�Du{��
=�p�n��DB�Du{��: command not found

$ ./level09 "f4kmm6p|=�p�n��DB�Du{��"
f5mpq;v�E���|���~����[��`������
```

J'essaye de comprendre la logique avec `strings` :

```
$ strings ./level09
...
__libc_start_main
GLIBC_2.4
GLIBC_2.0
PTRh
UWVS
[^_]
You should not reverse this
LD_PRELOAD
Injection Linked lib detected exit..
/etc/ld.so.preload
/proc/self/maps
/proc/self/maps is unaccessible, probably a LD_PRELOAD attempt exit..
libc
You need to provied only one arg.
00000000 00:00 0
LD_PRELOAD detected through memory maps exit ..
;*2$"$
...
```

Mais ne trouve rien d'intéressant. Je tente avec `ltrace` :

```
$ ltrace ./level09
__libc_start_main(0x80487ce, 1, 0xbffff7f4, 0x8048aa0, 0x8048b10 <unfinished ...>
ptrace(0, 0, 1, 0, 0xb7e2fe38)                                            = -1
puts("You should not reverse this"You should not reverse this
)                                       = 28
+++ exited (status 1) +++
```

Et avec un argument :

```
$ ltrace ./level09 "f4kmm6p|=�p�n��DB�Du{��"
__libc_start_main(0x80487ce, 2, 0xbffff7c4, 0x8048aa0, 0x8048b10 <unfinished ...>
ptrace(0, 0, 1, 0, 0xb7e2fe38)                                            = -1
puts("You should not reverse this"You should not reverse this
)                                       = 28
+++ exited (status 1) +++
```

Donc pas spécialement de différence, et rien d'intéressant de notable ici.

Je note cependant plus haut qu'en essayant de passer le contenu du fichier `token`, le programme semble en modifier son contenu. Une sorte de shift?

```
$ ./level09 "f4kmm6p|=�p�n��DB�Du{��"
f5mpq;v�E���|���~����[��`������
```

Ici, `f` reste `f`, `4` devient `5`, `k` devient `m`, et `m` devient `p`.

Transposé sur la table ASCII, cela reviendrait à un shift de :

f -> f => 0
4 -> 5 => 1
k -> m => 2
m -> p => 3

Ce schéma me semble suffisant pour estimer probable que le shift soit d'ajuster par `1 * position du char dans la string`.

Pour mieux guérir que prévenir, je tente toutefois le résultat du shift du contenu du fichier `token` comme mot de passe :

```
$ su flag09
Password: f5mpq;v�E���|���~����[��`������
su: Authentication failure
```

Sans succès, je me re-penche donc sur le fichier `token` qui était présent dans le profil de l'utilisateur.

A nouveau, je tente son contenu comme mot de passe :

```
$ su flag09
Password: f4kmm6p|=�p�n��DB�Du{��
su: Authentication failure
```

J'imagine donc qu'il est question d'utiliser à la fois le binaire, et sa capacité d'encryptage, ainsi que la valeur contenu dans `token`. Or, la valeur encryptée contenu dans `token` ne fonctionne pas, ni une fois shiftée.

Dans la mesure où les deux éléments sont impliqués et qu'une transformation vers l'avant ne fonctionne pas. Je tente donc une transformation en arrière en appliquant la même logique que le binaire fournis, au travers d'une commande utilisant `python -c` :

```python
python -c "import sys; print ''.join(chr(ord(c) - i) for i, c in enumerate(sys.argv[1]))"
```

Ce qui correspond à exécuter le script Python 2.0 suivant :

Cette commande itère sur tout les caractère contenu dans le résultat de `$(cat token)` et itère dessus, puis, créé une string dont chaque caractère est 1 en dessous dans la table ASCII par rapport à leurs position.

J'exécute ce script :

```
$ python -c "import sys; print ''.join(chr(ord(c) - i) for i, c in enumerate(sys.argv[1]))" $(cat tok
en)
f3iji1ju5yuevaus41q1afiuq
```

Je tente ce résultat comme mot de passe :

```
$ su flag09
Password: f3iji1ju5yuevaus41q1afiuq
Don't forget to launch getflag !

$ getflag
Check flag.Here is your token : s5cAJpM8ev6XHw998pRWG728z
```


