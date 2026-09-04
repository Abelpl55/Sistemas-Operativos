# Leccion 02: La Terminal y Comandos Basicos

## Objetivos

- Dominar la navegacion por el sistema de archivos desde la terminal
- Crear, copiar, mover y eliminar archivos y directorios
- Entender y modificar permisos de archivos
- Usar el manual del sistema y atajos de teclado

---

## 2.1 Abrir la Terminal

- **Ubuntu Desktop**: Ctrl + Alt + T
- **WSL2**: Buscar "Ubuntu" en el menu de inicio de Windows
- **Desde el explorador de archivos**: Click derecho > "Abrir terminal aqui"

### El Prompt

Al abrir la terminal veras algo como:

```
alumno@ubuntu:~$
```

| Parte | Significado |
|-------|-------------|
| `alumno` | Tu nombre de usuario |
| `@ubuntu` | Nombre de la maquina |
| `~` | Directorio actual (~ = home) |
| `$` | Usuario normal (# = root) |

## 2.2 Navegacion por Directorios

### pwd - Donde estoy

```bash
$ pwd
/home/alumno
```

### ls - Que hay aqui

```bash
# Listar archivos
$ ls

# Listar con detalles (permisos, tamano, fecha)
$ ls -l

# Incluir archivos ocultos (empiezan con .)
$ ls -la

# Listar con tamanos legibles
$ ls -lh

# Un archivo por linea
$ ls -1

# Ordenar por fecha de modificacion (mas nuevo primero)
$ ls -lt

# Ordenar por fecha (mas nuevo primero), uno por linea
$ ls -1t
```

Ejemplo de salida de `ls -l`:

```
-rw-r--r-- 1 alumno alumno 4096 may 14 10:30 archivo.txt
drwxr-xr-x 2 alumno alumno 4096 may 14 10:30 carpeta/
```

| Campo | Significado |
|-------|-------------|
| `-rw-r--r--` | Permisos (tipo + rwx para dueno, grupo, otros) |
| `1` | Numero de enlaces |
| `alumno` | Dueno del archivo |
| `alumno` | Grupo del archivo |
| `4096` | Tamano en bytes |
| `may 14 10:30` | Fecha de modificacion |
| `archivo.txt` | Nombre |

### cd - Cambiar directorio

```bash
# Ir a un directorio
$ cd /var/log

# Ir al directorio home
$ cd ~
$ cd          # Tambien funciona sin argumentos

# Subir un nivel
$ cd ..

# Subir dos niveles
$ cd ../..

# Ir al directorio anterior
$ cd -

# Ruta absoluta (desde la raiz)
$ cd /home/alumno/Documentos

# Ruta relativa (desde donde estoy)
$ cd Documentos
```

### Rutas Absolutas vs Relativas

```
/home/alumno/proyecto/scripts/backup.sh    <- Ruta ABSOLUTA (desde /)
./scripts/backup.sh                        <- Ruta RELATIVA (desde proyecto/)
../otro_proyecto/archivo.txt               <- Ruta RELATIVA (subir y bajar)
```

- **Absoluta**: Siempre empieza con `/`, funciona desde cualquier lugar
- **Relativa**: Depende de donde te encuentres actualmente

## 2.3 Crear Archivos y Directorios

### touch - Crear archivo vacio

```bash
$ touch archivo.txt
$ touch script.sh notas.md datos.csv    # Varios a la vez
```

### mkdir - Crear directorio

```bash
# Crear un directorio
$ mkdir mi_carpeta

# Crear directorios anidados (con -p crea los padres si no existen)
$ mkdir -p proyecto/scripts/lib
$ mkdir -p backups reportes evidencia    # Varios a la vez
```

**Importante**: `mkdir -p` es esencial en scripting porque no da error si el
directorio ya existe. Lo usaras mucho en el proyecto.

### Editores de texto en terminal

```bash
# Nano - Editor simple (recomendado para principiantes)
$ nano archivo.txt
# Ctrl+O para guardar, Ctrl+X para salir

# Vim - Editor avanzado
$ vim archivo.txt
# Presiona 'i' para insertar texto
# Presiona Esc, luego :wq para guardar y salir
```

## 2.4 Copiar, Mover y Eliminar

### cp - Copiar

```bash
# Copiar archivo
$ cp origen.txt destino.txt

# Copiar archivo a un directorio
$ cp archivo.txt /home/alumno/respaldo/

# Copiar directorio completo (recursivo)
$ cp -r carpeta_origen/ carpeta_destino/
```

### mv - Mover o Renombrar

```bash
# Mover archivo a otro directorio
$ mv archivo.txt /home/alumno/carpeta/

# Renombrar archivo (mover al mismo lugar con otro nombre)
$ mv nombre_viejo.txt nombre_nuevo.txt

# Mover directorio
$ mv carpeta/ /otra/ubicacion/
```

### rm - Eliminar

```bash
# Eliminar archivo
$ rm archivo.txt

# Eliminar sin preguntar
$ rm -f archivo.txt

# Eliminar directorio y todo su contenido
$ rm -r carpeta/

# Eliminar directorio sin preguntar
$ rm -rf carpeta/
```

**CUIDADO**: `rm -rf` es irreversible. No hay papelera de reciclaje en la terminal.
Nunca ejecutes `rm -rf /` ni `rm -rf ~`.

## 2.5 Ver Contenido de Archivos

```bash
# Mostrar todo el contenido
$ cat archivo.txt

# Mostrar con numeros de linea
$ cat -n archivo.txt

# Ver las primeras lineas
$ head archivo.txt          # Primeras 10 lineas
$ head -20 archivo.txt      # Primeras 20 lineas

# Ver las ultimas lineas
$ tail archivo.txt          # Ultimas 10 lineas
$ tail -20 archivo.txt      # Ultimas 20 lineas
$ tail -f /var/log/syslog   # Seguir en tiempo real (Ctrl+C para salir)

# Paginar contenido (para archivos largos)
$ less archivo.txt
# Usa: flechas para navegar, 'q' para salir, '/' para buscar

# Contar lineas, palabras y caracteres
$ wc archivo.txt
#   150   890  6234 archivo.txt
#   lineas palabras bytes

# Solo contar lineas
$ wc -l archivo.txt
```

## 2.6 Buscar Archivos y Contenido

### find - Buscar archivos por nombre o tipo

```bash
# Buscar archivos por nombre
$ find . -name "*.sh"

# Buscar en un directorio especifico
$ find /home/alumno -name "backup*"

# Buscar solo directorios
$ find . -type d

# Buscar solo archivos
$ find . -type f

# Buscar con profundidad limitada
$ find . -maxdepth 2 -type f -name "*.log"
```

### grep - Buscar contenido dentro de archivos

```bash
# Buscar texto en un archivo
$ grep "error" archivo.log

# Buscar ignorando mayusculas/minusculas
$ grep -i "error" archivo.log

# Buscar en todos los archivos de un directorio
$ grep -r "patron" directorio/

# Contar coincidencias
$ grep -c "error" archivo.log

# Mostrar numero de linea
$ grep -n "error" archivo.log
```

(grep se cubrira en profundidad en la Leccion 06)

## 2.7 Permisos de Archivos

Linux usa un sistema de permisos con tres niveles:

```
-rwxr-xr-- 1 alumno grupo archivo.sh
 |||||||||||
 |└┬┘└┬┘└┬┘
 | |  |  └── Otros (o): r-- (solo lectura)
 | |  └───── Grupo (g): r-x (lectura y ejecucion)
 | └──────── Dueno (u): rwx (lectura, escritura, ejecucion)
 └────────── Tipo: - (archivo), d (directorio), l (enlace)
```

| Permiso | Letra | Numero | Significado |
|---------|-------|--------|-------------|
| Lectura | r | 4 | Ver contenido |
| Escritura | w | 2 | Modificar contenido |
| Ejecucion | x | 1 | Ejecutar como programa |

### chmod - Cambiar permisos

```bash
# Forma simbolica
$ chmod +x script.sh        # Agregar ejecucion para todos
$ chmod u+x script.sh       # Agregar ejecucion solo al dueno
$ chmod go-w archivo.txt     # Quitar escritura a grupo y otros

# Forma octal (numeros)
$ chmod 755 script.sh        # rwxr-xr-x (dueno: todo, otros: leer/ejecutar)
$ chmod 644 archivo.txt      # rw-r--r-- (dueno: leer/escribir, otros: solo leer)
$ chmod 700 privado.sh       # rwx------ (solo el dueno tiene acceso)
```

### Tabla de permisos octales comunes

| Octal | Permisos | Uso tipico |
|-------|----------|------------|
| `755` | rwxr-xr-x | Scripts ejecutables |
| `644` | rw-r--r-- | Archivos de texto |
| `700` | rwx------ | Scripts privados |
| `600` | rw------- | Archivos sensibles |

**Para el proyecto**: Todos los scripts `.sh` necesitan permiso de ejecucion:

```bash
$ chmod +x scripts/*.sh
```

## 2.8 Otros Comandos Utiles

```bash
# Mostrar el arbol de directorios
$ tree
$ tree -L 2            # Limitar a 2 niveles

# Espacio en disco
$ df -h                # Particiones del disco
$ du -h archivo        # Tamano de un archivo
$ du -sh carpeta/      # Tamano total de una carpeta

# Informacion del sistema
$ uname -a             # Info del kernel
$ whoami               # Tu usuario
$ hostname             # Nombre de la maquina
$ date                 # Fecha y hora actual
$ uptime               # Tiempo que lleva encendido

# Historial de comandos
$ history              # Ver comandos anteriores
$ !!                   # Repetir ultimo comando
$ !grep                # Repetir ultimo comando que empieza con "grep"

# Limpiar pantalla
$ clear                # O usa Ctrl + L
```

## 2.9 Atajos de Teclado en la Terminal

| Atajo | Accion |
|-------|--------|
| `Ctrl + C` | Cancelar comando en ejecucion |
| `Ctrl + Z` | Suspender comando (enviar a background) |
| `Ctrl + D` | Cerrar la terminal (EOF) |
| `Ctrl + L` | Limpiar pantalla |
| `Ctrl + A` | Ir al inicio de la linea |
| `Ctrl + E` | Ir al final de la linea |
| `Ctrl + W` | Borrar palabra anterior |
| `Ctrl + R` | Buscar en el historial |
| `Tab` | Autocompletar nombres de archivos/comandos |
| `Tab Tab` | Mostrar todas las opciones de autocompletado |
| `Flecha arriba/abajo` | Navegar por el historial |

## 2.10 El Manual: man

Cada comando tiene su manual integrado:

```bash
$ man ls          # Manual de ls
$ man grep        # Manual de grep
$ man bash        # Manual completo de Bash

# Dentro de man:
# - Flechas: navegar
# - /patron: buscar
# - q: salir
```

Alternativa rapida:

```bash
$ ls --help       # Ayuda resumida
$ grep --help
```

---

## Ejercicios

### [PRACTICA 2.1] Navegacion basica
```bash
# Crea esta estructura de directorios:
# ~/practica/
# ├── documentos/
# ├── scripts/
# └── datos/
#     ├── entrada/
#     └── salida/

$ mkdir -p ~/practica/documentos ~/practica/scripts ~/practica/datos/entrada ~/practica/datos/salida
$ tree ~/practica
```

### [PRACTICA 2.2] Manipulacion de archivos
```bash
$ cd ~/practica
$ touch documentos/notas.txt scripts/mi_script.sh datos/entrada/data.csv
$ echo "Hola mundo" > documentos/notas.txt
$ cp documentos/notas.txt datos/salida/copia.txt
$ mv datos/salida/copia.txt datos/salida/resultado.txt
$ cat datos/salida/resultado.txt
```

### [PRACTICA 2.3] Permisos
```bash
$ ls -l scripts/mi_script.sh
# Observa: no tiene permiso de ejecucion

$ chmod +x scripts/mi_script.sh
$ ls -l scripts/mi_script.sh
# Ahora deberia mostrar 'x' en los permisos
```

### [PRACTICA 2.4] Explora el sistema
Responde usando comandos:
1. Cuantos archivos hay en `/etc/`? (usa `ls | wc -l`)
2. Cual es tu directorio home? (usa `echo $HOME`)
3. Que usuario eres? (usa `whoami`)
4. Cual es la fecha actual? (usa `date`)

---

## Resumen

| Comando | Funcion | Ejemplo |
|---------|---------|---------|
| `pwd` | Directorio actual | `pwd` |
| `ls` | Listar archivos | `ls -la` |
| `cd` | Cambiar directorio | `cd ~/proyecto` |
| `mkdir` | Crear directorio | `mkdir -p dir/subdir` |
| `touch` | Crear archivo vacio | `touch file.txt` |
| `cp` | Copiar | `cp -r origen/ destino/` |
| `mv` | Mover/renombrar | `mv viejo.txt nuevo.txt` |
| `rm` | Eliminar | `rm -r carpeta/` |
| `cat` | Ver contenido | `cat archivo.txt` |
| `head/tail` | Ver inicio/final | `head -20 archivo.txt` |
| `chmod` | Cambiar permisos | `chmod +x script.sh` |
| `find` | Buscar archivos | `find . -name "*.sh"` |
| `grep` | Buscar contenido | `grep "texto" archivo` |
| `man` | Manual | `man comando` |

**Siguiente leccion**: [03 - Variables y Entrada de Datos](03_Variables_y_Entrada.md)
