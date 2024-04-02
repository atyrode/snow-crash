Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2001(level01) gid=2001(level01) groups=2001(level01),100(users)
/home/user/level01
total 12
dr-x------ 1 level01 level01  100 Mar  5  2016 .
d--x--x--x 1 root    users    340 Aug 30  2015 ..
-r-x------ 1 level01 level01  220 Apr  3  2012 .bash_logout
-r-x------ 1 level01 level01 3518 Aug 30  2015 .bashrc
-r-x------ 1 level01 level01  675 Apr  3  2012 .profile
```

Comme pour le level00, je regarde dans les fichiers :

```
$ find / -user level01 2>/dev/null && find / -user flag01 2>/dev/null
/proc/2642
/proc/2642/task
/proc/2642/task/2642
/proc/2642/task/2642/attr
...
```

J'ai regardé un peu ces fichiers, mais ça semble être de la pollution volontaire, je ne m'attarde pas sur cette piste.

Je regarde du côté de /etc/passwd:

```
$ cat /etc/passwd | grep flag01
flag01:42hDRfypTqqnw:3001:3001::/home/flag/flag01:/bin/bash
	   ^^^^^^^^^^^^^
	   cela ressemble à un mot de passe
```

Je l'essaye:

```
$ su flag01
Password: 42hDRfypTqqnw
su: Authentication failure
```

Comme pour le level 0, je tente de l'inverser, je l'essaye, puis de faire une rotation et je regarde si je semble obtenir un mot de passe "human-readable".

Sans succès, je me renseigne sur la présence d'un mot de passe dans /etc/passwd (qui ne semble pas en être un en l'état)

[ChatGPT](https://chat.openai.com/share/e3f0fe4e-eb2e-4239-9db6-262b5e3143c7) me dit :

```
...it's important to clarify that while the file is named "passwd," it does not store passwords in a format that can be directly used for login purposes, especially not in modern systems.

-> In the past, `/etc/passwd` did include encrypted user passwords. 

However, due to security concerns, passwords were moved to a separate file, `/etc/shadow`, which is accessible only by the root user or processes with elevated privileges...
```

ChatGPT continue en m'expliquant les procédure à approcher pour tenter de le décrypter :

### 1. Identify the Hash Type

J'utilise [OnlineHashCrack](https://www.onlinehashcrack.com/hash-identification.php)  avec `42hDRfypTqqnw` :
```
Your hash may be one of the following:  
	- DES(Unix)  
	- Traditional DES  
	- DEScrypt
```

Et [TunnelsUp](https://www.tunnelsup.com/hash-analyzer/):

```
Hash: 42hDRfypTqqnw
Hash type: DES or 3DES?
```

Cela ne m'avance pas beaucoup, mais j'ai plus d'info sur le type du hash.

### 2. Use Password Cracking Tools

GPT me propose JohnTheRipper ou Hashcat.

Je remarque que le précédent niveau avait sa solution dans un dossier John. Je note donc qu'il semble que les hints se parsèment de niveaux en niveaux.

En local sur ma machine, j'installe JohnTheRipper:

```
$ apt-get update && apt-get install john -y
```

Je télécharge le fichier password (nécessaire pour JohnTheRipper) :

```
$ scp -P 4242 scp://level01@127.0.0.1/../../../etc/passwd .
```

J'execute John sur ce fichier (je suis dans WSL2) :

```
$ john /mnt/c/Users/alext/passwd --show

flag01:abcdefg:3001:3001::/home/flag/flag01:/bin/bash

1 password hash cracked, 0 left
```

Cela me semble plausible comme mot de passe. Je l'essaye :

```
$ su flag01
Password: abcdefg
Don't forget to launch getflag !

$ getflag
Check flag.Here is your token : f2av5il02puano7naaf6adaaf
```

### 3. Employ a Dictionary Attack or Brute-Force Attack

Pas eu besoin
### 4. Consider Rainbow Tables

Pas eu besoin
### 5. Practice Ethical Hacking 

Tqt GPT

