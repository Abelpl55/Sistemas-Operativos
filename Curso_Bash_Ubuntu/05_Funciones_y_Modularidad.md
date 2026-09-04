# Leccion 05: Funciones y Modularidad

## Objetivos

- Definir y llamar funciones en Bash
- Pasar parametros y retornar valores desde funciones
- Usar variables locales para evitar conflictos
- Crear librerias de funciones reutilizables con `source`

---

## 5.1 Que es una Funcion

Una funcion es un bloque de codigo reutilizable con un nombre. En lugar de repetir
el mismo codigo varias veces, lo encapsulas en una funcion y la llamas cuando la necesites.

### Sintaxis

```bash
# Forma 1 (recomendada)
nombre_funcion() {
    # comandos
}

# Forma 2
function nombre_funcion {
    # comandos
}
```

### Ejemplo basico

```bash
#!/usr/bin/env bash

# Definir la funcion
saludar() {
    echo "Hola desde la funcion saludar!"
}

# Llamar la funcion (sin parentesis)
saludar
saludar
```

Salida:
```
Hola desde la funcion saludar!
Hola desde la funcion saludar!
```

## 5.2 Parametros de Funciones

Las funciones reciben parametros igual que los scripts: con `$1`, `$2`, etc.

```bash
saludar() {
    echo "Hola, $1! Tienes $2 anos."
}

saludar "Maria" 22
saludar "Carlos" 25
```

Salida:
```
Hola, Maria! Tienes 22 anos.
Hola, Carlos! Tienes 25 anos.
```

### Variables especiales en funciones

| Variable | Significado |
|----------|-------------|
| `$1, $2, ...` | Parametros posicionales |
| `$@` | Todos los parametros como lista |
| `$#` | Numero de parametros |

```bash
mostrar_args() {
    echo "Numero de argumentos: $#"
    echo "Argumentos: $@"
    echo "Primero: $1"
    echo "Segundo: $2"
}

mostrar_args "uno" "dos" "tres"
```

## 5.3 Variables Locales

Por defecto, las variables en Bash son **globales**. Dentro de funciones, usa
`local` para crear variables que no afecten al resto del script:

```bash
#!/usr/bin/env bash

NOMBRE="Global"

cambiar_nombre() {
    local NOMBRE="Local"        # Solo existe dentro de esta funcion
    echo "Dentro: $NOMBRE"      # Local
}

echo "Antes: $NOMBRE"           # Global
cambiar_nombre                   # Llama a la funcion
echo "Despues: $NOMBRE"         # Global (no cambio)
```

**Regla**: Siempre usa `local` para variables dentro de funciones para evitar
efectos secundarios inesperados.

```bash
# Ejemplo: funcion que genera un timestamp
now_stamp() {
    local stamp
    stamp=$(date '+%Y-%m-%d_%H-%M-%S')
    echo "$stamp"
}

# Capturar el resultado
TIMESTAMP=$(now_stamp)
echo "Timestamp: $TIMESTAMP"
```

## 5.4 Retorno de Valores

### Con echo (retornar texto)

```bash
obtener_fecha() {
    echo "$(date '+%Y-%m-%d')"
}

# Capturar la salida con $()
FECHA=$(obtener_fecha)
echo "La fecha es: $FECHA"
```

### Con return (codigo numerico de salida)

`return` solo puede devolver un numero entre 0-255 (codigo de salida):

```bash
es_par() {
    local numero=$1
    if [ "$((numero % 2))" -eq 0 ]; then
        return 0    # Exito = es par
    else
        return 1    # Fallo = no es par
    fi
}

if es_par 4; then
    echo "4 es par"
fi

if ! es_par 7; then
    echo "7 no es par"
fi
```

### Patron comun: validar y salir con error

```bash
require_file() {
    local archivo="$1"
    if [ ! -f "$archivo" ]; then
        echo "Error: archivo no encontrado: $archivo"
        exit 1
    fi
}

# Si el archivo no existe, el script termina
require_file "./config.conf"
echo "Configuracion encontrada, continuando..."
```

## 5.5 Funciones con Logging

Un patron muy util es tener una funcion que registre mensajes con timestamp:

```bash
log_line() {
    local archivo="$1"
    local mensaje="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $mensaje" | tee -a "$archivo"
}

# Uso
log_line "evidencia/backup.txt" "Iniciando proceso de backup"
log_line "evidencia/backup.txt" "Backup completado exitosamente"
```

El archivo `evidencia/backup.txt` contendra:
```
[2026-05-14 10:30:00] Iniciando proceso de backup
[2026-05-14 10:30:05] Backup completado exitosamente
```

`tee -a` hace que el mensaje se escriba en el archivo (-a = append) Y se muestre
en pantalla al mismo tiempo.

## 5.6 Crear una Libreria de Funciones

Una libreria es un archivo `.sh` que contiene solo funciones, sin ejecutar nada
por si mismo. Otros scripts la cargan con `source`.

### lib.sh - Libreria de utilidades

