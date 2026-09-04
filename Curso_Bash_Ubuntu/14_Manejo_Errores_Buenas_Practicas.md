# Leccion 14: Manejo de Errores y Buenas Practicas

## Objetivos

- Implementar manejo robusto de errores con `set -euo pipefail`
- Aplicar validaciones de entrada y prerequisitos
- Escribir scripts legibles, mantenibles y seguros
- Usar colores ANSI para mejorar la salida en terminal

---

## 14.1 set -euo pipefail (Modo Estricto)

La primera linea despues del shebang debe ser:

```bash
#!/usr/bin/env bash
set -euo pipefail
```

### Que hace cada flag

| Flag | Efecto | Sin la flag |
|------|--------|-------------|
| `-e` | El script termina si un comando falla | Continua ignorando errores |
| `-u` | Error si usas una variable no definida | La trata como cadena vacia |
| `-o pipefail` | Un pipe falla si cualquier comando falla | Solo falla si el ultimo falla |

### Ejemplos

#### Sin set -e (peligroso)

```bash
#!/usr/bin/env bash
rm -rf /directorio/importante    # Si falla, sigue adelante
cp nuevos_datos/ /directorio/    # Esto podria copiar en el lugar equivocado
echo "Todo bien!"                # Se imprime aunque haya errores
```

#### Con set -e (seguro)

```bash
#!/usr/bin/env bash
set -euo pipefail
rm -rf /directorio/importante    # Si falla, el script TERMINA aqui
cp nuevos_datos/ /directorio/    # Nunca se ejecuta si lo anterior fallo
echo "Todo bien!"                # Solo se imprime si todo funciono
```

#### set -u: variables no definidas

```bash
#!/usr/bin/env bash
set -u

echo "$VARIABLE_QUE_NO_EXISTE"   # ERROR: VARIABLE_QUE_NO_EXISTE: unbound variable
```

#### set -o pipefail: pipes seguros

```bash
#!/usr/bin/env bash

# Sin pipefail: solo importa el ultimo comando del pipe
grep "patron" archivo_inexistente.txt | sort | head
echo $?   # 0 (head tuvo exito, aunque grep fallo)

# Con pipefail: si grep falla, todo el pipe falla
set -o pipefail
grep "patron" archivo_inexistente.txt | sort | head
echo $?   # 2 (grep fallo)
```

## 14.2 Manejar Errores Controladamente

### El patron || true

Cuando usas `set -e` pero un comando que falla es **esperado** (como grep
que no encuentra nada):

```bash
set -euo pipefail

# PROBLEMA: grep retorna 1 si no encuentra nada → el script termina
RESULTADO=$(grep "patron_raro" archivo.txt)

# SOLUCION: || true evita que el codigo de salida 1 mate el script
RESULTADO=$(grep "patron_raro" archivo.txt || true)

# Ahora RESULTADO esta vacio pero el script continua
if [ -n "$RESULTADO" ]; then
    echo "Encontrado: $RESULTADO"
else
    echo "No se encontro el patron"
fi
```

### El patron 2>/dev/null || true

Para comandos que pueden fallar Y producir errores en stderr:

```bash
# ls falla si no hay archivos .tar.gz, redirigimos error y continuamos
LISTA=$(ls -1t backups/*.tar.gz 2>/dev/null || true)

if [ -z "$LISTA" ]; then
    echo "No hay backups."
    exit 0
fi
```

## 14.3 Validaciones de Entrada

### Validar argumentos del script

```bash
#!/usr/bin/env bash
set -euo pipefail

# Verificar que se recibio un argumento
if [ $# -lt 1 ]; then
    echo "Error: falta argumento"
    echo "Uso: $0 <directorio>"
    exit 1
fi

DIRECTORIO="$1"

# Verificar que el argumento es un directorio valido
if [ ! -d "$DIRECTORIO" ]; then
    echo "Error: '$DIRECTORIO' no es un directorio valido"
    exit 1
fi
```

### Validar que una variable es un numero

```bash
MAX_BACKUPS="$1"

# Verificar que es un numero
if [[ ! "$MAX_BACKUPS" =~ ^[0-9]+$ ]]; then
    echo "Error: MAX_BACKUPS debe ser un numero"
    exit 1
fi

# Verificar que es mayor a 0
if [ "$MAX_BACKUPS" -le 0 ]; then
    echo "Error: MAX_BACKUPS debe ser mayor a 0"
    exit 1
fi
```

