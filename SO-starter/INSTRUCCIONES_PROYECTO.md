# Proyecto Final — Sistemas Operativos
## Automatización y análisis de seguridad en Linux con Bash

**Modalidad:** Equipo 3 personas - Nombre equipo  
**Duración sugerida:** 2 a 3 semanas  
**Entrega:** carpeta comprimida `.tar.gz`

---

## 1. Contexto del proyecto

Simularás ser administrador de un servidor Linux. Tu tarea será completar un sistema Bash para respaldar archivos, rotar respaldos, analizar logs web y generar evidencia técnica.

El paquete incluye un starter con scripts incompletos. Cada archivo contiene marcas `TODO-XX` que debes resolver.

---

## 2. Pasos obligatorios

### Paso 1. Preparar el proyecto

```bash
unzip SO-starter.zip
cd SO-starter
chmod +x scripts/*.sh
./scripts/setup.sh
```

Evidencia esperada:

```text
evidencia/setup_estructura.txt
```

---

### Paso 2. Revisar configuración

Abre:

```text
config.conf
```

Completa:

- `STUDENT_ID`
- rutas si fuera necesario
- `MAX_BACKUPS`

TODO relacionado:

```text
TODO-00
TODO-00A
```

---

### Paso 3. Completar respaldo

Archivo:

```text
scripts/backup.sh
```

Debes resolver:

```text
TODO-03 a TODO-08
```

El script debe:

1. Validar carpeta origen.
2. Crear timestamp.
3. Crear nombre del `.tar.gz`.
4. Ejecutar `tar`.
5. Guardar evidencia.

Evidencia esperada:

```text
evidencia/backup_ejecucion.txt
backups/backup_*.tar.gz
```

---

### Paso 4. Completar rotación de respaldos

Archivo:

```text
scripts/rotar_backups.sh
```

Debes resolver:

```text
TODO-09 a TODO-13
```

El script debe conservar solo los últimos `MAX_BACKUPS` respaldos.

Evidencia esperada:

```text
evidencia/rotacion.txt
```

---

### Paso 5. Completar análisis de access.log

Archivo:

```text
scripts/analizar_access.sh
```

Debes resolver:

```text
TODO-14 a TODO-21
```

Debe generar:

```text
reportes/reporte_access.txt
```

Debe incluir:

1. Total de líneas.
2. Top IPs.
3. Códigos HTTP frecuentes.
4. Rutas sensibles.
5. User agents sospechosos.
6. Posibles SQL Injection.
7. Posible path traversal.
8. Conclusión breve.

---

### Paso 6. Completar análisis de error.log

Archivo:

```text
scripts/analizar_error.sh
```

Debes resolver:

```text
TODO-22 a TODO-28
```

Debe generar:

```text
reportes/reporte_error.txt
```

Debe incluir:

1. Total de líneas.
2. Eventos `access forbidden`.
3. Eventos `permission denied`.
4. Archivos/rutas inexistentes.
5. Problemas de upstream.
6. IPs más frecuentes en errores.
7. Conclusión breve.

---

### Paso 7. Configurar cron

Debes programar tareas automáticas con `crontab -e`.

Ejemplo base, ajústalo con tu ruta real:

```cron
0 22 * * * /RUTA/ABSOLUTA/SO-starter/scripts/backup.sh
0 23 * * 5 /RUTA/ABSOLUTA/SO-starter/scripts/rotar_backups.sh
30 23 * * * /RUTA/ABSOLUTA/SO-starter/scripts/analizar_access.sh
40 23 * * * /RUTA/ABSOLUTA/SO-starter/scripts/analizar_error.sh
```

Guarda evidencia:

```bash
crontab -l > evidencia/cron.txt
```

---

### Paso 8. Completar reporte final

Archivo:

```text
scripts/reporte_final.sh
```

Debes resolver:

```text
TODO-29 a TODO-35
```

Debe generar:

```text
reportes/reporte_final.md
```

---

### Paso 9. Opcional: menú interactivo

Archivo:

```text
scripts/menu.sh
```

TODO relacionado:

```text
TODO-36
```

Este archivo puede usarse como mejora para puntos extra.

---

## 3. Comandos esperados

Se espera el uso de:

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
cat
echo
date
crontab
```

---

## 4. Restricciones

1. No uses Python, Node.js, Excel ni herramientas externas para analizar los logs.
2. No edites `logs/access.log` ni `logs/error.log`.
3. No borres evidencias.
4. Ejecuta scripts desde la raíz del proyecto.
5. Documenta decisiones importantes.

---

## 5. Entrega final

Genera:

```bash
tar -czf proyecto_final_so_IDALUMNO.tar.gz SO-starter
```

El `.tar.gz` debe incluir:

```text
scripts/
logs/
backups/
reportes/
evidencia/
config.conf
README.md
INSTRUCCIONES_PROYECTO.md
RUBRICA.md
```
