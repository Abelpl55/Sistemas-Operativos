# Leccion 03: Variables y Entrada de Datos

## Objetivos

- Declarar y usar variables en Bash
- Entender la sustitucion de comandos y expansion de variables
- Leer entrada del usuario con `read`
- Escribir tu primer script ejecutable

---

## 3.1 Tu Primer Script

Un script es un archivo de texto con comandos que Bash ejecuta en secuencia.

Crea un archivo llamado `hola.sh`:

```bash
#!/usr/bin/env bash
# Mi primer script
echo "Hola, mundo!"
echo "Hoy es $(date)"
echo "Tu usuario es: $(whoami)"
```

Ejecucion:

```bash
$ chmod +x hola.sh     # Dar permiso de ejecucion (solo la primera vez)
$ ./hola.sh            # Ejecutar el script
Hola, mundo!
Hoy es jue may 14 10:30:00 CST 2026
Tu usuario es: alumno
```

### El Shebang (#!)

La primera linea `#!/usr/bin/env bash` se llama **shebang** y le dice al sistema
que interprete usar para ejecutar el script.

```bash
#!/usr/bin/env bash    # Forma portable (recomendada) - busca bash en el PATH
#!/bin/bash            # Forma directa (funciona en la mayoria de sistemas)
```

**Siempre** incluye el shebang como primera linea de tus scripts.

## 3.2 Variables

### Declarar variables

```bash
# Declaracion: NOMBRE=valor (SIN ESPACIOS alrededor del =)
NOMBRE="Juan"
EDAD=22
DIRECTORIO="/home/alumno/proyecto"
ARCHIVO="backup.tar.gz"

# INCORRECTO - causa error:
# NOMBRE = "Juan"     # Error: espacios alrededor del =
```

**Reglas para nombres de variables**:
- Solo letras, numeros y guion bajo
- No pueden empezar con numero
- Convencion: MAYUSCULAS para constantes/configuracion, minusculas para locales

### Usar variables

```bash
# Se accede con $ o ${}
echo "Hola, $NOMBRE"
echo "Tu directorio es: ${DIRECTORIO}"
echo "El archivo es: ${ARCHIVO}"
```

### Cuando usar \${} en lugar de $

```bash
FRUTA="manzana"

# Ambiguo - bash no sabe donde termina el nombre:
echo "$FRUTAs"     # Error: busca variable FRUTAs (no existe)

# Correcto - las llaves delimitan el nombre:
echo "${FRUTA}s"   # Imprime: manzanas
```

**Regla**: Usa `${variable}` cuando la variable esta pegada a otro texto.

## 3.3 Tipos de Variables

Bash no tiene tipos estrictos. Todo es texto, pero se interpreta segun el contexto:

```bash
# Cadena de texto
MENSAJE="Hola mundo"

# Numero (Bash lo trata como texto hasta que lo uses en aritmetica)
CANTIDAD=42

# Variable vacia
VACIA=""

# Variable con espacios (necesita comillas)
RUTA_COMPLETA="/home/mi usuario/documentos"
```

### Variables de entorno vs Variables locales

```bash
# Variable local (solo existe en este script/sesion)
MI_VAR="solo aqui"

# Variable de entorno (disponible para procesos hijos)
export MI_VAR_GLOBAL="para todos"

# Ver todas las variables de entorno
$ env

# Ver una variable especifica
$ echo $HOME
$ echo $PATH
$ echo $USER
```

### Variables especiales del sistema

| Variable | Contenido |
|----------|-----------|
| `$HOME` | Directorio home del usuario |
| `$USER` | Nombre del usuario actual |
| `$PWD` | Directorio de trabajo actual |
| `$PATH` | Directorios donde buscar ejecutables |
| `$SHELL` | Shell actual |
| `$HOSTNAME` | Nombre de la maquina |
| `$RANDOM` | Numero aleatorio |

## 3.4 Sustitucion de Comandos

Permite capturar la salida de un comando en una variable:

```bash
# Sintaxis moderna (recomendada): $(comando)
FECHA=$(date)
USUARIO=$(whoami)
DIRECTORIO_ACTUAL=$(pwd)
NUM_ARCHIVOS=$(ls | wc -l)

echo "Fecha: $FECHA"
echo "Usuario: $USUARIO"
echo "Estoy en: $DIRECTORIO_ACTUAL"
echo "Hay $NUM_ARCHIVOS archivos aqui"
```

