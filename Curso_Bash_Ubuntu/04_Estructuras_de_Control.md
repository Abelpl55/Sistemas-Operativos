# Leccion 04: Estructuras de Control

## Objetivos

- Usar condicionales `if`, `elif`, `else` para tomar decisiones
- Dominar los operadores de comparacion y pruebas de archivos
- Usar `case` para menus y seleccion multiple
- Implementar bucles `for`, `while` y `until`

---

## 4.1 Condicional if

### Sintaxis basica

```bash
if [ condicion ]; then
    # comandos si la condicion es verdadera
fi
```

### if / else

```bash
if [ condicion ]; then
    # si verdadero
else
    # si falso
fi
```

### if / elif / else

```bash
if [ condicion1 ]; then
    # si condicion1 es verdadera
elif [ condicion2 ]; then
    # si condicion2 es verdadera
else
    # si ninguna es verdadera
fi
```

### Ejemplo practico

```bash
#!/usr/bin/env bash

EDAD=20

if [ "$EDAD" -ge 18 ]; then
    echo "Eres mayor de edad"
else
    echo "Eres menor de edad"
fi
```

## 4.2 Operadores de Comparacion

### Comparacion de numeros

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `-eq` | Igual a (equal) | `[ "$A" -eq 5 ]` |
| `-ne` | Diferente de (not equal) | `[ "$A" -ne 5 ]` |
| `-gt` | Mayor que (greater than) | `[ "$A" -gt 5 ]` |
| `-ge` | Mayor o igual (greater or equal) | `[ "$A" -ge 5 ]` |
| `-lt` | Menor que (less than) | `[ "$A" -lt 5 ]` |
| `-le` | Menor o igual (less or equal) | `[ "$A" -le 5 ]` |

```bash
TOTAL=8
MAX=5

if [ "$TOTAL" -gt "$MAX" ]; then
    echo "Excediste el limite: $TOTAL > $MAX"
fi
```

### Comparacion de cadenas de texto

| Operador | Significado | Ejemplo |
|----------|-------------|---------|
| `=` | Iguales | `[ "$A" = "hola" ]` |
| `!=` | Diferentes | `[ "$A" != "hola" ]` |
| `-z` | Cadena vacia | `[ -z "$A" ]` |
| `-n` | Cadena NO vacia | `[ -n "$A" ]` |

```bash
NOMBRE=""

if [ -z "$NOMBRE" ]; then
    echo "Error: el nombre esta vacio"
    exit 1
fi

echo "Hola, $NOMBRE"
```

### Pruebas de archivos y directorios

| Operador | Significado |
|----------|-------------|
| `-f archivo` | Existe y es un archivo regular |
| `-d directorio` | Existe y es un directorio |
| `-e path` | Existe (archivo o directorio) |
| `-r archivo` | Tiene permiso de lectura |
| `-w archivo` | Tiene permiso de escritura |
| `-x archivo` | Tiene permiso de ejecucion |
| `-s archivo` | Existe y tiene tamano mayor a cero |
| `! condicion` | Negacion (NOT) |

```bash
#!/usr/bin/env bash

# Verificar si un directorio existe
if [ ! -d "./backups" ]; then
    echo "Creando directorio de backups..."
    mkdir -p ./backups
fi

# Verificar si un archivo existe
if [ -f "./config.conf" ]; then
    echo "Cargando configuracion..."
    source ./config.conf
else
    echo "Error: config.conf no encontrado"
    exit 1
fi
```

## 4.3 Operadores Logicos

```bash
# AND - ambas condiciones deben ser verdaderas
if [ "$A" -gt 0 ] && [ "$A" -lt 100 ]; then
    echo "A esta entre 1 y 99"
fi

# OR - al menos una condicion debe ser verdadera
if [ -f "access.log" ] || [ -f "error.log" ]; then
    echo "Al menos un archivo de log existe"
fi

# NOT - niega la condicion
if [ ! -d "./backups" ]; then
    echo "El directorio backups NO existe"
fi
```

## 4.4 Corchetes Simples vs Dobles

Bash tiene dos formas de evaluar condiciones:

### [ condicion ] - Test clasico (POSIX)

```bash
# Funciona en cualquier shell POSIX
if [ "$VAR" = "valor" ]; then
    echo "ok"
fi
```

### [[ condicion ]] - Test extendido (Bash)

