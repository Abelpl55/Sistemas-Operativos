# Leccion 15: Proyecto Final - Guia de Desarrollo

## Objetivo

Esta leccion te guia paso a paso para completar el proyecto SO-Finish.
Cada paso referencia las lecciones donde aprendiste los conceptos necesarios.

---

## Vision General del Proyecto

Eres un administrador de servidores Linux. Tu trabajo es:

1. **Respaldar** un sitio web automaticamente (backup + rotacion)
2. **Analizar** logs de acceso y errores para detectar amenazas
3. **Automatizar** tareas con cron
4. **Reportar** hallazgos en un documento profesional

### Estructura del Proyecto

```
SO-Finish/
├── scripts/          # Tus scripts (lo que debes completar)
│   ├── lib.sh        # Funciones compartidas
│   ├── setup.sh      # Inicializacion
│   ├── backup.sh     # Crear respaldos
│   ├── rotar_backups.sh  # Rotacion de respaldos
│   ├── analizar_access.sh  # Analisis de access.log
│   ├── analizar_error.sh   # Analisis de error.log
│   ├── reporte_final.sh    # Reporte consolidado
│   └── menu.sh       # Menu interactivo (bonus)
├── logs/             # Logs de servidor (datos de entrada)
├── sitio_web/        # Sitio web a respaldar
├── backups/          # Respaldos generados
├── reportes/         # Reportes generados
├── evidencia/        # Evidencia de ejecucion
└── config.conf       # Configuracion del proyecto
```

---

## Paso 0: Preparacion del Entorno

### Requisitos
- Ubuntu (nativo, VM o WSL2) — ver Leccion 01
- Terminal funcional — ver Leccion 02

### Obtener el proyecto

Descomprime el archivo del proyecto con `tar` y da permisos de ejecucion a los scripts con `chmod`.

### Leccion aplicada: Leccion 02 (comandos basicos), Leccion 09 (tar)

---

## Paso 1: Configurar config.conf

Abre `config.conf` con un editor de texto y cambia `STUDENT_ID` por tu numero de alumno real. Verifica que las demas variables de ruta (`SOURCE_DIR`, `BACKUP_DIR`, `LOG_DIR`, etc.) apunten a los directorios correctos del proyecto.

### Leccion aplicada: Leccion 03 (variables, source)

---

## Paso 2: Completar lib.sh

Este archivo contiene funciones que todos los demas scripts usan. Debes implementar las siguientes funciones:

| Funcion | Proposito | Pista |
|---------|-----------|-------|
| `load_config()` | Cargar `config.conf` usando `source`. Debe validar que el archivo existe antes de cargarlo. | Leccion 03 (source), Leccion 04 (test de archivo) |
| `ensure_dir()` | Recibe una ruta como parametro y crea el directorio si no existe. | Leccion 02 (`mkdir -p`), Leccion 04 (`[ -d ]`) |
| `now_stamp()` | Retorna la fecha y hora actual en formato `YYYY-MM-DD_HH-MM-SS`. | Leccion 03 (`date` con formato) |
| `log_line()` | Recibe un archivo y un mensaje. Escribe el mensaje con timestamp al archivo y tambien lo muestra en pantalla. | Leccion 07 (`tee -a`) |
| `require_file()` | Valida que un archivo existe. Si no, muestra error y termina el script. | Leccion 04 (`[ -f ]`) |
| `require_dir()` | Valida que un directorio existe. Si no, muestra error y termina el script. | Leccion 04 (`[ -d ]`) |

### Conceptos usados
- Funciones con `local` — Leccion 05
- Pruebas de archivo `[ -f ]`, `[ -d ]` — Leccion 04, 08
- `mkdir -p` — Leccion 02
- `date` con formato — Leccion 03
- `tee -a` — Leccion 07
- `source` — Leccion 03, 05

---

## Paso 3: Completar setup.sh

Este script inicializa la estructura del proyecto.

### Que debe hacer

1. Cargar `lib.sh` y `config.conf` (usando `source` y `load_config`)
2. Crear los directorios necesarios: backups, reportes, evidencia (usando `ensure_dir`)
3. Generar un archivo de evidencia `evidencia/setup_estructura.txt` que muestre:
   - Fecha, usuario y directorio de trabajo
   - Estructura de directorios del proyecto
   - Listado de scripts disponibles
   - Listado de logs disponibles

### Comandos utiles
- `find` para listar la estructura de directorios
- `ls -la` para listar archivos con detalle
- `tee` para escribir a archivo y mostrar en pantalla simultaneamente

### Verificacion
```bash
$ cat evidencia/setup_estructura.txt
$ ls backups/ reportes/ evidencia/
```

### Leccion aplicada: Leccion 05 (source, funciones), Leccion 07 (tee), Leccion 08 (directorios)

---

## Paso 4: Completar backup.sh

### Que debe hacer

1. Cargar la configuracion y validar que el directorio fuente (`SOURCE_DIR`) existe
2. Crear un archivo `.tar.gz` del sitio web con un nombre que incluya un timestamp (ej: `backup_sitio_web_2026-05-14_10-30-00.tar.gz`)
3. Documentar la ejecucion en `evidencia/backup_ejecucion.txt`: fecha, origen, destino, tamano del archivo y contenido del backup

