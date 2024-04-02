Tout d'abord j'identifie où je me trouve :

```$ pwd
/home/user/level00
```

Puis ce que ce dossier contient :

```
$ ls -la
total 12
dr-xr-x---+ 1 level00 level00  100 Mar  5  2016 .
d--x--x--x  1 root    users    340 Aug 30  2015 ..
-r-xr-x---+ 1 level00 level00  220 Apr  3  2012 .bash_logout
-r-xr-x---+ 1 level00 level00 3518 Aug 30  2015 .bashrc
-r-xr-x---+ 1 level00 level00  675 Apr  3  2012 .profile
```

Je n'observe rien d'intéressant ici ou qui semble être le flag ici.

Nous cherchons le mot de passe du user **flag00**. Je tente d'aller voir ses fichiers :

```
$ find / -user flag00 2>/dev/null
/usr/sbin/john
/rofs/usr/sbin/john
```

Je pipe les retours d'erreur (2) dans /dev/null pour les filtrer.

Je cat les deux fichiers trouvés :

```
$ cat /rofs/usr/sbin/john
cdiiddwpgswtgt

$ cat /usr/sbin/john
cdiiddwpgswtgt
```

Je l'essaye comme mot de passe : 

```
$ su flag00
Password: cdiiddwpgswtgt
su: Authentication failure
```

Je le tente à l'envers :

```
$ echo "cdiiddwpgswtgt" | rev
tgtwsgpwddiidc

$ su flag00
Password: tgtwsgpwddiidc
su: Authentication failure
```

Je tente de shifter la string par rotation :

```python
source = "cdiiddwpgswtgt"

def rotate_character(c, n):
    return chr((ord(c) - ord('a') + n) % 26 + ord('a'))
    
for n in range(1, 26):
    print(''.join(rotate_character(c, n) for c in source))
```

J'obtiens :

```
dejjeexqhtxuhu
efkkffyriuyviv
fgllggzsjvzwjw
ghmmhhatkwaxkx
hinniibulxbyly
ijoojjcvmyczmz
jkppkkdwnzdana
klqqllexoaebob
lmrrmmfypbfcpc
mnssnngzqcgdqd
nottoohardhere <- human-readable
opuuppibseifsf
pqvvqqjctfjgtg
qrwwrrkdugkhuh
rsxxsslevhlivi
styyttmfwimjwj
tuzzuungxjnkxk
uvaavvohykolyl
vwbbwwpizlpmzm
wxccxxqjamqnan
xyddyyrkbnrobo
yzeezzslcospcp
zaffaatmdptqdq
abggbbunequrer
bchhccvofrvsfs
```

Je le tente comme mot de passe :

```
$ su flag00
Password: nottoohardhere
Don't forget to launch getflag !

$ getflag
Check flag.Here is your token : x24ti5gi3x0ol2eh4esiuxias
```