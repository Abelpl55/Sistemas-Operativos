# Leccion 08: Gestion de Archivos y Directorios

## Objetivos

- Dominar las pruebas de archivos en scripts
- Usar `find` para buscar archivos con criterios avanzados
- Gestionar permisos y propiedad de archivos
- Crear estructuras de directorios para proyectos
- Obtener informacion sobre archivos (tamano, fecha, tipo)

---

## 8.1 Pruebas de Archivos en Scripts

Las pruebas de archivos son fundamentales para escribir scripts robustos.

### Operadores de prueba

```bash
# Verificar si existe un archivo
if [ -f "config.conf" ]; then
    echo "Archivo encontrado"
fi

# Verificar si existe un directorio
if [ -d "backups" ]; then
    echo "Directorio encontrado"
fi

# Verificar si NO existe (negacion con !)
if [ ! -d "backups" ]; then
    echo "Creando directorio backups..."
    mkdir -p backups
fi
```

### Tabla completa de operadores de archivo

| Operador | Verdadero si... |
|----------|----------------|
| `-f archivo` | Es un archivo regular |
| `-d directorio` | Es un directorio |
| `-e path` | Existe (cualquier tipo) |
| `-s archivo` | Existe y tiene tamano > 0 |
| `-r archivo` | Tiene permiso de lectura |
| `-w archivo` | Tiene permiso de escritura |
| `-x archivo` | Tiene permiso de ejecucion |
| `-L enlace` | Es un enlace simbolico |
| `! -f archivo` | NO es un archivo (o no existe) |

### Patron del proyecto: validacion de prerequisitos

```bash
#!/usr/bin/env bash

# Funcion para exigir que un archivo exista
require_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: archivo requerido no encontrado: $file"
        exit 1
    fi
}

# Funcion para exigir que un directorio exista
require_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: directorio requerido no encontrado: $dir"
        exit 1
    fi
}

# Uso: el script termina si algo falta
require_file "./config.conf"
require_file "./logs/access.log"
require_dir "./sitio_web"

echo "Todos los prerequisitos estan presentes"
```

## 8.2 Crear Estructuras de Directorios

### mkdir -p: crear con padres

```bash
# Crear un solo directorio
$ mkdir backups

# Crear directorios anidados (con -p crea intermedios)
$ mkdir -p proyecto/scripts/lib
$ mkdir -p proyecto/logs proyecto/reportes proyecto/evidencia

# Crear toda la estructura del proyecto de una vez
$ mkdir -p backups reportes evidencia
```

### El patron ensure_dir

```bash
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Uso
ensure_dir "$BACKUP_DIR"
ensure_dir "$REPORT_DIR"
ensure_dir "$EVIDENCE_DIR"
```

`mkdir -p` no da error si el directorio ya existe, pero `ensure_dir` es mas
explicito en su intencion y puede extenderse con logging.

## 8.3 Informacion sobre Archivos

### du - Uso de disco

```bash
# Tamano de un archivo (legible)
$ du -h backup.tar.gz
4.2K    backup.tar.gz

# Solo el tamano (sin nombre)
$ du -h backup.tar.gz | cut -f1
4.2K

# Tamano total de un directorio
$ du -sh backups/
16K     backups/

# Tamano de cada archivo en un directorio
$ du -h backups/*
4.2K    backups/backup_2026-05-14_10-00-00.tar.gz
4.2K    backups/backup_2026-05-14_11-00-00.tar.gz
4.2K    backups/backup_2026-05-14_12-00-00.tar.gz
```

### ls -lh: detalles de archivos

```bash
$ ls -lh backups/
total 16K
-rw-r--r-- 1 alumno alumno 4.2K may 14 10:00 backup_2026-05-14_10-00-00.tar.gz
-rw-r--r-- 1 alumno alumno 4.2K may 14 11:00 backup_2026-05-14_11-00-00.tar.gz
-rw-r--r-- 1 alumno alumno 4.2K may 14 12:00 backup_2026-05-14_12-00-00.tar.gz
```

