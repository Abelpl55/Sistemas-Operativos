# Leccion 09: Archivos Comprimidos y Backups

## Objetivos

- Entender los formatos de compresion en Linux
- Dominar el comando `tar` para crear y extraer archivos
- Implementar una estrategia de respaldo automatizada
- Verificar la integridad de archivos comprimidos

---

## 9.1 Formatos de Compresion en Linux

| Formato | Extension | Comando | Caracteristica |
|---------|-----------|---------|----------------|
| gzip | `.gz` | `gzip/gunzip` | Rapido, buena compresion |
| bzip2 | `.bz2` | `bzip2/bunzip2` | Mejor compresion, mas lento |
| xz | `.xz` | `xz/unxz` | Mejor compresion disponible |
| zip | `.zip` | `zip/unzip` | Compatible con Windows |
| **tar.gz** | `.tar.gz` | `tar -czf` | **El mas usado en Linux** |

### tar vs zip

- **tar**: Solo empaqueta archivos (agrupa sin comprimir)
- **gzip/bzip2/xz**: Solo comprime (un solo archivo)
- **tar.gz**: tar empaqueta + gzip comprime = empaquetado comprimido

```
archivo1.txt  ─┐
archivo2.txt  ─┼─ tar ──> paquete.tar ──> gzip ──> paquete.tar.gz
carpeta/      ─┘
```

## 9.2 El Comando tar

### Crear un archivo tar.gz

```bash
# Sintaxis basica
$ tar -czf nombre_archivo.tar.gz directorio_o_archivos

# Ejemplos
$ tar -czf backup.tar.gz sitio_web/
$ tar -czf documentos.tar.gz *.txt *.md
$ tar -czf proyecto.tar.gz proyecto/
```

### Opciones de tar

| Opcion | Significado |
|--------|-------------|
| `-c` | **Create** - Crear un nuevo archivo |
| `-x` | **Extract** - Extraer contenido |
| `-z` | Usar gzip para comprimir/descomprimir |
| `-f` | **File** - Especificar nombre del archivo |
| `-v` | **Verbose** - Mostrar progreso |
| `-t` | **List** - Listar contenido sin extraer |

### Extraer un archivo tar.gz

```bash
# Extraer en el directorio actual
$ tar -xzf backup.tar.gz

# Extraer en un directorio especifico
$ tar -xzf backup.tar.gz -C /destino/

# Extraer con verbose (ver archivos)
$ tar -xzvf backup.tar.gz
```

### Listar contenido sin extraer

```bash
$ tar -tzf backup.tar.gz
sitio_web/
sitio_web/index.html
sitio_web/assets/
sitio_web/assets/css/
sitio_web/assets/css/styles.css
sitio_web/assets/js/
sitio_web/assets/js/app.js
sitio_web/admin/
sitio_web/admin/README.txt
```

Esto es util para verificar que un backup contiene lo esperado.

## 9.3 Creacion de Backups con Timestamp

Los backups deben tener nombres unicos para no sobrescribirse entre si:

```bash
#!/usr/bin/env bash

SOURCE_DIR="./sitio_web"
BACKUP_DIR="./backups"

# Generar timestamp
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

# Construir nombre del archivo
BACKUP_FILE="${BACKUP_DIR}/backup_sitio_web_${TIMESTAMP}.tar.gz"

# Crear el backup
echo "Creando backup de $SOURCE_DIR..."
tar -czf "$BACKUP_FILE" "$SOURCE_DIR"

echo "Backup creado: $BACKUP_FILE"
```

Resultado:
```
Creando backup de ./sitio_web...
Backup creado: ./backups/backup_sitio_web_2026-05-14_10-30-00.tar.gz
```

## 9.4 Script Completo de Backup (Como en el Proyecto)