### Validar que un archivo de configuracion existe

```bash
CONFIG_FILE="./config.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: archivo de configuracion no encontrado: $CONFIG_FILE"
    echo "Asegurate de estar en el directorio raiz del proyecto"
    exit 1
fi

source "$CONFIG_FILE"
```

### Validar cadenas vacias

```bash
# Verificar que STUDENT_ID no esta vacio ni es el valor por defecto
if [ -z "$STUDENT_ID" ] || [ "$STUDENT_ID" = "ALUMNO_DEMO" ]; then
    echo "Error: debes configurar tu STUDENT_ID en config.conf"
    exit 1
fi
```

## 14.4 Colores ANSI en la Terminal

Los codigos ANSI permiten agregar color y formato al texto en la terminal:

### Definir colores

```bash
# Colores basicos
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'         # NC = No Color (reset)
```

### Usar colores

```bash
echo -e "${GREEN}Operacion exitosa${NC}"
echo -e "${RED}Error: archivo no encontrado${NC}"
echo -e "${YELLOW}Advertencia: disco casi lleno${NC}"
echo -e "${BLUE}Info: procesando datos...${NC}"
echo -e "${BOLD}Texto en negrita${NC}"
echo -e "${CYAN}=== MENU PRINCIPAL ===${NC}"
```

**Nota**: Usa `echo -e` para interpretar los codigos de escape.

### Funciones de color

```bash
info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Uso
info "Iniciando proceso..."
ok "Backup creado exitosamente"
warn "Solo quedan 2 espacios de backup"
error "No se pudo crear el archivo"
```

### Indicadores de estado

```bash
mostrar_estado() {
    local archivo="$1"
    if [ -f "$archivo" ]; then
        echo -e "  ${GREEN}[existe]${NC} $archivo"
    else
        echo -e "  ${RED}[falta]${NC}  $archivo"
    fi
}

echo "=== Verificacion de archivos ==="
mostrar_estado "evidencia/setup_estructura.txt"
mostrar_estado "evidencia/backup_ejecucion.txt"
mostrar_estado "evidencia/rotacion.txt"
mostrar_estado "reportes/reporte_access.txt"
mostrar_estado "reportes/reporte_error.txt"
mostrar_estado "reportes/reporte_final.md"
```

## 14.5 Estructura de un Script Profesional

```bash
#!/usr/bin/env bash
# ============================================
# Nombre:    backup.sh
# Proposito: Crear respaldo comprimido del sitio web
# Uso:       ./scripts/backup.sh
# ============================================
set -euo pipefail

# --- Cargar dependencias ---
source ./scripts/lib.sh
load_config

# --- Validaciones ---
require_dir "$SOURCE_DIR"
ensure_dir "$BACKUP_DIR"
ensure_dir "$EVIDENCE_DIR"

# --- Logica principal ---
TIMESTAMP=$(now_stamp)
BACKUP_FILE="${BACKUP_DIR}/backup_sitio_web_${TIMESTAMP}.tar.gz"

tar -czf "$BACKUP_FILE" "$SOURCE_DIR"

TAMANO=$(du -h "$BACKUP_FILE" | cut -f1)

# --- Documentar ---
{
    echo "=== Backup ==="
    echo "Fecha:   $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Archivo: $BACKUP_FILE"
    echo "Tamano:  $TAMANO"
} | tee "$EVIDENCE_DIR/backup_ejecucion.txt"

echo "Backup completado."
```

### Principios del script

1. **Shebang** portable: `#!/usr/bin/env bash`
2. **Comentario de encabezado**: Nombre, proposito, uso
3. **Modo estricto**: `set -euo pipefail`
4. **Cargar dependencias**: `source` de librerias y config
5. **Validar prerequisitos**: Antes de hacer cualquier cosa
6. **Logica clara**: Una responsabilidad por script
7. **Documentar resultados**: Generar evidencia

## 14.6 Buenas Practicas

### Variables