### stat: informacion detallada

```bash
$ stat archivo.txt
  File: archivo.txt
  Size: 1234       Blocks: 8     IO Block: 4096   regular file
  Access: 2026-05-14 10:30:00
  Modify: 2026-05-14 10:25:00
  Change: 2026-05-14 10:25:00
```

### file: tipo de archivo

```bash
$ file backup.tar.gz
backup.tar.gz: gzip compressed data

$ file script.sh
script.sh: Bash script, ASCII text executable

$ file imagen.png
imagen.png: PNG image data, 800 x 600, 8-bit/color RGBA
```

## 8.4 Listar Archivos con Criterios

### ls con opciones de ordenamiento

```bash
# Ordenar por fecha de modificacion (mas nuevo primero)
$ ls -1t backups/*.tar.gz
backups/backup_2026-05-14_12-00-00.tar.gz
backups/backup_2026-05-14_11-00-00.tar.gz
backups/backup_2026-05-14_10-00-00.tar.gz

# Ordenar por tamano (mas grande primero)
$ ls -1S backups/

# Reverso (mas viejo/pequeno primero)
$ ls -1tr backups/
```

### find: busqueda avanzada

```bash
# Buscar archivos .sh en el directorio actual y subdirectorios
$ find . -name "*.sh"

# Buscar solo en el nivel actual (sin recursion)
$ find . -maxdepth 1 -name "*.sh"

# Buscar hasta 2 niveles de profundidad
$ find . -maxdepth 2 -type d | sort

# Buscar archivos modificados en los ultimos 7 dias
$ find . -mtime -7 -type f

# Buscar archivos mayores a 1MB
$ find . -size +1M -type f

# Buscar y ejecutar un comando en cada resultado
$ find scripts/ -name "*.sh" -exec chmod +x {} \;
```

### Ejemplo: documentar la estructura del proyecto

```bash
# Mostrar arbol de directorios (hasta 2 niveles)
$ find . -maxdepth 2 -type d | sort
.
./backups
./datos_empresa
./datos_empresa/finanzas
./datos_empresa/operacion
./datos_empresa/rh
./evidencia
./logs
./reportes
./scripts
./sitio_web
./sitio_web/admin
./sitio_web/assets
./sitio_web/uploads
```

## 8.5 Operaciones Masivas

### Dar permisos a todos los scripts

```bash
$ chmod +x scripts/*.sh
```

### Listar y contar archivos por tipo

```bash
# Contar archivos .tar.gz en backups
$ ls -1 backups/*.tar.gz 2>/dev/null | wc -l

# Contar todos los scripts
$ find scripts/ -name "*.sh" | wc -l
```

### Copiar y mover con patrones

```bash
# Copiar todos los logs a un respaldo
$ cp logs/*.log respaldo_logs/

# Mover archivos viejos
$ mv backups/backup_2026-01-*.tar.gz archivo_viejo/
```

## 8.6 Rotacion de Archivos (Patron del Proyecto)

La rotacion consiste en mantener solo los N archivos mas recientes y eliminar el resto:

```bash
#!/usr/bin/env bash
# rotar_backups.sh - Mantener solo los ultimos MAX_BACKUPS

MAX_BACKUPS=5
BACKUP_DIR="./backups"

# Listar backups ordenados por fecha (mas nuevo primero)
LISTA=$(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null || true)

# Contar total
TOTAL=$(echo "$LISTA" | grep -c "." || true)

echo "Backups encontrados: $TOTAL"
echo "Maximo permitido: $MAX_BACKUPS"

if [ "$TOTAL" -gt "$MAX_BACKUPS" ]; then
    # Obtener los archivos que exceden el limite
    EXCEDENTES=$(echo "$LISTA" | tail -n +$((MAX_BACKUPS + 1)))

    echo "Eliminando $((TOTAL - MAX_BACKUPS)) backups antiguos:"

    # Eliminar cada archivo excedente
    echo "$EXCEDENTES" | while read -r backup_viejo; do
        echo "  Eliminando: $backup_viejo"
        rm -f "$backup_viejo"
    done
else
    echo "No hay backups que eliminar"
fi
```

