# Starter — Proyecto Final de Sistemas Operativos
## Automatización, respaldos, cron y análisis de logs web con Bash

Este paquete es un **starter para alumnos**. No está completamente resuelto: contiene estructura, logs realistas, scripts base y `TODOs` numerados que deben completarse.

---

## 1. Objetivo del proyecto

Construir un sistema Bash que permita:

1. Crear evidencia del entorno de trabajo.
2. Generar respaldos comprimidos de una carpeta web simulada.
3. Rotar respaldos conservando solo los más recientes.
4. Analizar `access.log` para detectar actividad normal y sospechosa.
5. Analizar `error.log` para identificar errores relevantes del servidor.
6. Programar tareas automáticas con `cron`.
7. Generar un reporte final en Markdown.

---

## 2. Estructura del paquete

```text
SO-starter/
├── scripts/
│   ├── lib.sh
│   ├── setup.sh
│   ├── backup.sh
│   ├── rotar_backups.sh
│   ├── analizar_access.sh
│   ├── analizar_error.sh
│   ├── reporte_final.sh
│   └── menu.sh
├── logs/
│   ├── access.log
│   ├── error.log
│   └── README_LOGS.md
├── sitio_web/
├── datos_empresa/
├── backups/
├── evidencia/
├── reportes/
├── config.conf
├── ALUMNOS.md
├── INSTRUCCIONES_PROYECTO.md
├── RUBRICA.md
└── Verificacion.md
```

---

## 3. Primeros pasos

### Paso 1. Descomprimir el paquete

```bash
unzip SO-starter.zip
cd SO-starter
```

### Paso 2. Dar permisos de ejecución

```bash
chmod +x scripts/*.sh
```

### Paso 3. Ejecutar el setup

```bash
./scripts/setup.sh
```

### Paso 4. Revisar los TODOs

Busca los TODOs con:

```bash
grep -R "TODO-" scripts/ README.md INSTRUCCIONES_PROYECTO.md
```

---

## 4. Archivos que debes modificar

Los archivos principales a completar son:

| Archivo | Propósito |
|---|---|
| `scripts/backup.sh` | Crear respaldos `.tar.gz` |
| `scripts/rotar_backups.sh` | Eliminar respaldos antiguos |
| `scripts/analizar_access.sh` | Analizar accesos web |
| `scripts/analizar_error.sh` | Analizar errores del servidor |
| `scripts/reporte_final.sh` | Consolidar reporte final |
| `config.conf` | Ajustar variables del proyecto |

---

## 5. Orden sugerido de trabajo

1. Ejecuta `setup.sh`.
2. Revisa `config.conf`.
3. Completa `backup.sh`.
4. Completa `rotar_backups.sh`.
5. Completa `analizar_access.sh`.
6. Completa `analizar_error.sh`.
7. Completa `reporte_final.sh`.
8. Configura `cron`.
9. Comprime el proyecto final.

---

## 6. Evidencias esperadas

Debes generar evidencias en:

```text
evidencia/
reportes/
backups/
```

Ejemplos:

```text
evidencia/setup_estructura.txt
evidencia/backup_ejecucion.txt
evidencia/rotacion.txt
evidencia/cron.txt
reportes/reporte_access.txt
reportes/reporte_error.txt
reportes/reporte_final.md
```

---

## 7. Comandos esperados

Durante el proyecto deberás usar comandos como:

```bash
grep
awk
cut
sort
uniq
head
tail
wc
find
tar
chmod
tee
date
crontab
```

---

## 8. Restricciones

1. No modificar los archivos originales `logs/access.log` y `logs/error.log`.
2. No usar Python, Node.js ni herramientas externas para resolver el análisis.
3. Todo el procesamiento debe hacerse con Bash y comandos de Linux.
4. Los scripts deben ejecutarse desde la raíz del proyecto.

---

## 9. Entrega final

Entrega un archivo con el siguiente formato:

```text
proyecto_final_so_NOMBREEQUIPO.tar.gz
```

Ejemplo:

```bash
tar -czf proyecto_final_so_COBRA_REAL.tar.gz SO-starter
```