```bash
#!/usr/bin/env bash
set -euo pipefail

# Cargar libreria y configuracion
source ./scripts/lib.sh
load_config

# Validar que el directorio fuente existe
require_dir "$SOURCE_DIR"

# Asegurar que el directorio de backups existe
ensure_dir "$BACKUP_DIR"
ensure_dir "$EVIDENCE_DIR"

# Generar nombre con timestamp
TIMESTAMP=$(now_stamp)
BACKUP_FILE="${BACKUP_DIR}/backup_sitio_web_${TIMESTAMP}.tar.gz"
EVIDENCE_FILE="${EVIDENCE_DIR}/backup_ejecucion.txt"

# Crear el backup
tar -czf "$BACKUP_FILE" "$SOURCE_DIR"

# Obtener informacion del backup
TAMANO=$(du -h "$BACKUP_FILE" | cut -f1)

# Documentar la ejecucion
{
    echo "=== Ejecucion de Backup ==="
    echo "Fecha:       $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Origen:      $SOURCE_DIR"
    echo "Destino:     $BACKUP_FILE"
    echo "Tamano:      $TAMANO"
    echo ""
    echo "--- Contenido del backup ---"
    tar -tzf "$BACKUP_FILE"
} | tee "$EVIDENCE_FILE"

echo ""
echo "Backup completado exitosamente."
```

## 9.5 Verificacion de Backups

Siempre verifica que un backup se creo correctamente:

```bash
# Verificar que el archivo existe y tiene tamano > 0
if [ -s "$BACKUP_FILE" ]; then
    echo "Backup verificado: $BACKUP_FILE"
else
    echo "Error: el backup esta vacio o no se creo"
    exit 1
fi

# Listar contenido para verificar integridad
tar -tzf "$BACKUP_FILE" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "Integridad verificada: el archivo se puede leer correctamente"
else
    echo "Error: el archivo esta corrupto"
    exit 1
fi

# Mostrar informacion del backup
echo "Tamano: $(du -h "$BACKUP_FILE" | cut -f1)"
echo "Archivos: $(tar -tzf "$BACKUP_FILE" | wc -l)"
```

## 9.6 Rotacion de Backups

La rotacion evita que los backups llenen el disco. La estrategia: conservar
los N mas recientes, eliminar el resto.

```bash
#!/usr/bin/env bash
set -euo pipefail

source ./scripts/lib.sh
load_config

ensure_dir "$EVIDENCE_DIR"

# Validar MAX_BACKUPS
if [[ ! "$MAX_BACKUPS" =~ ^[0-9]+$ ]] || [ "$MAX_BACKUPS" -le 0 ]; then
    echo "Error: MAX_BACKUPS debe ser un numero positivo"
    exit 1
fi

# Listar backups por fecha (mas nuevo primero)
LISTA=$(ls -1t "$BACKUP_DIR"/*.tar.gz 2>/dev/null || true)

if [ -z "$LISTA" ]; then
    echo "No hay backups para rotar."
    exit 0
fi

TOTAL=$(echo "$LISTA" | wc -l)

{
    echo "=== Rotacion de Backups ==="
    echo "Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Limite:   $MAX_BACKUPS"
    echo "Actuales: $TOTAL"
    echo ""

    if [ "$TOTAL" -gt "$MAX_BACKUPS" ]; then
        # Archivos que se conservan (los mas nuevos)
        CONSERVADOS=$(echo "$LISTA" | head -n "$MAX_BACKUPS")
        echo "--- Backups conservados ---"
        echo "$CONSERVADOS"
        echo ""

        # Archivos que se eliminan (los mas viejos)
        ELIMINADOS=$(echo "$LISTA" | tail -n +$((MAX_BACKUPS + 1)))
        echo "--- Backups eliminados ---"
        echo "$ELIMINADOS" | while read -r viejo; do
            echo "Eliminando: $viejo"
            rm -f "$viejo"
        done
    else
        echo "No es necesario rotar. $TOTAL <= $MAX_BACKUPS"
        echo ""
        echo "--- Backups actuales ---"
        echo "$LISTA"
    fi
} | tee "$EVIDENCE_DIR/rotacion.txt"
```

## 9.7 Otros Formatos de Compresion

### gzip (solo un archivo)

```bash
# Comprimir (elimina el original)
$ gzip archivo.txt          # Crea archivo.txt.gz

# Descomprimir
$ gunzip archivo.txt.gz     # Restaura archivo.txt

# Comprimir sin eliminar original
$ gzip -k archivo.txt       # Mantiene ambos
```

