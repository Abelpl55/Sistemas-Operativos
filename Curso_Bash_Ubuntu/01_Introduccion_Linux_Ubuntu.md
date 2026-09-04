# Leccion 01: Introduccion a Linux y Ubuntu

## Objetivos

- Entender que es Linux y su relacion con los sistemas operativos
- Conocer la estructura del sistema de archivos de Linux
- Instalar y configurar Ubuntu (o WSL2 en Windows)
- Comprender la diferencia entre kernel, shell y terminal

---

## 1.1 Que es Linux

Linux es un **kernel** (nucleo de sistema operativo) creado por Linus Torvalds en 1991.
Es software libre y de codigo abierto, lo que significa que cualquiera puede verlo,
modificarlo y distribuirlo.

Cuando hablamos de "Linux" en general, nos referimos a un **sistema operativo GNU/Linux**,
que combina:

- **Kernel Linux**: Gestiona hardware, memoria, procesos y dispositivos
- **Herramientas GNU**: Utilidades de linea de comandos (ls, cp, grep, etc.)
- **Shell**: Interprete de comandos (bash, zsh, etc.)
- **Entorno grafico** (opcional): GNOME, KDE, XFCE, etc.

### Por que Linux es importante en Sistemas Operativos

- Es el SO dominante en **servidores** (mas del 90% de Internet)
- Ejecuta **Android**, supercomputadoras y dispositivos IoT
- Permite entender conceptos de SO de forma directa: procesos, permisos, filesystem
- Es la base de **DevOps**, cloud computing y ciberseguridad

## 1.2 Distribuciones Linux

Una **distribucion** (distro) es Linux empaquetado con software adicional:

| Distribucion | Base | Uso Principal |
|-------------|------|---------------|
| **Ubuntu** | Debian | Escritorio y servidores |
| Debian | - | Servidores (estabilidad) |
| Fedora | Red Hat | Desarrollo |
| CentOS/Rocky | Red Hat | Servidores empresariales |
| Arch Linux | - | Usuarios avanzados |
| Kali Linux | Debian | Seguridad/pentesting |

Usaremos **Ubuntu** por su facilidad de uso y amplia documentacion.

## 1.3 Instalacion de Ubuntu

### Opcion A: Maquina Virtual (VirtualBox/VMware)

1. Descarga Ubuntu Desktop desde https://ubuntu.com/download/desktop
2. Instala VirtualBox desde https://www.virtualbox.org/
3. Crea una nueva maquina virtual:
   - Tipo: Linux
   - Version: Ubuntu (64-bit)
   - RAM: minimo 2 GB (recomendado 4 GB)
   - Disco: minimo 25 GB
4. Monta la ISO y sigue el asistente de instalacion

### Opcion B: WSL2 en Windows (Recomendada para usuarios Windows)

WSL2 (Windows Subsystem for Linux) permite ejecutar Linux dentro de Windows:

```bash
# Abre PowerShell como Administrador y ejecuta:
wsl --install -d Ubuntu

# Reinicia tu computadora
# Al abrir Ubuntu, configura usuario y contrasena
```

Verificacion despues de instalar:

```bash
$ lsb_release -a
# Deberia mostrar: Ubuntu 22.04 o superior

$ uname -r
# Muestra la version del kernel

$ bash --version
# Muestra la version de Bash
```

### Opcion C: Dual Boot

Instalar Ubuntu junto a Windows en el disco duro. Solo recomendado si tienes
experiencia previa, ya que un error puede afectar tu sistema Windows.

## 1.4 Estructura del Sistema de Archivos

Linux organiza todo en una **jerarquia de directorios** desde la raiz `/`:

```
/                  # Raiz (root) del sistema
├── bin/           # Binarios esenciales (ls, cp, bash)
├── boot/          # Archivos de arranque del kernel
├── dev/           # Dispositivos (disco, USB, terminal)
├── etc/           # Archivos de configuracion del sistema
├── home/          # Directorios personales de usuarios
│   └── alumno/    # Tu directorio personal
├── lib/           # Librerias compartidas
├── media/         # Dispositivos montados (USB, CD)
├── mnt/           # Punto de montaje manual
├── opt/           # Software adicional
├── proc/          # Info de procesos en ejecucion (virtual)
├── root/          # Home del superusuario
├── sbin/          # Binarios del sistema (solo root)
├── tmp/           # Archivos temporales
├── usr/           # Programas y utilidades del usuario
│   ├── bin/       # Binarios del usuario
│   ├── lib/       # Librerias
│   └── share/     # Datos compartidos
└── var/           # Datos variables
    ├── log/       # Archivos de log del sistema
    └── www/       # Archivos web (en servidores)
```

