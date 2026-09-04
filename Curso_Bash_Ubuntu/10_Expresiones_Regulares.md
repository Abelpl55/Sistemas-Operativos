# Leccion 10: Expresiones Regulares

## Objetivos

- Entender la sintaxis de expresiones regulares (regex)
- Diferenciar regex basico (BRE) y extendido (ERE)
- Aplicar regex con `grep -E`, `awk` y `[[ =~ ]]`
- Construir patrones para detectar IPs, emails, ataques, etc.

---

## 10.1 Que son las Expresiones Regulares

Una expresion regular (regex) es un **patron** que describe un conjunto de cadenas
de texto. Se usan para buscar, validar y extraer datos.

Ejemplo: el patron `[0-9]+` significa "uno o mas digitos".

```bash
# Buscar lineas que contienen numeros
$ grep -E '[0-9]+' archivo.txt
```

## 10.2 Caracteres Basicos

### Literales y metacaracteres

| Caracter | Significado | Ejemplo | Coincide con |
|----------|-------------|---------|-------------|
| `.` | Cualquier caracter | `a.c` | abc, a1c, a-c |
| `*` | 0 o mas del anterior | `ab*c` | ac, abc, abbc |
| `+` | 1 o mas del anterior | `ab+c` | abc, abbc (no ac) |
| `?` | 0 o 1 del anterior | `ab?c` | ac, abc |
| `^` | Inicio de linea | `^Hola` | "Hola mundo" |
| `$` | Final de linea | `fin$` | "este es el fin" |
| `\` | Escape (literal) | `\.` | un punto literal |
| `\|` | OR (alternativa) | `gato\|perro` | "gato" o "perro" |

### Clases de caracteres

| Clase | Significado | Equivalente |
|-------|-------------|-------------|
| `[abc]` | a, b, o c | - |
| `[a-z]` | Cualquier minuscula | - |
| `[A-Z]` | Cualquier mayuscula | - |
| `[0-9]` | Cualquier digito | - |
| `[a-zA-Z]` | Cualquier letra | - |
| `[a-zA-Z0-9]` | Letra o digito | - |
| `[^abc]` | Cualquier cosa EXCEPTO a, b, c | - |

### Cuantificadores

| Cuantificador | Significado | Ejemplo |
|---------------|-------------|---------|
| `*` | 0 o mas | `a*` = "", "a", "aaa" |
| `+` | 1 o mas | `a+` = "a", "aaa" (no "") |
| `?` | 0 o 1 | `a?` = "", "a" |
| `{3}` | Exactamente 3 | `a{3}` = "aaa" |
| `{2,5}` | Entre 2 y 5 | `a{2,5}` = "aa" a "aaaaa" |
| `{2,}` | 2 o mas | `a{2,}` = "aa", "aaa", ... |

## 10.3 BRE vs ERE

Bash tiene dos dialectos de regex:

### BRE - Basic Regular Expressions (grep sin flags)

Los metacaracteres `+`, `?`, `{`, `}`, `(`, `)`, `|` necesitan escape con `\`:

```bash
$ grep 'ab\+c' archivo.txt       # + necesita escape
$ grep 'gato\|perro' archivo.txt  # | necesita escape
```

### ERE - Extended Regular Expressions (grep -E)

Los metacaracteres funcionan directamente:

```bash
$ grep -E 'ab+c' archivo.txt      # + funciona directo
$ grep -E 'gato|perro' archivo.txt # | funciona directo
```

**Recomendacion**: Siempre usa `grep -E` para evitar confusion con escapes.

## 10.4 Patrones Comunes para el Proyecto

### Patron: Direccion IP

```bash
# IP basica
[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+

# Uso con grep
$ grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log

# Extraer IPs de logs de error
$ grep -oE 'client: ([0-9.]+)' error.log
```

### Patron: Codigo HTTP

```bash
# Codigos de 3 digitos
[0-9]{3}

# Solo codigos de error (4xx y 5xx)
[45][0-9]{2}
```

### Patron: Herramientas de ataque

```bash
# Detectar scanners y herramientas de hacking
$ grep -iE 'sqlmap|Nikto|curl/|masscan|python-requests|Go-http-client' access.log
```

| Herramienta | Que es | Por que es sospechosa |
|-------------|--------|----------------------|
| `sqlmap` | Herramienta de SQL injection | Inyeccion automatica de SQL |
| `Nikto` | Scanner de vulnerabilidades web | Busca fallos conocidos |
| `curl/` | Cliente HTTP | Puede ser usado para scripting malicioso |
| `masscan` | Scanner de puertos rapido | Reconocimiento de red |
| `python-requests` | Libreria HTTP de Python | Bots y scripts de ataque |
| `Go-http-client` | Cliente HTTP de Go | Bots automatizados |

### Patron: Inyeccion SQL

```bash
$ grep -iE 'UNION|SELECT|OR%201=1|%27|--' access.log
```

| Patron | Significado | Ataque |
|--------|-------------|--------|
| `UNION` | Combinar consultas SQL | Union-based injection |
| `SELECT` | Consultar datos | Data extraction |
| `OR%201=1` | `OR 1=1` (URL encoded) | Bypass de autenticacion |
| `%27` | `'` (comilla simple URL encoded) | Escape de strings |
| `--` | Comentario SQL | Ignorar resto de query |

### Patron: Path Traversal

```bash
$ grep -iE '\.\./|%2e%2e|/etc/passwd' access.log
```

| Patron | Significado |
|--------|-------------|
| `../` | Navegar al directorio padre |
| `%2e%2e` | `..` URL encoded |
| `/etc/passwd` | Archivo clasico objetivo de LFI |

### Patron: Rutas sensibles

```bash
$ grep -iE '/\.env|phpmyadmin|wp-login\.php|xmlrpc\.php|server-status|/admin' access.log
```

## 10.5 Regex en Bash con [[ =~ ]]

Dentro de scripts puedes usar `[[ =~ ]]` para comparar con regex:

```bash
# Validar que una variable es un numero
if [[ "$MAX_BACKUPS" =~ ^[0-9]+$ ]]; then
    echo "$MAX_BACKUPS es un numero valido"
else
    echo "Error: no es un numero"
    exit 1
fi
```

### Desglose de `^[0-9]+$`

| Parte | Significado |
|-------|-------------|
| `^` | Inicio de la cadena |
| `[0-9]` | Un digito |
| `+` | Uno o mas |
| `$` | Final de la cadena |

La cadena completa debe ser solo digitos. "123" coincide, "12abc" no.

### Mas ejemplos de validacion

```bash
# Validar email (simplificado)
EMAIL="usuario@dominio.com"
if [[ "$EMAIL" =~ ^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+$ ]]; then
    echo "Email valido"
fi

# Validar formato de fecha YYYY-MM-DD
FECHA="2026-05-14"
if [[ "$FECHA" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
    echo "Formato de fecha correcto"
fi

# Validar nombre de archivo de backup
ARCHIVO="backup_sitio_web_2026-05-14_10-30-00.tar.gz"
if [[ "$ARCHIVO" =~ ^backup_.*\.tar\.gz$ ]]; then
    echo "Nombre de backup valido"
fi
```

## 10.6 Regex en grep -o (Extraer Coincidencias)

`grep -o` solo muestra la parte que coincide con el patron:

```bash
# Extraer todas las IPs de un log
$ grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' access.log
192.168.1.15
10.0.0.25
172.16.0.100

# Extraer codigos HTTP
$ grep -oE '" [0-9]{3} ' access.log | grep -oE '[0-9]{3}'
200
404
500
301

# Extraer URLs solicitadas
$ grep -oE '"(GET|POST) [^ ]+' access.log
"GET /index.html
"POST /login
"GET /admin
```

## 10.7 Tabla de Referencia Rapida

### Metacaracteres

```
.     Cualquier caracter
^     Inicio de linea
$     Final de linea
*     0 o mas repeticiones
+     1 o mas repeticiones (ERE)
?     0 o 1 repeticion (ERE)
|     Alternativa/OR (ERE)
()    Agrupacion (ERE)
[]    Clase de caracteres
[^]   Negacion de clase
\     Escape
```

### Clases POSIX

```
[:alpha:]   Letras         [[:alpha:]]
[:digit:]   Digitos        [[:digit:]]
[:alnum:]   Alfanumerico   [[:alnum:]]
[:space:]   Espacios       [[:space:]]
[:upper:]   Mayusculas     [[:upper:]]
[:lower:]   Minusculas     [[:lower:]]
```

---

## Ejercicios

### [PRACTICA 10.1] Patrones basicos
Usando grep -E, busca en un archivo de texto:
1. Lineas que empiezan con "Error"
2. Lineas que terminan con un numero
3. Lineas que contienen una IP
4. Lineas que contienen "warning" o "error" (sin importar mayusculas)

### [PRACTICA 10.2] Validacion de datos
Escribe un script que valide:
1. Que un argumento es un numero positivo: `^[0-9]+$`
2. Que un argumento tiene formato de IP: `^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$`
3. Que un argumento es un email basico

### [PRACTICA 10.3] Extraccion de datos
Dado el archivo access.log del proyecto:
1. Extrae todas las IPs unicas
2. Extrae todas las rutas que contienen "admin"
3. Cuenta los intentos de SQL injection
4. Cuenta los intentos de path traversal

### [PRACTICA 10.4] Construye patrones
Escribe el regex para cada caso:
1. Un numero telefonico: (55) 1234-5678
2. Un codigo postal mexicano: 5 digitos
3. Una fecha en formato DD/MM/YYYY
4. Una direccion MAC: AA:BB:CC:DD:EE:FF

---

## Resumen

| Necesidad | Patron (ERE) | Uso con grep |
|-----------|-------------|-------------|
| Numero | `^[0-9]+$` | `grep -E '^[0-9]+$'` |
| IP | `[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+` | `grep -oE` |
| SQL injection | `UNION` &#124; `SELECT` &#124; `OR%201=1` &#124; `%27` &#124; `--` | `grep -iE` |
| Path traversal | `\.\./` &#124; `%2e%2e` &#124; `/etc/passwd` | `grep -iE` |
| Rutas sensibles | `/\.env` &#124; `phpmyadmin` &#124; `wp-login` | `grep -iE` |
| User agents | `sqlmap` &#124; `Nikto` &#124; `masscan` | `grep -iE` |

**Siguiente leccion**: [11 - Analisis de Logs](11_Analisis_de_Logs.md)
