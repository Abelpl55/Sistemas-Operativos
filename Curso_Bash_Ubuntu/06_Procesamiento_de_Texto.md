# Leccion 06: Procesamiento de Texto

## Objetivos

- Dominar `grep` para buscar patrones en archivos
- Usar `awk` para extraer columnas y campos de datos
- Aplicar `sed` para sustituir texto
- Combinar `sort`, `uniq`, `cut`, `wc` y `head`/`tail` para analizar datos

---

## 6.1 grep - Buscar Patrones

`grep` busca lineas que coincidan con un patron dentro de archivos.

### Uso basico

```bash
# Buscar texto exacto
$ grep "error" archivo.log

# Buscar ignorando mayusculas (-i)
$ grep -i "error" archivo.log

# Contar coincidencias (-c)
$ grep -c "error" archivo.log
42

# Mostrar numero de linea (-n)
$ grep -n "error" archivo.log
15: [error] algo salio mal
23: [error] conexion rechazada

# Mostrar solo la parte que coincide (-o)
$ grep -o "client: [0-9.]*" error.log
client: 192.168.1.15
client: 203.0.113.45
```

### Opciones importantes de grep

| Opcion | Significado | Ejemplo                        |
|--------|-------------|--------------------------------|
| `-i` | Ignorar mayusculas | `grep -i "error" log`          |
| `-c` | Contar coincidencias | `grep -c "404" access.log`     |
| `-n` | Mostrar numero de linea | `grep -n "error" log`          |
| `-o` | Solo mostrar lo que coincide | `grep -o "IP: [0-9.]*" log`    |
| `-v` | Invertir (lineas que NO coinciden) | `grep -v "200" access.log`     |
| `-r` | Buscar recursivamente en directorios | `grep -r "TODO" scripts/`      |
| `-l` | Solo nombres de archivos que coinciden | `grep -rl "error" logs/`       |
| `-E` | Expresiones regulares extendidas | `grep -E "error\|warning" log` |
| `-w` | Coincidencia de palabra completa | `grep -w "error" log`          |

### grep con multiples patrones (-E)

```bash
# Buscar lineas con "error" O "warning" O "critical"
$ grep -iE 'error|warning|critical' archivo.log

# Buscar herramientas de ataque en logs
$ grep -iE 'sqlmap|Nikto|curl/|masscan|python-requests' access.log

# Buscar intentos de inyeccion SQL
$ grep -iE 'UNION|SELECT|OR%201=1|%27|--' access.log

# Buscar intentos de path traversal
$ grep -iE '\.\./|%2e%2e|/etc/passwd' access.log
```

### grep con || true (evitar errores)

Cuando usas `set -e` (el script termina si un comando falla), `grep` puede causar
problemas porque retorna codigo 1 si no encuentra nada:

```bash
set -euo pipefail

# PROBLEMA: si no hay coincidencias, grep retorna 1 y el script termina
RESULTADO=$(grep "patron_raro" archivo.log)     # Script muere aqui

# SOLUCION: agregar || true para ignorar el error
RESULTADO=$(grep "patron_raro" archivo.log || true)  # Script continua
```

## 6.2 awk - Extraer Campos

`awk` procesa texto campo por campo (separados por espacios o tabs).

### Campos en awk

```
campo1   campo2   campo3   campo4
$1       $2       $3       $4
```

`$0` representa la linea completa.

### Uso basico

```bash
# Extraer el primer campo (columna)
$ echo "Juan 22 Ingenieria" | awk '{print $1}'
Juan

# Extraer multiples campos
$ echo "Juan 22 Ingenieria" | awk '{print $1, $3}'
Juan Ingenieria

# Extraer de un archivo
$ awk '{print $1}' access.log    # IPs (primer campo del log)
$ awk '{print $9}' access.log    # Codigos HTTP (campo 9)
```

### awk con separador personalizado

```bash
# Archivo CSV (separador: coma)
$ echo "nombre,edad,carrera" | awk -F',' '{print $2}'
edad

# Archivo con dos puntos (como /etc/passwd)
$ awk -F':' '{print $1}' /etc/passwd    # Nombres de usuario
```

### Ejemplo del proyecto: Top IPs

```bash
# Pipeline completo: extraer IPs, contar y ordenar
$ awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10
    132 192.168.1.15
     98 10.0.0.25
     87 172.16.0.100
    ...
```

Desglose del pipeline:
1. `awk '{print $1}'` - Extrae la IP (campo 1)
2. `sort` - Ordena alfabeticamente (necesario para uniq)
3. `uniq -c` - Cuenta ocurrencias consecutivas
4. `sort -nr` - Ordena por numero, descendente
5. `head -10` - Muestra solo los 10 primeros

## 6.3 sed - Sustituir Texto

`sed` (Stream Editor) modifica texto sobre la marcha.