```bash
# Ejemplo practico: timestamp para nombres de archivo
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
NOMBRE_BACKUP="backup_${TIMESTAMP}.tar.gz"
echo "$NOMBRE_BACKUP"
# Resultado: backup_2026-05-14_10-30-00.tar.gz
```

### Formatos de fecha comunes

```bash
$ date '+%Y-%m-%d'           # 2026-05-14
$ date '+%Y-%m-%d_%H-%M-%S'  # 2026-05-14_10-30-00 (para archivos)
$ date '+%Y-%m-%d %H:%M:%S'  # 2026-05-14 10:30:00 (para logs)
$ date '+%d/%m/%Y'           # 14/05/2026
```

| Formato | Significado | Ejemplo |
|---------|-------------|---------|
| `%Y` | Ano (4 digitos) | 2026 |
| `%m` | Mes (01-12) | 05 |
| `%d` | Dia (01-31) | 14 |
| `%H` | Hora (00-23) | 10 |
| `%M` | Minuto (00-59) | 30 |
| `%S` | Segundo (00-59) | 00 |

## 3.5 Expansion Aritmetica

Para operaciones matematicas usa `$(( ))`:

```bash
A=10
B=3

echo "Suma:     $((A + B))"       # 13
echo "Resta:    $((A - B))"       # 7
echo "Producto: $((A * B))"       # 30
echo "Division: $((A / B))"       # 3 (division entera)
echo "Modulo:   $((A % B))"       # 1 (residuo)

# Incrementar
CONTADOR=0
CONTADOR=$((CONTADOR + 1))
echo "$CONTADOR"                   # 1

# Ejemplo del proyecto: calcular exceso de backups
MAX_BACKUPS=5
TOTAL=8
EXCESO=$((TOTAL - MAX_BACKUPS))
echo "Hay $EXCESO backups de mas"  # Hay 3 backups de mas
```

## 3.6 Leer Entrada del Usuario

### Comando read

```bash
#!/usr/bin/env bash

# Leer una variable
echo "Como te llamas?"
read NOMBRE
echo "Hola, $NOMBRE!"

# Leer con prompt en la misma linea (-p)
read -p "Ingresa tu edad: " EDAD
echo "Tienes $EDAD anos"

# Leer sin mostrar lo escrito (-s) - para contrasenas
read -sp "Contrasena: " PASS
echo    # Salto de linea despues del input oculto
echo "Contrasena guardada."

# Leer con -r (recomendado: no interpreta backslashes)
read -r LINEA
```

**Siempre usa `read -r`** para evitar problemas con caracteres especiales.

### Ejemplo practico: script interactivo

```bash
#!/usr/bin/env bash

read -rp "Nombre del proyecto: " PROYECTO
read -rp "Tu ID de alumno: " ALUMNO_ID
read -rp "Directorio de trabajo: " WORK_DIR

echo "=== Configuracion ==="
echo "Proyecto:   $PROYECTO"
echo "Alumno:     $ALUMNO_ID"
echo "Directorio: $WORK_DIR"
```

## 3.7 Parametros de Script (Argumentos)

Un script puede recibir datos como argumentos al ejecutarse:

```bash
$ ./mi_script.sh argumento1 argumento2 argumento3
```

Dentro del script:

```bash
#!/usr/bin/env bash

echo "Nombre del script: $0"    # ./mi_script.sh
echo "Primer argumento:  $1"    # argumento1
echo "Segundo argumento: $2"    # argumento2
echo "Tercer argumento:  $3"    # argumento3
echo "Todos los args:    $@"    # argumento1 argumento2 argumento3
echo "Numero de args:    $#"    # 3
```

| Variable | Significado |
|----------|-------------|
| `$0` | Nombre del script |
| `$1` a `$9` | Argumentos posicionales |
| `$@` | Todos los argumentos (como lista) |
| `$#` | Numero de argumentos |
| `$?` | Codigo de salida del ultimo comando |
| `$$` | PID del script actual |

### Ejemplo: script que recibe una ruta

