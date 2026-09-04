# Leccion 07: Pipes y Redireccion

## Objetivos

- Entender stdin, stdout y stderr
- Dominar la redireccion de entrada y salida
- Usar pipes para encadenar comandos
- Aplicar `tee` para escribir a archivo y pantalla simultaneamente
- Agrupar salida de multiples comandos

---

## 7.1 Los Tres Flujos Estandar

Todo proceso en Linux tiene tres flujos de datos:

```
                +------------------+
  stdin (0) --> |     Proceso      | --> stdout (1)
                |   (tu script)    | --> stderr (2)
                +------------------+
```

| Flujo | Numero | Descripcion | Default |
|-------|--------|-------------|---------|
| **stdin** | 0 | Entrada estandar | Teclado |
| **stdout** | 1 | Salida estandar | Pantalla |
| **stderr** | 2 | Salida de errores | Pantalla |

```bash
# Ejemplo: ls produce stdout, pero si falla produce stderr
$ ls /home          # stdout: lista de archivos
$ ls /noexiste      # stderr: "No such file or directory"
```

## 7.2 Redireccion de Salida

### Escribir a archivo (sobrescribir)

```bash
# > redirige stdout a un archivo (sobrescribe si existe)
$ echo "Hola mundo" > salida.txt
$ ls /home > lista_home.txt
$ date > timestamp.txt
```

### Agregar a archivo (append)

```bash
# >> agrega al final del archivo (no sobrescribe)
$ echo "Linea 1" > log.txt      # Crea el archivo
$ echo "Linea 2" >> log.txt     # Agrega al final
$ echo "Linea 3" >> log.txt     # Agrega al final
$ cat log.txt
Linea 1
Linea 2
Linea 3
```

### Redirigir stderr

```bash
# 2> redirige errores a un archivo
$ ls /noexiste 2> errores.txt

# 2>> agrega errores al archivo
$ ls /noexiste 2>> errores.txt

# Descartar errores (enviar a /dev/null)
$ ls /noexiste 2>/dev/null
# No muestra nada, el error se descarta
```

### Combinar stdout y stderr

```bash
# Ambos al mismo archivo
$ comando > salida.txt 2>&1

# Forma moderna (Bash 4+)
$ comando &> salida.txt

# Descartar toda salida
$ comando > /dev/null 2>&1
```

### /dev/null - El agujero negro

`/dev/null` es un archivo especial que descarta todo lo que recibe:

```bash
# Silenciar un comando completamente
$ apt update > /dev/null 2>&1

# Uso comun: verificar si un patron existe sin mostrar las lineas
$ grep -q "patron" archivo.txt    # -q = quiet, solo retorna codigo
$ echo $?                          # 0 si encontro, 1 si no
```

## 7.3 Redireccion de Entrada

```bash
# < lee stdin desde un archivo en lugar del teclado
$ wc -l < archivo.txt
150

# Sin redireccion, wc muestra el nombre del archivo:
$ wc -l archivo.txt
150 archivo.txt

# Con redireccion, solo muestra el numero:
$ wc -l < archivo.txt
150
```

### Lectura de archivo en while

```bash
# Leer un archivo linea por linea
while read -r linea; do
    echo "Procesando: $linea"
done < archivo.txt
```

Esto es equivalente a `cat archivo.txt | while read -r linea`, pero mas eficiente
porque no lanza un proceso adicional.

## 7.4 Pipes (Tuberias)

El pipe `|` conecta la **salida** de un comando con la **entrada** del siguiente:

```bash
# Concepto:
comando1 | comando2 | comando3

# La salida de comando1 es la entrada de comando2
# La salida de comando2 es la entrada de comando3
```

### Ejemplos basicos

```bash
# Contar archivos en un directorio
$ ls | wc -l

# Buscar un proceso
$ ps aux | grep "firefox"

# Ver las primeras lineas de un comando largo
$ cat /etc/passwd | head -5

# Filtrar y contar
$ grep "error" log.txt | wc -l
```

### Pipeline del proyecto: Top IPs

```bash
$ awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10
```

Visualizado paso a paso:

```
access.log:
192.168.1.15 - - [14/May/2026] "GET / " 200 ...
10.0.0.25 - - [14/May/2026] "GET /login" 401 ...
192.168.1.15 - - [14/May/2026] "POST /api" 200 ...
10.0.0.25 - - [14/May/2026] "GET /admin" 403 ...
192.168.1.15 - - [14/May/2026] "GET /css" 200 ...

  awk '{print $1}'         sort              uniq -c
  ─────────────────  ─────────────────  ─────────────────
  192.168.1.15       10.0.0.25              2 10.0.0.25
  10.0.0.25          10.0.0.25              3 192.168.1.15
  192.168.1.15       192.168.1.15
  10.0.0.25          192.168.1.15
  192.168.1.15       192.168.1.15

  sort -nr            head -10
  ─────────────────  ─────────────────
      3 192.168.1.15      3 192.168.1.15
      2 10.0.0.25         2 10.0.0.25
```

## 7.5 tee - Escribir a Archivo y Pantalla

`tee` toma stdin y lo envia a **un archivo** Y a **stdout** al mismo tiempo:

```bash
# Guardar en archivo Y mostrar en pantalla
$ echo "Resultado importante" | tee resultado.txt
Resultado importante
# (tambien se guardo en resultado.txt)

# Agregar al archivo (append) en lugar de sobrescribir
$ echo "Otra linea" | tee -a resultado.txt
```

### tee en el proyecto

```bash
# log_line escribe al archivo Y muestra en pantalla
log_line() {
    local file="$1"
    local msg="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$file"
}
```

### Capturar salida completa de un bloque

```bash
# Agrupar multiples comandos y enviar todo a tee
{
    echo "=== Informacion del Sistema ==="
    echo "Fecha:    $(date)"
    echo "Usuario:  $(whoami)"
    echo "Host:     $(hostname)"
    echo ""
    echo "=== Estructura de Directorios ==="
    find . -maxdepth 2 -type d | sort
    echo ""
    echo "=== Scripts Disponibles ==="
    ls -la scripts/*.sh
} | tee evidencia/setup_estructura.txt
```

Las llaves `{ ... }` agrupan los comandos. La salida de **todos** se envia por pipe
a `tee`, que la escribe en el archivo Y la muestra en pantalla.

## 7.6 Redireccion con > (Crear Reportes)

Para generar archivos de reporte, puedes redirigir bloques completos:

```bash
# Crear un reporte redirigiendo la salida a un archivo
{
    echo "=== REPORTE DE ANALISIS ==="
    echo "Fecha: $(date)"
    echo ""
    echo "--- Seccion 1: Total de lineas ---"
    wc -l < access.log
    echo ""
    echo "--- Seccion 2: Top IPs ---"
    awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10
} > reportes/reporte_access.txt

echo "Reporte guardado en reportes/reporte_access.txt"
```

### Diferencia entre > y | tee

| Metodo | Archivo | Pantalla |
|--------|---------|----------|
| `> archivo` | Si | No |
| &#124; `tee archivo` | Si | Si |
| &#124; `tee -a archivo` | Si (append) | Si |

## 7.7 Encadenamiento de Comandos

Ademas de pipes, puedes encadenar comandos de otras formas:

```bash
# Secuencial: siempre ejecuta ambos
$ comando1 ; comando2

# AND: ejecuta comando2 solo si comando1 tuvo exito
$ comando1 && comando2

# OR: ejecuta comando2 solo si comando1 fallo
$ comando1 || comando2
```

### Ejemplo practico

```bash
# Crear directorio y entrar (solo si se creo bien)
$ mkdir -p backups && echo "Directorio listo"

# Buscar patron; si no existe, mostrar mensaje
$ grep -q "error" log.txt && echo "Hay errores" || echo "Sin errores"

# Patron comun: || true para evitar fallo con set -e
$ RESULTADO=$(grep "patron" archivo.txt || true)
```

## 7.8 Here Documents (Heredoc)

Un heredoc permite pasar multiples lineas como entrada:

```bash
# Crear un archivo con multiples lineas
cat > archivo.txt << 'EOF'
Linea 1
Linea 2
Linea 3
EOF

# Con variables expandidas (sin comillas en EOF)
cat > config.txt << EOF
usuario=$USER
fecha=$(date)
directorio=$PWD
EOF

# Sin expansion de variables (con comillas en 'EOF')
cat > ejemplo.txt << 'EOF'
Esto es literal: $USER no se expande
$(date) tampoco se ejecuta
EOF
```

## 7.9 Ejemplo Completo del Proyecto

Asi es como se combinan todos estos conceptos en un script real:

```bash
#!/usr/bin/env bash
set -euo pipefail
source ./scripts/lib.sh
load_config

# Validar prerequisitos
require_file "$ACCESS_LOG"
ensure_dir "$REPORT_DIR"

# Generar reporte (tanto a archivo como a pantalla)
{
    echo "========================================"
    echo "  ANALISIS DE LOG DE ACCESO"
    echo "  Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "========================================"
    echo ""

    # Seccion 1: Total
    echo "--- 1. Total de peticiones ---"
    echo "Total: $(wc -l < "$ACCESS_LOG") lineas"
    echo ""

    # Seccion 2: Top IPs
    echo "--- 2. Top 10 IPs ---"
    awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -10
    echo ""

    # Seccion 3: Codigos HTTP
    echo "--- 3. Codigos de estado HTTP ---"
    awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -nr
    echo ""

    # Seccion 4: Rutas sensibles
    echo "--- 4. Accesos a rutas sensibles ---"
    grep -iE '/\.env|phpmyadmin|wp-login|/admin' "$ACCESS_LOG" || echo "(ninguno)"
    echo ""
    echo "Total: $(grep -ciE '/\.env|phpmyadmin|wp-login|/admin' "$ACCESS_LOG" || true)"

} | tee "$REPORT_DIR/reporte_access.txt"

echo ""
echo "Reporte guardado en: $REPORT_DIR/reporte_access.txt"
```

---

## Ejercicios

### [PRACTICA 7.1] Redireccion basica
```bash
# 1. Guarda la fecha actual en un archivo
$ date > mi_fecha.txt

# 2. Agrega tu nombre de usuario al mismo archivo
$ whoami >> mi_fecha.txt

# 3. Muestra el contenido
$ cat mi_fecha.txt

# 4. Intenta listar un directorio inexistente, descarta el error
$ ls /noexiste 2>/dev/null
```

### [PRACTICA 7.2] Pipeline de analisis
Usando `/etc/passwd`:
```bash
# 1. Cuenta cuantos usuarios usan /bin/bash
$ grep '/bin/bash' /etc/passwd | wc -l

# 2. Lista solo los nombres de usuario que usan bash
$ grep '/bin/bash' /etc/passwd | cut -d':' -f1

# 3. Ordenalos alfabeticamente
$ grep '/bin/bash' /etc/passwd | cut -d':' -f1 | sort
```

### [PRACTICA 7.3] Generador de reporte
Crea un script `reporte_sistema.sh` que genere un reporte con:
- Fecha y hora
- Informacion del sistema (uname)
- Espacio en disco (df -h)
- Usuarios conectados (who)

El reporte debe guardarse en un archivo Y mostrarse en pantalla (usa tee).

### [PRACTICA 7.4] Pipeline complejo
Crea un archivo con 20 lineas de nombres y calificaciones:
```
Juan 85
Maria 92
Pedro 78
Ana 95
...
```
Escribe pipelines para:
1. Los 5 alumnos con mejor calificacion
2. El promedio de calificaciones (usa awk)
3. Los alumnos reprobados (calificacion < 70)

---

## Resumen

| Operador | Funcion | Ejemplo |
|----------|---------|---------|
| `>` | Redirigir stdout a archivo (sobrescribe) | `echo "hi" > file` |
| `>>` | Redirigir stdout a archivo (append) | `echo "hi" >> file` |
| `2>` | Redirigir stderr a archivo | `cmd 2> errors.txt` |
| `2>/dev/null` | Descartar errores | `cmd 2>/dev/null` |
| `&>` | Redirigir stdout + stderr | `cmd &> all.txt` |
| `<` | Redirigir archivo a stdin | `wc -l < file` |
| &#124; | Pipe: conectar stdout con stdin | `cmd1` &#124; `cmd2` |
| &#124; `tee file` | Escribir a archivo Y pantalla | `cmd` &#124; `tee out.txt` |
| &#124; `tee -a file` | Append a archivo Y pantalla | `cmd` &#124; `tee -a log` |
| `{ ... }` | Agrupar comandos | `{ cmd1; cmd2; }` |
| `&&` | Ejecutar si exito | `cmd1 && cmd2` |
| &#124;&#124; | Ejecutar si fallo | `cmd1` &#124;&#124; `cmd2` |

**Siguiente leccion**: [08 - Gestion de Archivos y Directorios](08_Gestion_Archivos_Directorios.md)