### Sustitucion basica

```bash
# Sustituir primera ocurrencia por linea
$ echo "hola mundo" | sed 's/mundo/amigo/'
hola amigo

# Sustituir TODAS las ocurrencias (flag g)
$ echo "error error error" | sed 's/error/ok/g'
ok ok ok

# Sustituir en un archivo (sin modificar el original)
$ sed 's/patron/reemplazo/' archivo.txt

# Sustituir en el archivo directamente (-i)
$ sed -i 's/patron/reemplazo/' archivo.txt
```

### Uso en el proyecto

```bash
# Extraer IPs de logs de error
$ grep -oE 'client: ([0-9.]+)' error.log | sed 's/client: //'
192.168.1.15
203.0.113.45
10.0.0.25
```

Desglose:
1. `grep -oE 'client: ([0-9.]+)'` - Extrae "client: IP"
2. `sed 's/client: //'` - Elimina el prefijo "client: ", dejando solo la IP

## 6.4 sort - Ordenar

```bash
# Orden alfabetico
$ sort archivo.txt

# Orden numerico
$ sort -n numeros.txt

# Orden numerico descendente (reverso)
$ sort -nr numeros.txt

# Ordenar por campo especifico (-k)
$ sort -t',' -k2 -n datos.csv    # Por campo 2, numerico, separador coma

# Ordenar archivos por fecha de modificacion
$ ls -1t directorio/             # ls ya ordena por tiempo con -t
```

### Ejemplo practico

```bash
# Distribucion de codigos HTTP, de mayor a menor
$ awk '{print $9}' access.log | sort | uniq -c | sort -nr
    899 200
    188 401
     86 404
     75 403
     42 301
     35 500
     29 503
```

## 6.5 uniq - Eliminar Duplicados

`uniq` elimina lineas duplicadas **consecutivas** (por eso siempre se usa con `sort`):

```bash
# Eliminar duplicados (requiere estar ordenado)
$ sort archivo.txt | uniq

# Contar ocurrencias de cada linea
$ sort archivo.txt | uniq -c
      5 linea_comun
      2 linea_rara
      1 linea_unica

# Mostrar solo lineas duplicadas
$ sort archivo.txt | uniq -d

# Mostrar solo lineas unicas (no repetidas)
$ sort archivo.txt | uniq -u
```

### El pipeline clasico: sort | uniq -c | sort -nr

Este es el patron mas usado para contar y ordenar frecuencias:

```bash
# Contar las 10 IPs mas frecuentes en un log
$ awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10

# Paso a paso:
# 1. awk '{print $1}'    -> extrae IPs
# 2. sort                -> ordena (necesario para uniq)
# 3. uniq -c             -> cuenta cada IP
# 4. sort -nr            -> ordena por conteo, descendente
# 5. head -10            -> top 10
```

## 6.6 cut - Extraer por Posicion

`cut` extrae partes de cada linea basandose en delimitadores o posiciones:

```bash
# Extraer por campo (delimitador tab por defecto)
$ cut -f1 archivo.tsv

# Extraer por campo con delimitador personalizado
$ cut -d',' -f2 datos.csv       # Segundo campo, separador coma
$ cut -d':' -f1 /etc/passwd     # Primer campo, separador dos puntos

# Extraer por posicion de caracteres
$ cut -c1-10 archivo.txt        # Primeros 10 caracteres de cada linea
```

### Ejemplo del proyecto

```bash
# Obtener tamano de un archivo
$ du -h backup.tar.gz | cut -f1
4.2K
```

`du -h` muestra: `4.2K    backup.tar.gz`
`cut -f1` extrae solo: `4.2K`

## 6.7 wc - Contar

```bash
# Contar lineas, palabras y bytes
$ wc archivo.txt
  150  890  6234 archivo.txt

# Solo lineas
$ wc -l archivo.txt
150 archivo.txt

# Solo lineas (sin nombre de archivo, usando redireccion)
$ wc -l < archivo.txt
150

# Solo palabras
$ wc -w archivo.txt

# Contar archivos en un directorio
$ ls directorio/ | wc -l
```

## 6.8 head y tail - Inicio y Final

```bash
# Primeras 10 lineas (default)
$ head archivo.txt

# Primeras N lineas
$ head -20 archivo.txt

# Ultimas 10 lineas (default)
$ tail archivo.txt

# Ultimas N lineas
$ tail -20 archivo.txt

# Desde la linea N en adelante
$ tail -n +5 archivo.txt     # Desde la linea 5 hasta el final

# Seguir en tiempo real (para logs)
$ tail -f /var/log/syslog    # Ctrl+C para salir
```

### Uso en rotacion de backups

```bash
# Listar backups (mas nuevo primero)
LISTA=$(ls -1t backups/*.tar.gz)

# Los que exceden el limite (para eliminar)
EXCEDENTES=$(echo "$LISTA" | tail -n +$((MAX_BACKUPS + 1)))
# tail -n +6 = desde la linea 6 en adelante (si MAX=5)
```