### Directorios clave para el proyecto

| Directorio | Relevancia |
|-----------|------------|
| `/home/usuario/` | Donde trabajaras y guardaras el proyecto |
| `/var/log/` | Donde estan los logs reales del sistema |
| `/etc/crontab` | Configuracion de tareas programadas |
| `/tmp/` | Archivos temporales (se borran al reiniciar) |

## 1.5 Kernel, Shell y Terminal

Estos tres conceptos son diferentes pero trabajan juntos:

```
+------------------+
|   Aplicaciones   |  (Firefox, VS Code, etc.)
+------------------+
|      Shell       |  (Bash - interpreta tus comandos)
+------------------+
|     Kernel       |  (Linux - gestiona el hardware)
+------------------+
|    Hardware      |  (CPU, RAM, disco, red)
+------------------+
```

- **Kernel**: Nucleo del SO, gestiona memoria, procesos, dispositivos
- **Shell**: Programa que lee tus comandos y los ejecuta (Bash es el mas comun)
- **Terminal**: Aplicacion grafica que muestra el shell (como GNOME Terminal)

### Bash (Bourne Again Shell)

Bash es el shell por defecto en Ubuntu. Cuando abres una terminal, estas usando Bash.

```bash
# Ver que shell estas usando
$ echo $SHELL
/bin/bash

# Ver la version de Bash
$ bash --version
GNU bash, version 5.1.16(1)-release
```

## 1.6 El Superusuario (root)

Linux tiene un sistema de **permisos** basado en usuarios:

- **root**: Superusuario con acceso total al sistema
- **Usuarios normales**: Acceso limitado a su directorio home

Para ejecutar comandos como root se usa `sudo` (Super User DO):

```bash
# Comando normal (como tu usuario)
$ ls /home

# Comando como superusuario
$ sudo apt update
[sudo] password for alumno: ********
```

**Regla de oro**: Nunca trabajes como root permanentemente. Usa `sudo` solo cuando
sea necesario.

## 1.7 Gestion de Paquetes con APT

Ubuntu usa **APT** (Advanced Package Tool) para instalar software:

```bash
# Actualizar lista de paquetes disponibles
$ sudo apt update

# Actualizar paquetes instalados
$ sudo apt upgrade

# Instalar un paquete nuevo
$ sudo apt install nombre_paquete

# Buscar un paquete
$ apt search nombre

# Eliminar un paquete
$ sudo apt remove nombre_paquete

# Ver paquetes instalados
$ dpkg -l | grep nombre
```

### Paquetes utiles para el curso

```bash
$ sudo apt install -y git curl wget tree nano vim
```

- **git**: Control de versiones
- **curl/wget**: Descarga de archivos desde la red
- **tree**: Muestra directorios en forma de arbol
- **nano**: Editor de texto simple en terminal
- **vim**: Editor de texto avanzado en terminal

---

## Ejercicios

### [PRACTICA 1.1] Verifica tu instalacion
Ejecuta estos comandos y anota la salida:
```bash
$ uname -a
$ lsb_release -a
$ bash --version
$ whoami
$ echo $HOME
```

### [PRACTICA 1.2] Explora el sistema de archivos
```bash
$ ls /
$ ls /home
$ ls /var/log
$ ls /etc
```

### [PRACTICA 1.3] Instala herramientas
```bash
$ sudo apt update
$ sudo apt install -y tree nano curl
$ tree --version
```

### [PRACTICA 1.4] Responde las preguntas
1. Cual es la diferencia entre kernel y shell?
2. Para que sirve el directorio `/var/log/`?
3. Por que no se debe trabajar como root permanentemente?
4. Que comando usas para instalar software en Ubuntu?

---

## Resumen

| Concepto | Descripcion |
|----------|-------------|
| Linux | Kernel de SO libre y de codigo abierto |
| Ubuntu | Distribucion basada en Debian, facil de usar |
| Shell (Bash) | Interprete de comandos |
| Terminal | Aplicacion que muestra el shell |
| root / sudo | Superusuario / ejecutar como superusuario |
| APT | Gestor de paquetes de Ubuntu |
| / | Raiz del sistema de archivos |
| /home | Directorios personales |

**Siguiente leccion**: [02 - La Terminal y Comandos Basicos](02_Terminal_Comandos_Basicos.md)