### Desglose de la logica

```
Antes (8 backups, MAX=5):
  backup_08.tar.gz  (mas nuevo)  <- CONSERVAR
  backup_07.tar.gz               <- CONSERVAR
  backup_06.tar.gz               <- CONSERVAR
  backup_05.tar.gz               <- CONSERVAR
  backup_04.tar.gz               <- CONSERVAR
  ─────────────────── linea de corte (tail -n +6)
  backup_03.tar.gz               <- ELIMINAR
  backup_02.tar.gz               <- ELIMINAR
  backup_01.tar.gz  (mas viejo)  <- ELIMINAR

Despues (5 backups):
  backup_08.tar.gz
  backup_07.tar.gz
  backup_06.tar.gz
  backup_05.tar.gz
  backup_04.tar.gz
```

## 8.7 Verificar Existencia de Archivos de Evidencia

Un patron util para verificar que todo el proyecto esta completo:

```bash
#!/usr/bin/env bash
# Verificar archivos generados

archivos=(
    "evidencia/setup_estructura.txt"
    "evidencia/backup_ejecucion.txt"
    "evidencia/rotacion.txt"
    "reportes/reporte_access.txt"
    "reportes/reporte_error.txt"
    "reportes/reporte_final.md"
)

echo "=== Verificacion de archivos ==="
for archivo in "${archivos[@]}"; do
    if [ -f "$archivo" ]; then
        echo "[OK]    $archivo"
    else
        echo "[FALTA] $archivo"
    fi
done
```

---

## Ejercicios

### [PRACTICA 8.1] Estructura de proyecto
Crea la siguiente estructura usando solo comandos:
```
mi_proyecto/
├── src/
│   ├── main.sh
│   └── lib/
│       └── utils.sh
├── data/
│   ├── input/
│   └── output/
├── logs/
├── config.conf
└── README.md
```

### [PRACTICA 8.2] Script de verificacion
Escribe `verificar_proyecto.sh` que reciba un directorio como argumento y verifique:
- Que existen las subcarpetas necesarias
- Que los scripts tienen permiso de ejecucion
- Muestre un resumen con [OK] o [FALTA] para cada elemento

### [PRACTICA 8.3] Rotacion de logs
Crea un script que:
1. Genere 10 archivos de log simulados (log_01.txt a log_10.txt)
2. Mantenga solo los 5 mas recientes
3. Muestre cuales conservo y cuales elimino

### [PRACTICA 8.4] Inventario de archivos
Crea un script que reciba un directorio y genere un reporte con:
- Total de archivos y directorios
- Total de archivos por extension (.txt, .sh, .log, etc.)
- Tamano total del directorio
- Archivo mas grande y mas pequeno

---

## Resumen

| Operacion | Comando | Ejemplo |
|----------|---------|---------|
| Verificar archivo | `[ -f file ]` | `if [ -f "config.conf" ]; then` |
| Verificar directorio | `[ -d dir ]` | `if [ ! -d "backups" ]; then` |
| Crear directorio | `mkdir -p` | `mkdir -p backups reportes` |
| Tamano de archivo | `du -h` | `du -h backup.tar.gz` &#124; `cut -f1` |
| Listar por fecha | `ls -1t` | `ls -1t backups/*.tar.gz` |
| Buscar archivos | `find` | `find . -name "*.sh" -type f` |
| Tipo de archivo | `file` | `file backup.tar.gz` |
| Detalles de archivo | `stat` | `stat archivo.txt` |
| Contar archivos | `ls` &#124; `wc -l` | `ls backups/*.tar.gz` &#124; `wc -l` |

**Siguiente leccion**: [09 - Archivos Comprimidos y Backups](09_Archivos_Comprimidos_Backups.md)