### zip (compatible con Windows)

```bash
# Crear zip
$ zip -r backup.zip directorio/

# Extraer zip
$ unzip backup.zip

# Listar contenido
$ unzip -l backup.zip
```

### Comparacion de tamanos

```bash
# Crear el mismo backup con diferentes compresiones
$ tar -czf backup.tar.gz sitio_web/     # gzip
$ tar -cjf backup.tar.bz2 sitio_web/    # bzip2
$ tar -cJf backup.tar.xz sitio_web/     # xz

# Comparar tamanos
$ ls -lh backup.tar.*
-rw-r--r-- 1 alumno alumno 4.2K backup.tar.gz
-rw-r--r-- 1 alumno alumno 3.8K backup.tar.bz2
-rw-r--r-- 1 alumno alumno 3.5K backup.tar.xz
```

## 9.8 Estrategias de Backup

### Tipos de backup

| Tipo | Descripcion | Tamano | Velocidad |
|------|-------------|--------|-----------|
| **Completo** | Copia todo | Grande | Lento |
| Incremental | Solo cambios desde el ultimo backup | Pequeno | Rapido |
| Diferencial | Cambios desde el ultimo completo | Medio | Medio |

El proyecto usa **backups completos** con rotacion, que es la estrategia
mas simple y confiable.

### Regla 3-2-1 de backups

- **3** copias de tus datos
- **2** tipos de medio de almacenamiento diferentes
- **1** copia fuera del sitio (offsite)

---

## Ejercicios

### [PRACTICA 9.1] Crear y explorar backups
```bash
# 1. Crea un directorio con archivos de prueba
$ mkdir -p prueba_backup/docs prueba_backup/scripts
$ echo "documento 1" > prueba_backup/docs/doc1.txt
$ echo "documento 2" > prueba_backup/docs/doc2.txt
$ echo "#!/bin/bash" > prueba_backup/scripts/test.sh

# 2. Crea un backup comprimido
$ tar -czf mi_backup.tar.gz prueba_backup/

# 3. Lista el contenido sin extraer
$ tar -tzf mi_backup.tar.gz

# 4. Verifica el tamano
$ du -h mi_backup.tar.gz
```

### [PRACTICA 9.2] Script de backup con timestamp
Escribe `mi_backup.sh` que:
1. Reciba un directorio como argumento
2. Cree un backup con timestamp en el nombre
3. Muestre el tamano y contenido del backup
4. Guarde un log de la operacion

### [PRACTICA 9.3] Rotacion
1. Ejecuta tu script de backup 8 veces (con `sleep 1` entre cada una para timestamps diferentes)
2. Escribe un script de rotacion que mantenga solo los 3 mas recientes
3. Verifica que funciono

### [PRACTICA 9.4] Verificador de integridad
Escribe un script que:
1. Liste todos los `.tar.gz` en un directorio
2. Para cada uno, intente leer su contenido (`tar -tzf`)
3. Reporte cuales estan intactos y cuales estan corruptos

---

## Resumen

| Operacion | Comando | Ejemplo |
|----------|---------|---------|
| Crear tar.gz | `tar -czf` | `tar -czf backup.tar.gz dir/` |
| Extraer tar.gz | `tar -xzf` | `tar -xzf backup.tar.gz` |
| Listar contenido | `tar -tzf` | `tar -tzf backup.tar.gz` |
| Tamano | `du -h` | `du -h backup.tar.gz` |
| Comprimir (gzip) | `gzip` | `gzip archivo.txt` |
| Crear zip | `zip -r` | `zip -r backup.zip dir/` |
| Timestamp | `date '+%Y-%m-%d_%H-%M-%S'` | Para nombres unicos |

### Flags de tar

```
-c = Create (crear)
-x = Extract (extraer)
-t = List (listar)
-z = gzip
-j = bzip2
-J = xz
-f = File (nombre de archivo)
-v = Verbose (detalles)
```

**Siguiente leccion**: [10 - Expresiones Regulares](10_Expresiones_Regulares.md)