### Comandos utiles
- `tar -czf` para crear el archivo comprimido
- `du -h` para obtener el tamano
- `tar -tzf` para listar el contenido sin descomprimir
- `cut` para extraer campos de la salida

### Verificacion
```bash
$ ls -lh backups/
$ cat evidencia/backup_ejecucion.txt
```

### Leccion aplicada: Leccion 09 (tar, backups), Leccion 03 (variables, date)

---

## Paso 5: Completar rotar_backups.sh

### Que debe hacer

1. Validar que `MAX_BACKUPS` es un numero positivo
2. Listar los backups existentes ordenados por fecha (mas nuevo primero)
3. Si hay mas de `MAX_BACKUPS`, eliminar los mas antiguos
4. Documentar en `evidencia/rotacion.txt` que archivos se conservaron y cuales se eliminaron

### Pistas
- `ls -1t` lista archivos ordenados por fecha de modificacion (mas nuevo primero)
- `tail -n +N` muestra desde la linea N en adelante (util para obtener los que exceden el limite)
- Un bucle `while read` puede procesar cada archivo a eliminar
- Redirige stderr a `/dev/null` con `2>/dev/null` para manejar el caso de que no haya backups

### Leccion aplicada: Leccion 08 (rotacion, ls -1t), Leccion 04 (while, if), Leccion 10 (regex para validar numero)

---

## Paso 6: Completar analizar_access.sh

Este es el script mas complejo. Debe generar un reporte con 8 secciones y guardarlo en `reportes/reporte_access.txt`.

### Las 8 secciones

| # | Seccion | Que debes encontrar | Pista |
|---|---------|---------------------|-------|
| 1 | Total de peticiones | Contar lineas del log | `wc -l` |
| 2 | Top 10 IPs | Las IPs que mas peticiones hacen | Extraer campo 1 con `awk`, luego `sort` &#124; `uniq -c` &#124; `sort -nr` |
| 3 | Codigos HTTP | Distribucion de codigos de respuesta (200, 404, 500...) | Extraer el campo del codigo con `awk`, luego contar |
| 4 | Rutas sensibles | Accesos a rutas como `/admin`, `/wp-login`, `/phpmyadmin`, etc. | `grep -iE` con patrones de rutas conocidas |
| 5 | User agents sospechosos | Herramientas como sqlmap, nikto, nmap, curl, etc. | `grep -iE` con nombres de herramientas de ataque |
| 6 | SQL Injection | Intentos con `SELECT`, `UNION`, `DROP`, `OR 1=1`, etc. | `grep -iE` con patrones comunes de SQLi |
| 7 | Path Traversal | Intentos con `../`, `/etc/passwd`, `/etc/shadow` | `grep -iE` con patrones de traversal |
| 8 | Conclusion | Resumen con conteos de cada tipo de amenaza detectada | Usa variables con los conteos de secciones anteriores |

### Estructura general

Tu script debe:
1. Cargar la configuracion y validar que `ACCESS_LOG` existe
2. Generar cada seccion con un encabezado claro
3. Enviar toda la salida a `reportes/reporte_access.txt` (y mostrarla en pantalla)

### Leccion aplicada: Leccion 06 (procesamiento de texto), Leccion 10 (regex), Leccion 11 (analisis de logs), Leccion 13 (seguridad)

---

## Paso 7: Completar analizar_error.sh

Similar al anterior pero para `error.log`. Debe generar un reporte con 7 secciones en `reportes/reporte_error.txt`.

### Las 7 secciones

| # | Seccion | Que debes detectar | Pista |
|---|---------|-------------------|-------|
| 1 | Total de errores | Contar lineas del log | `wc -l` |
| 2 | Access forbidden | Accesos denegados | `grep -c` con patron relevante |
| 3 | Permission denied | Permisos insuficientes | `grep -c` con patron relevante |
| 4 | File not found | Archivos o rutas inexistentes | `grep -cE` con patrones de archivos no encontrados |
| 5 | Upstream problems | Problemas con servidores upstream | `grep -ciE` con patrones de upstream |
| 6 | Top IPs en errores | Las IPs que mas errores generan | Extraer IPs con `grep -oE`, luego contar y ordenar |
| 7 | Conclusion | Resumen y significado de los hallazgos | Texto interpretativo basado en los datos |

### Pistas adicionales
- Para extraer IPs de texto libre, usa una expresion regular que capture el patron de direccion IP
- `sed` puede ayudar a limpiar caracteres extra alrededor de las IPs extraidas

### Leccion aplicada: Leccion 06 (sed, grep -o), Leccion 11 (error.log)

---

## Paso 8: Configurar Cron

Configura al menos 4 tareas programadas usando `crontab -e`:

| Tarea | Frecuencia sugerida |
|-------|-------------------|
| Backup | Diario |
| Rotacion de backups | Semanal |
| Analisis de access.log | Cada 6 horas |
| Analisis de error.log | Diario |