```bash
# Solo funciona en Bash, pero tiene mas funciones
if [[ "$VAR" == "valor" ]]; then
    echo "ok"
fi

# Soporta regex con =~
if [[ "$EMAIL" =~ ^[a-zA-Z]+@[a-zA-Z]+\.[a-zA-Z]+$ ]]; then
    echo "Email valido"
fi

# Soporta patron con *
if [[ "$ARCHIVO" == *.tar.gz ]]; then
    echo "Es un archivo comprimido"
fi
```

### Cuando usar cual

- `[ ]`: Cuando necesitas compatibilidad POSIX o es una prueba simple
- `[[ ]]`: Cuando necesitas regex (`=~`) o comparacion con patrones (`*`)

Ejemplo del proyecto (validacion de numero):

```bash
MAX_BACKUPS=5

# Verificar que MAX_BACKUPS es un numero valido
if [[ ! "$MAX_BACKUPS" =~ ^[0-9]+$ ]]; then
    echo "Error: MAX_BACKUPS debe ser un numero"
    exit 1
fi

if [ "$MAX_BACKUPS" -le 0 ]; then
    echo "Error: MAX_BACKUPS debe ser mayor a 0"
    exit 1
fi
```

## 4.5 Case: Seleccion Multiple

`case` es ideal para menus y cuando necesitas comparar una variable con multiples valores:

```bash
case "$variable" in
    patron1)
        # comandos
        ;;
    patron2)
        # comandos
        ;;
    patron3|patron4)
        # comandos para patron3 O patron4
        ;;
    *)
        # default: si nada coincide
        ;;
esac
```

### Ejemplo: Menu interactivo

```bash
#!/usr/bin/env bash

echo "=== MENU ==="
echo "1) Ejecutar backup"
echo "2) Analizar logs"
echo "3) Ver reportes"
echo "0) Salir"
echo ""
read -rp "Selecciona una opcion: " opcion

case "$opcion" in
    1)
        echo "Ejecutando backup..."
        ./scripts/backup.sh
        ;;
    2)
        echo "Analizando logs..."
        ./scripts/analizar_access.sh
        ;;
    3)
        echo "Mostrando reportes..."
        ls -l reportes/
        ;;
    0)
        echo "Adios!"
        exit 0
        ;;
    *)
        echo "Opcion invalida: $opcion"
        ;;
esac
```

### Ejemplo: Confirmacion si/no

```bash
read -rp "Continuar? (s/n): " respuesta

case "$respuesta" in
    [sS]|[sS][iI])
        echo "Continuando..."
        ;;
    [nN]|[nN][oO])
        echo "Cancelado."
        exit 0
        ;;
    *)
        echo "Respuesta no valida."
        exit 1
        ;;
esac
```

El patron `[sS]|[sS][iI]` acepta: s, S, si, Si, sI, SI.

## 4.6 Bucle for

### Iterar sobre una lista

```bash
# Lista de elementos
for FRUTA in manzana pera naranja; do
    echo "Me gusta la $FRUTA"
done

# Lista de archivos
for ARCHIVO in scripts/*.sh; do
    echo "Script encontrado: $ARCHIVO"
done

# Secuencia de numeros
for i in {1..5}; do
    echo "Iteracion $i"
done

# Secuencia con incremento
for i in {0..20..5}; do
    echo "Valor: $i"    # 0, 5, 10, 15, 20
done
```

### for estilo C

```bash
for ((i = 0; i < 10; i++)); do
    echo "Numero: $i"
done
```

### Ejemplo practico: dar permisos a todos los scripts

```bash
for script in scripts/*.sh; do
    chmod +x "$script"
    echo "Permiso otorgado: $script"
done
```

## 4.7 Bucle while

Repite mientras la condicion sea verdadera:

```bash
# Contar del 1 al 5
CONTADOR=1
while [ "$CONTADOR" -le 5 ]; do
    echo "Contando: $CONTADOR"
    CONTADOR=$((CONTADOR + 1))
done
```

### Leer un archivo linea por linea

Esta es una de las construcciones mas usadas en Bash:

```bash
while read -r linea; do
    echo "Linea: $linea"
done < archivo.txt
```

```bash
# Contar lineas que contienen "error"
ERRORES=0
while read -r linea; do
    if [[ "$linea" == *"error"* ]]; then
        ERRORES=$((ERRORES + 1))
    fi
done < log.txt
echo "Total de errores: $ERRORES"
```

### while con pipe

```bash
# Procesar la salida de un comando
echo "$LISTA_ARCHIVOS" | while read -r archivo; do
    echo "Procesando: $archivo"
    rm -f "$archivo"
done
```

### Bucle infinito (para menus)