```bash
#!/usr/bin/env bash
# Uso: ./contar.sh /ruta/directorio

DIRECTORIO="$1"

if [ -z "$DIRECTORIO" ]; then
    echo "Error: debes proporcionar un directorio"
    echo "Uso: $0 /ruta/directorio"
    exit 1
fi

TOTAL=$(ls "$DIRECTORIO" | wc -l)
echo "El directorio $DIRECTORIO tiene $TOTAL elementos"
```

## 3.8 Comillas: Simples vs Dobles

```bash
NOMBRE="mundo"

# Comillas dobles: expanden variables y sustituciones
echo "Hola, $NOMBRE"          # Hola, mundo
echo "Fecha: $(date)"         # Fecha: jue may 14...

# Comillas simples: texto literal, nada se expande
echo 'Hola, $NOMBRE'          # Hola, $NOMBRE
echo 'Fecha: $(date)'         # Fecha: $(date)

# Sin comillas: funciona pero es peligroso con espacios
echo $NOMBRE                   # mundo (funciona aqui)
# Pero si NOMBRE="mi mundo":
echo $NOMBRE                   # mi mundo (podria causar problemas)
echo "$NOMBRE"                 # mi mundo (seguro)
```

**Regla**: Siempre usa comillas dobles `"$variable"` a menos que necesites
texto literal (entonces usa comillas simples).

## 3.9 Source: Cargar Variables desde Otro Archivo

El comando `source` (o `.`) ejecuta un archivo dentro del shell actual,
haciendo disponibles sus variables y funciones:

```bash
# config.conf
PROJECT_NAME="SO-Proyecto"
SOURCE_DIR="./sitio_web"
BACKUP_DIR="./backups"
MAX_BACKUPS=5
```

```bash
#!/usr/bin/env bash
# mi_script.sh

# Cargar configuracion
source ./config.conf
# Alternativa: . ./config.conf

echo "Proyecto: $PROJECT_NAME"
echo "Origen:   $SOURCE_DIR"
echo "Backups:  $BACKUP_DIR"
echo "Maximo:   $MAX_BACKUPS"
```

**Esto es exactamente lo que hace el proyecto**: `config.conf` tiene la configuracion
y cada script lo carga con `source`.

---

## Ejercicios

### [PRACTICA 3.1] Script con variables
Crea `info_sistema.sh` que muestre:
```
=== Informacion del Sistema ===
Usuario:    [tu usuario]
Hostname:   [nombre de maquina]
Fecha:      [fecha actual]
Directorio: [directorio actual]
Shell:      [tu shell]
```

### [PRACTICA 3.2] Script con argumentos
Crea `saludo.sh` que reciba un nombre como argumento:
```bash
$ ./saludo.sh Juan
Hola, Juan! Bienvenido.
Hoy es jueves 14 de mayo de 2026

# Si no recibe argumento:
$ ./saludo.sh
Error: Por favor proporciona tu nombre
Uso: ./saludo.sh <nombre>
```

### [PRACTICA 3.3] Script con configuracion
1. Crea un archivo `mi_config.conf` con:
   ```
   ALUMNO="Tu Nombre"
   MATERIA="Sistemas Operativos"
   SEMESTRE="2026-A"
   ```
2. Crea `mostrar_config.sh` que cargue el archivo con `source` y muestre los datos

### [PRACTICA 3.4] Timestamps
Crea `timestamp.sh` que genere un nombre de archivo con la fecha:
```bash
$ ./timestamp.sh
Nombre de backup: backup_2026-05-14_10-30-00.tar.gz
```

---

## Resumen

| Concepto | Sintaxis | Ejemplo |
|----------|----------|---------|
| Variable | `NOMBRE=valor` | `DIR="/home"` |
| Usar variable | `$VAR` o `${VAR}` | `echo "$DIR"` |
| Sustitucion | `$(comando)` | `FECHA=$(date)` |
| Aritmetica | `$((expresion))` | `$((A + B))` |
| Leer input | `read -rp "msg" VAR` | `read -rp "Nombre: " N` |
| Argumento | `$1, $2, $@, $#` | `echo "$1"` |
| Cargar archivo | `source archivo` | `source ./config.conf` |
| Comillas dobles | `"expande $vars"` | `"Hola $NOMBRE"` |
| Comillas simples | `'texto literal'` | `'No expande $nada'` |

**Siguiente leccion**: [04 - Estructuras de Control](04_Estructuras_de_Control.md)