```bash
#!/usr/bin/env bash
# lib.sh - Funciones compartidas para todos los scripts del proyecto

# Cargar archivo de configuracion
load_config() {
    local config_file="./config.conf"
    if [ ! -f "$config_file" ]; then
        echo "Error: $config_file no encontrado."
        exit 1
    fi
    source "$config_file"
}

# Crear directorio si no existe
ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

# Generar timestamp para nombres de archivo
now_stamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

# Registrar mensaje con timestamp
log_line() {
    local file="$1"
    local msg="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $msg" | tee -a "$file"
}

# Verificar que un archivo existe
require_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: archivo requerido no encontrado: $file"
        exit 1
    fi
}

# Verificar que un directorio existe
require_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Error: directorio requerido no encontrado: $dir"
        exit 1
    fi
}
```

### Usar la libreria desde otro script

```bash
#!/usr/bin/env bash
# backup.sh - Script de respaldo
set -euo pipefail

# Cargar libreria de funciones
source ./scripts/lib.sh

# Cargar configuracion
load_config

# Usar las funciones
ensure_dir "$BACKUP_DIR"
require_dir "$SOURCE_DIR"

TIMESTAMP=$(now_stamp)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.tar.gz"

log_line "${EVIDENCE_DIR}/backup.txt" "Iniciando backup de ${SOURCE_DIR}"

tar -czf "$BACKUP_FILE" "$SOURCE_DIR"

log_line "${EVIDENCE_DIR}/backup.txt" "Backup creado: $BACKUP_FILE"
```

## 5.7 El Patron source Explicado

```
+------------------+
|   config.conf    |  Variables de configuracion
+------------------+
        |
        | source
        v
+------------------+
|     lib.sh       |  Funciones compartidas
+------------------+
        |
        | source
        v
+-------+----------+---------+---------+
|       |          |         |         |
v       v          v         v         v
setup  backup   rotar   analizar  reporte
.sh    .sh      .sh     .sh       .sh
```

Cada script hace:
1. `source ./scripts/lib.sh` (carga funciones)
2. `load_config` (carga variables de config.conf)
3. Usa las funciones de lib.sh en su logica

**Ventajas**:
- No repites codigo
- Si cambias una funcion en lib.sh, todos los scripts se actualizan
- Codigo mas limpio y facil de mantener

## 5.8 Funciones Avanzadas

### Funcion que procesa multiples archivos

```bash
procesar_logs() {
    local directorio="$1"
    local patron="$2"
    local total=0

    for archivo in "$directorio"/*."$patron"; do
        if [ -f "$archivo" ]; then
            local lineas
            lineas=$(wc -l < "$archivo")
            echo "$archivo: $lineas lineas"
            total=$((total + lineas))
        fi
    done

    echo "Total: $total lineas"
}

procesar_logs "./logs" "log"
```

### Funcion de confirmacion

```bash
confirm_action() {
    local mensaje="$1"
    read -rp "$mensaje (s/n): " respuesta
    case "$respuesta" in
        [sS]|[sS][iI])
            return 0    # Confirmo
            ;;
        *)
            return 1    # No confirmo
            ;;
    esac
}

# Uso
if confirm_action "Deseas eliminar los backups antiguos?"; then
    echo "Eliminando..."
else
    echo "Operacion cancelada."
fi
```

---

## Ejercicios

### [PRACTICA 5.1] Funciones basicas
Crea un script con las siguientes funciones:
- `mostrar_linea()`: Imprime una linea de 40 guiones
- `encabezado(titulo)`: Imprime el titulo centrado entre lineas
- Usa ambas funciones para mostrar un reporte con 3 secciones

### [PRACTICA 5.2] Libreria personalizada
1. Crea `mis_funciones.sh` con:
   - `archivo_existe(ruta)`: retorna 0 si existe, 1 si no
   - `contar_lineas(archivo)`: imprime el numero de lineas
   - `tamano_archivo(archivo)`: imprime el tamano en formato legible
2. Crea `usar_lib.sh` que cargue la libreria y use las funciones

### [PRACTICA 5.3] Funcion de log
Crea una funcion `registrar(nivel, mensaje)` que escriba mensajes con formato:
```
[2026-05-14 10:30:00] [INFO] Mensaje informativo
[2026-05-14 10:30:01] [ERROR] Algo salio mal
[2026-05-14 10:30:02] [WARN] Advertencia
```

### [PRACTICA 5.4] Refactoriza
Toma tu menu de la practica 4.4 y:
1. Extrae cada opcion del menu a su propia funcion
2. Crea una funcion `mostrar_menu()` para imprimir las opciones
3. El codigo del menu principal debe ser solo llamadas a funciones

---

## Resumen

| Concepto | Sintaxis | Ejemplo |
|----------|----------|---------|
| Definir funcion | `nombre() { ... }` | `saludar() { echo "hola"; }` |
| Llamar funcion | `nombre args` | `saludar "Juan"` |
| Parametros | `$1, $2, $@, $#` | `echo "Hola $1"` |
| Variable local | `local var=valor` | `local nombre="Juan"` |
| Retornar texto | `echo "valor"` | `RESULTADO=$(funcion)` |
| Retornar codigo | `return 0` o `return 1` | `if funcion; then ...` |
| Cargar libreria | `source archivo.sh` | `source ./scripts/lib.sh` |

**Siguiente leccion**: [06 - Procesamiento de Texto](06_Procesamiento_de_Texto.md)