```bash
# BIEN: entre comillas (protege contra espacios)
echo "$VARIABLE"
rm -f "$ARCHIVO"

# MAL: sin comillas
echo $VARIABLE
rm -f $ARCHIVO     # Si ARCHIVO="mi archivo.txt", borra "mi" y "archivo.txt"
```

### Nombres descriptivos

```bash
# BIEN
BACKUP_DIR="./backups"
MAX_BACKUPS=5
ACCESS_LOG="./logs/access.log"

# MAL
D="./backups"
M=5
F="./logs/access.log"
```

### Un script, una responsabilidad

```bash
# BIEN: scripts separados
backup.sh           # Solo crea backups
rotar_backups.sh    # Solo rota backups
analizar_access.sh  # Solo analiza access.log

# MAL: un script gigante que hace todo
hacer_todo.sh       # Dificil de mantener y depurar
```

### Funciones reutilizables en libreria

```bash
# BIEN: funciones comunes en lib.sh, usadas por todos
source ./scripts/lib.sh
load_config
ensure_dir "$BACKUP_DIR"

# MAL: copiar el mismo codigo en cada script
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi
```

### Documentar con evidencia

```bash
# BIEN: cada script genera evidencia de ejecucion
{
    echo "Fecha: $(date)"
    echo "Resultado: exito"
    echo "Archivo: $BACKUP_FILE"
} | tee "$EVIDENCE_DIR/backup_ejecucion.txt"

# MAL: ejecutar sin dejar rastro
tar -czf backup.tar.gz sitio_web/
```

## 14.7 Debugging de Scripts

### bash -x: ejecutar con traza

```bash
# Muestra cada comando antes de ejecutarlo
$ bash -x scripts/backup.sh
+ set -euo pipefail
+ source ./scripts/lib.sh
++ load_config() { ... }
+ load_config
+ source ./config.conf
++ SOURCE_DIR=./sitio_web
...
```

### Agregar debug temporal

```bash
# Activar debug en una seccion especifica
set -x    # Activar
# ... codigo a depurar ...
set +x    # Desactivar
```

### Mensajes de debug

```bash
DEBUG=true

debug_msg() {
    if [ "$DEBUG" = "true" ]; then
        echo "[DEBUG] $1" >&2
    fi
}

debug_msg "Variable BACKUP_DIR = $BACKUP_DIR"
debug_msg "Archivos encontrados: $TOTAL"
```

---

## Ejercicios

### [PRACTICA 14.1] Modo estricto
Crea un script que:
1. Use `set -euo pipefail`
2. Intente acceder a una variable no definida (observa el error)
3. Intente ejecutar un comando inexistente (observa el error)
4. Corrige los errores y verifica que funciona

### [PRACTICA 14.2] Validaciones robustas
Escribe un script `validar.sh` que reciba 2 argumentos:
1. Un directorio (valida que existe)
2. Un numero (valida que es positivo)
Muestra errores descriptivos para cada caso invalido.

### [PRACTICA 14.3] Script con colores
Crea un script que muestre un reporte de estado del sistema con:
- Nombre del host (en cyan)
- Espacio en disco (en verde si > 20% libre, amarillo si < 20%, rojo si < 5%)
- Usuarios conectados (en azul)

### [PRACTICA 14.4] Refactoriza un script
Toma cualquier script de los ejercicios anteriores y:
1. Agrega `set -euo pipefail`
2. Extrae funciones reutilizables
3. Agrega validaciones de entrada
4. Agrega colores a la salida
5. Genera un archivo de evidencia

---

## Resumen

| Practica | Como implementarla |
|----------|-------------------|
| Modo estricto | `set -euo pipefail` |
| Evitar fallo esperado | `comando` &#124;&#124; `true` |
| Descartar errores | `2>/dev/null` |
| Validar archivo | `[ -f "$archivo" ]` &#124;&#124; `exit 1` |
| Validar directorio | `[ -d "$dir" ]` &#124;&#124; `exit 1` |
| Validar numero | `[[ "$var" =~ ^[0-9]+$ ]]` |
| Validar no vacio | `[ -z "$var" ] && exit 1` |
| Colores | `echo -e "${RED}error${NC}"` |
| Debug | `bash -x script.sh` |
| Comillas siempre | `"$variable"` |

**Siguiente leccion**: [15 - Proyecto Final: Guia de Desarrollo](15_Proyecto_Final_Guia.md)