## 6.9 Pipelines Completos (Combinando Todo)

### Analisis de access.log

```bash
#!/usr/bin/env bash
# Ejemplo: analisis completo de un log de acceso web

LOG="access.log"

echo "=== ANALISIS DE $LOG ==="
echo ""

# 1. Total de lineas
echo "Total de peticiones: $(wc -l < "$LOG")"
echo ""

# 2. Top 10 IPs
echo "--- Top 10 IPs ---"
awk '{print $1}' "$LOG" | sort | uniq -c | sort -nr | head -10
echo ""

# 3. Distribucion de codigos HTTP
echo "--- Codigos HTTP ---"
awk '{print $9}' "$LOG" | sort | uniq -c | sort -nr
echo ""

# 4. Rutas sospechosas
echo "--- Accesos a rutas sensibles ---"
SENSIBLES=$(grep -iE '/\.env|phpmyadmin|wp-login|/admin' "$LOG" || true)
if [ -n "$SENSIBLES" ]; then
    echo "$SENSIBLES" | head -5
    echo "Total: $(echo "$SENSIBLES" | wc -l)"
else
    echo "Ninguno detectado"
fi
```

### Analisis de error.log

```bash
#!/usr/bin/env bash
LOG="error.log"

echo "=== ANALISIS DE ERRORES ==="

# Contar por tipo
echo "Access forbidden:  $(grep -c 'access forbidden' "$LOG" || true)"
echo "Permission denied: $(grep -c 'permission denied' "$LOG" || true)"
echo "File not found:    $(grep -cE 'No such file|open\(\) .* failed' "$LOG" || true)"
echo ""

# Top IPs en errores
echo "--- Top IPs en errores ---"
grep -oE 'client: ([0-9.]+)' "$LOG" | sed 's/client: //' | sort | uniq -c | sort -nr | head -10
```

---

## Ejercicios

### [PRACTICA 6.1] Analizar /etc/passwd
```bash
# 1. Cuantos usuarios hay?
$ wc -l < /etc/passwd

# 2. Lista solo nombres de usuario (campo 1, separador :)
$ cut -d':' -f1 /etc/passwd

# 3. Cuantos usan /bin/bash como shell?
$ grep -c '/bin/bash' /etc/passwd

# 4. Lista usuarios con su shell (campos 1 y 7)
$ awk -F':' '{print $1, $7}' /etc/passwd
```

### [PRACTICA 6.2] Crear datos de prueba y analizarlos
Crea un archivo `ventas.csv`:
```
producto,cantidad,precio
laptop,5,15000
mouse,20,350
teclado,15,800
monitor,8,5000
laptop,3,15000
mouse,10,350
```

Luego:
1. Muestra solo los productos (campo 1)
2. Cuenta cuantas veces aparece cada producto
3. Ordena por cantidad (campo 2)

### [PRACTICA 6.3] Pipeline de analisis
Crea un script que analice un archivo de texto y muestre:
- Total de lineas
- Total de palabras
- Las 5 palabras mas frecuentes
- Las lineas que contienen una palabra especifica (recibida como argumento)

### [PRACTICA 6.4] Mini analizador de log
Crea un log de prueba con formato:
```
192.168.1.1 - - [14/May/2026] "GET /index.html" 200
10.0.0.5 - - [14/May/2026] "GET /admin" 403
192.168.1.1 - - [14/May/2026] "POST /login" 401
```

Escribe un script que extraiga:
1. Las IPs unicas
2. La distribucion de codigos HTTP
3. Las rutas que devolvieron error (4xx, 5xx)

---

## Resumen

| Herramienta | Funcion | Ejemplo clave |
|------------|---------|---------------|
| `grep` | Buscar patrones | `grep -iE 'error\|warn' log` |
| `grep -c` | Contar coincidencias | `grep -c "404" log` |
| `grep -o` | Solo lo que coincide | `grep -oE 'IP: [0-9.]+'` |
| `awk` | Extraer campos | `awk '{print $1}' log` |
| `sed` | Sustituir texto | `sed 's/viejo/nuevo/'` |
| `sort` | Ordenar | `sort -nr` (numerico reverso) |
| `uniq -c` | Contar unicos | `sort` &#124; `uniq -c` |
| `cut` | Extraer por delimitador | `cut -d':' -f1` |
| `wc -l` | Contar lineas | `wc -l < archivo` |
| `head/tail` | Inicio/final | `head -10`, `tail -n +5` |

### El pipeline clasico

```
awk '{print $CAMPO}' | sort | uniq -c | sort -nr | head -N
```

**Siguiente leccion**: [07 - Pipes y Redireccion](07_Pipes_y_Redireccion.md)