Recuerda:
- Cada entrada de cron debe usar `cd` para posicionarse en el directorio del proyecto antes de ejecutar el script
- Redirige stdout y stderr a un archivo de log para depuracion
- Guarda evidencia de tu configuracion:

```bash
$ crontab -l > evidencia/cron.txt
```

### Leccion aplicada: Leccion 12 (cron)

---

## Paso 9: Completar reporte_final.sh

Este script consolida todo en un archivo Markdown (`reportes/reporte_final.md`).

### Que debe hacer

1. Validar que los reportes previos y archivos de evidencia existen (usa `require_file`)
2. Generar un documento Markdown que incluya:
   - Informacion del alumno y fecha
   - Listado de backups generados
   - Resultado de la rotacion
   - Contenido del reporte de access.log
   - Contenido del reporte de error.log
   - Tabla con la configuracion de cron
   - Conclusiones tecnicas sobre los hallazgos

### Pistas
- Usa `cat` para incluir el contenido de los reportes previos
- Envuelve los datos en bloques de codigo Markdown (``` ```) para mejor formato
- Redirige toda la salida a `reportes/reporte_final.md`

### Leccion aplicada: Leccion 07 (redireccion), Leccion 11 (reportes)

---

## Paso 10 (Bonus): Completar menu.sh

El menu interactivo da puntos extra. Debe:
- Mostrar opciones con colores
- Ejecutar cada script individualmente
- Pedir confirmacion antes de operaciones destructivas
- Mostrar estado de archivos de evidencia

### Leccion aplicada: Leccion 04 (case, while), Leccion 14 (colores)

---

## Orden de Ejecucion

```bash
# 1. Configurar
$ nano config.conf                    # Cambiar STUDENT_ID

# 2. Preparar
$ chmod +x scripts/*.sh

# 3. Setup
$ ./scripts/setup.sh

# 4. Backups (ejecutar varias veces para tener multiples)
$ ./scripts/backup.sh
$ sleep 2 && ./scripts/backup.sh
$ sleep 2 && ./scripts/backup.sh

# 5. Rotacion
$ ./scripts/rotar_backups.sh

# 6. Analisis
$ ./scripts/analizar_access.sh
$ ./scripts/analizar_error.sh

# 7. Cron
$ crontab -e                          # Agregar tareas
$ crontab -l > evidencia/cron.txt

# 8. Reporte final
$ ./scripts/reporte_final.sh

# 9. Verificar todo
$ ls evidencia/
$ ls reportes/
$ ls backups/
```

---

## Checklist de Entrega

| Archivo | Verificacion |
|---------|-------------|
| `config.conf` | STUDENT_ID configurado |
| `scripts/lib.sh` | Todas las funciones implementadas |
| `scripts/setup.sh` | Genera `evidencia/setup_estructura.txt` |
| `scripts/backup.sh` | Genera `.tar.gz` y `evidencia/backup_ejecucion.txt` |
| `scripts/rotar_backups.sh` | Respeta MAX_BACKUPS, genera `evidencia/rotacion.txt` |
| `scripts/analizar_access.sh` | 8 secciones, genera `reportes/reporte_access.txt` |
| `scripts/analizar_error.sh` | 7 secciones, genera `reportes/reporte_error.txt` |
| `scripts/reporte_final.sh` | Genera `reportes/reporte_final.md` |
| `evidencia/cron.txt` | Minimo 4 tareas programadas |
| Sin TODOs | `grep -r "TODO" scripts/` no devuelve resultados |

### Crear entrega final

```bash
$ cd ..
$ tar -czf SO-Finish_TU_ID.tar.gz SO-Finish/
```

---

## Rubrica (100 puntos + 20 bonus)

| Categoria | Puntos |
|----------|--------|
| Configuracion y Setup | 10 |
| Backup | 15 |
| Rotacion | 10 |
| Cron | 10 |
| Analisis access.log | 20 |
| Analisis error.log | 15 |
| Reporte final | 10 |
| Evidencia | 5 |
| Calidad de codigo | 5 |
| **Total** | **100** |
| Bonus: Menu con colores | +10 |
| Bonus: Validaciones extra | +10 |

---

## Mapa de Lecciones por Paso

| Paso del proyecto | Lecciones a consultar |
|------------------|-----------------------|
| config.conf | 03 (variables, source) |
| lib.sh | 04 (condicionales), 05 (funciones) |
| setup.sh | 02 (comandos), 07 (tee), 08 (directorios) |
| backup.sh | 03 (date), 09 (tar) |
| rotar_backups.sh | 04 (while), 08 (rotacion), 10 (regex) |
| analizar_access.sh | 06 (texto), 10 (regex), 11 (logs), 13 (ataques) |
| analizar_error.sh | 06 (sed, grep -o), 11 (error.log) |
| cron | 12 (cron) |
| reporte_final.sh | 07 (redireccion), 11 (reportes) |
| menu.sh (bonus) | 04 (case), 14 (colores) |

Tienes todas las herramientas. Ahora a construir.