```bash
while true; do
    echo "=== MENU ==="
    echo "1) Opcion 1"
    echo "0) Salir"
    read -rp "Elige: " opcion

    case "$opcion" in
        1) echo "Ejecutando opcion 1" ;;
        0) echo "Adios!"; break ;;    # break sale del bucle
        *) echo "Opcion invalida" ;;
    esac
done
```

## 4.8 Bucle until

Repite **hasta que** la condicion sea verdadera (opuesto a while):

```bash
INTENTOS=0
until [ "$INTENTOS" -ge 3 ]; do
    read -rsp "Contrasena: " PASS
    echo
    if [ "$PASS" = "secreto" ]; then
        echo "Acceso concedido"
        break
    fi
    INTENTOS=$((INTENTOS + 1))
    echo "Intento $INTENTOS de 3"
done

if [ "$INTENTOS" -ge 3 ]; then
    echo "Demasiados intentos. Bloqueado."
fi
```

## 4.9 Control de Bucles: break y continue

```bash
# break - sale del bucle completamente
for i in {1..100}; do
    if [ "$i" -eq 10 ]; then
        echo "Llegue a 10, salgo del bucle"
        break
    fi
    echo "$i"
done

# continue - salta a la siguiente iteracion
for i in {1..10}; do
    if [ "$((i % 2))" -eq 0 ]; then
        continue    # Saltar numeros pares
    fi
    echo "Impar: $i"   # Solo imprime impares
done
```

## 4.10 Codigos de Salida

Cada comando en Linux retorna un **codigo de salida**:

- `0` = exito
- `1-255` = error (distintos codigos para distintos errores)

```bash
# Verificar el codigo de salida del ultimo comando
$ ls /directorio_existente
$ echo $?
0

$ ls /directorio_inexistente
$ echo $?
2
```

En scripts:

```bash
#!/usr/bin/env bash

# Salir con error
if [ ! -f "config.conf" ]; then
    echo "Error: archivo de configuracion no encontrado"
    exit 1    # Salir con codigo de error
fi

# Si todo bien, el script termina con exito
echo "Todo correcto"
exit 0    # Salir con exito (opcional, 0 es el default)
```

### Encadenar comandos con && y ||

```bash
# && ejecuta el segundo comando SOLO si el primero tiene exito
mkdir -p backups && echo "Directorio creado"

# || ejecuta el segundo comando SOLO si el primero falla
grep -q "error" log.txt || echo "No se encontraron errores"

# Combinacion comun: intentar algo y manejar el fallo
[ -f "archivo.txt" ] && cat archivo.txt || echo "Archivo no existe"
```

---

## Ejercicios

### [PRACTICA 4.1] Verificador de archivos
Crea `verificar.sh` que reciba una ruta como argumento y diga si es:
- Un archivo regular
- Un directorio
- No existe

```bash
$ ./verificar.sh /etc/passwd
/etc/passwd es un archivo regular

$ ./verificar.sh /home
/home es un directorio

$ ./verificar.sh /noexiste
/noexiste no existe
```

### [PRACTICA 4.2] Calculadora simple
Crea `calculadora.sh` que reciba tres argumentos: numero operador numero
```bash
$ ./calculadora.sh 10 + 5
Resultado: 15

$ ./calculadora.sh 20 / 4
Resultado: 5
```
Usa `case` para el operador (+, -, *, /).

### [PRACTICA 4.3] Procesador de archivos
Crea `procesar.sh` que:
1. Reciba un directorio como argumento
2. Liste todos los archivos `.txt` del directorio
3. Para cada uno, muestre su nombre y numero de lineas

### [PRACTICA 4.4] Menu interactivo
Crea `menu_practica.sh` con un menu que:
1. Muestre la fecha y hora
2. Muestre el espacio en disco
3. Liste los archivos del directorio actual
4. Salga del programa

Usa `while true` + `case` para mantener el menu activo.

---

## Resumen

| Estructura | Uso | Sintaxis clave |
|-----------|-----|----------------|
| `if/elif/else` | Decisiones | `if [ cond ]; then ... fi` |
| `case` | Seleccion multiple | `case "$var" in pat) ... esac` |
| `for` | Iterar sobre lista | `for x in lista; do ... done` |
| `while` | Repetir mientras verdadero | `while [ cond ]; do ... done` |
| `until` | Repetir hasta verdadero | `until [ cond ]; do ... done` |
| `break` | Salir del bucle | `break` |
| `continue` | Saltar iteracion | `continue` |
| `exit` | Terminar script | `exit 0` (exito) `exit 1` (error) |

**Siguiente leccion**: [05 - Funciones y Modularidad](05_Funciones_y_Modularidad.md)
