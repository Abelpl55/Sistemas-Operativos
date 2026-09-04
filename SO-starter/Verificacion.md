# Guia de Verificacion — Proyecto Final SO

Esta guia permite verificar paso a paso que el proyecto fue completado correctamente.
Ejecuta cada comando **desde la raiz del proyecto** (`cd SO-starter`).

---

## Paso 0: Prerequisitos

Antes de verificar, asegurate de estar en el directorio correcto.

```bash
cd SO-starter
```

### 0.1 Verificar que no quedan TODOs sin resolver

```bash
grep -rn "TODO.*pendiente\|TODO: " scripts/ config.conf
```

**Esperado:** Sin resultados (ningun TODO pendiente). Si aparecen lineas, esos TODOs aun no se completaron.

### 0.2 Verificar que los scripts tienen permisos de ejecucion

```bash
ls -l scripts/*.sh | awk '{print $1, $NF}'
```

**Esperado:** Todos deben mostrar `x` en los permisos (ej: `-rwxr-xr-x`). Si no:

```bash
chmod +x scripts/*.sh
```

---

## Paso 1: Configuracion inicial (10 pts)

### 1.1 Verificar config.conf

```bash
source ./config.conf
echo "STUDENT_ID=$STUDENT_ID"
echo "MAX_BACKUPS=$MAX_BACKUPS"
echo "SOURCE_DIR=$SOURCE_DIR"
```

**Esperado:**
- `STUDENT_ID` debe ser distinto de `"ID_ALUMNO"` (debe tener el NOMBRE DEL EQUIPO).
- `MAX_BACKUPS` debe ser un numero mayor que 0.
- `SOURCE_DIR` debe apuntar a un directorio que exista (`./sitio_web`).

### 1.2 Ejecutar setup.sh

```bash
./scripts/setup.sh
```

**Esperado:** Termina sin errores y muestra la estructura del proyecto.

### 1.3 Verificar evidencia de setup

```bash
cat evidencia/setup_estructura.txt
```

**Esperado:** Archivo existente con fecha, usuario, estructura de directorios y lista de scripts.

---

## Paso 2: Respaldo (15 pts)

### 2.1 Ejecutar backup.sh

```bash
./scripts/backup.sh
```

**Esperado:** Termina sin errores y muestra mensaje de confirmacion con el nombre del archivo generado.

### 2.2 Verificar archivo de respaldo

```bash
ls -lh backups/backup_*.tar.gz
```

**Esperado:** Al menos un archivo `.tar.gz` con tamano mayor a 0 bytes.

### 2.3 Verificar contenido del respaldo

```bash
tar -tzf backups/backup_*.tar.gz | head -10
```

**Esperado:** Listado de archivos que incluye contenido de `./sitio_web/`.

### 2.4 Verificar evidencia de backup

```bash
cat evidencia/backup_ejecucion.txt
```

**Esperado:** Archivo con fecha, SOURCE_DIR, archivo generado y tamano.

---

## Paso 3: Rotacion de respaldos (10 pts)

Para probar la rotacion correctamente, primero genera varios respaldos:

```bash
./scripts/backup.sh
sleep 2
./scripts/backup.sh
sleep 2
./scripts/backup.sh
sleep 2
./scripts/backup.sh
sleep 2
./scripts/backup.sh
sleep 2
./scripts/backup.sh
```

Esto crea 6+ respaldos (mas que MAX_BACKUPS=5).

### 3.1 Ejecutar rotar_backups.sh

```bash
./scripts/rotar_backups.sh
```

**Esperado:** Termina sin errores y muestra que respaldos se conservaron y cuales se eliminaron.

### 3.2 Verificar que se respeta MAX_BACKUPS

```bash
ls -1t backups/backup_*.tar.gz | wc -l
```

**Esperado:** El numero debe ser igual o menor a `MAX_BACKUPS` (5 por defecto).

### 3.3 Verificar evidencia de rotacion

```bash
cat evidencia/rotacion.txt
```

**Esperado:** Archivo con fecha, lista de conservados y lista de eliminados.

---

## Paso 4: Analisis de access.log (20 pts)

### 4.1 Ejecutar analizar_access.sh

```bash
./scripts/analizar_access.sh
```

**Esperado:** Termina sin errores y muestra el reporte completo en pantalla.

### 4.2 Verificar que el reporte existe

```bash
test -f reportes/reporte_access.txt && echo "OK" || echo "FALTA"
```

### 4.3 Verificar las 8 secciones del reporte

```bash
grep -c "^[0-9])" reportes/reporte_access.txt
```

**Esperado:** `8` (las 8 secciones numeradas).

### 4.4 Verificar contenido especifico de cada seccion

**Total de lineas:**
```bash
grep -A1 "1) Total" reportes/reporte_access.txt
```
Esperado: Un numero (1354 lineas en el log actual).

**Top IPs:**
```bash
grep -A12 "2) Top 10" reportes/reporte_access.txt
```
Esperado: Lista con conteo e IPs, ordenada de mayor a menor.

**Codigos HTTP:**
```bash
grep -A8 "3) Codigos" reportes/reporte_access.txt
```
Esperado: Codigos como 200, 404, 403, 500, 301, 304, 401 con conteos.

**Rutas sensibles:**
```bash
grep -c "sensibles" reportes/reporte_access.txt
```
Esperado: Al menos 1 (el encabezado). Debe haber lineas con `/admin`, `/.env`, `/phpmyadmin`, etc.

**User agents sospechosos:**
```bash
grep -ciE "sqlmap|Nikto|curl|masscan|python-requests|Go-http-client" reportes/reporte_access.txt
```
Esperado: Numero mayor que 0. Los 6 agentes deben tener al menos una coincidencia.

**SQL Injection:**
```bash
grep -ciE "UNION|SELECT|OR%201=1|%27" reportes/reporte_access.txt
```
Esperado: Numero mayor que 0.

**Path traversal:**
```bash
grep -ciE "\.\./|%2e%2e|/etc/passwd" reportes/reporte_access.txt
```
Esperado: Numero mayor que 0.

**Conclusion:**
```bash
grep -A5 "8) Conclusion" reportes/reporte_access.txt
```
Esperado: Texto con resumen de hallazgos (no debe decir "TODO" ni "pendiente").

---

## Paso 5: Analisis de error.log (15 pts)

### 5.1 Ejecutar analizar_error.sh

```bash
./scripts/analizar_error.sh
```

**Esperado:** Termina sin errores.

### 5.2 Verificar que el reporte existe

```bash
test -f reportes/reporte_error.txt && echo "OK" || echo "FALTA"
```

### 5.3 Verificar las 7 secciones

```bash
grep -c "^[0-9])" reportes/reporte_error.txt
```

**Esperado:** `7`.

### 5.4 Verificar contenido especifico

**Total de lineas:**
```bash
grep -A1 "1) Total" reportes/reporte_error.txt
```
Esperado: 146 lineas.

**Access forbidden:**
```bash
grep "access forbidden" reportes/reporte_error.txt | head -3
```
Esperado: Lineas del error.log que contienen "access forbidden by rule".

**Permission denied:**
```bash
grep "permission denied" reportes/reporte_error.txt | head -3
```
Esperado: Lineas con "permission denied while accessing /admin".

**Archivos inexistentes:**
```bash
grep -c "No such file\|open()" reportes/reporte_error.txt
```
Esperado: Numero mayor que 0.

**Upstream:**
```bash
grep -ciE "connection refused|buffered|prematurely" reportes/reporte_error.txt
```
Esperado: Numero mayor que 0.

**IPs frecuentes:**
```bash
grep -A12 "6) IPs" reportes/reporte_error.txt
```
Esperado: Lista de IPs con conteo, ordenada de mayor a menor.

**Conclusion:**
```bash
grep -A5 "7) Conclusion" reportes/reporte_error.txt
```
Esperado: Texto con resumen (sin "TODO" ni "pendiente").

---

## Paso 6: Configuracion de cron (10 pts)

### 6.1 Verificar que cron esta configurado

```bash
crontab -l
```

**Esperado:** Al menos 4 entradas con rutas absolutas a:
- `backup.sh`
- `rotar_backups.sh`
- `analizar_access.sh`
- `analizar_error.sh`

### 6.2 Verificar evidencia de cron

```bash
cat evidencia/cron.txt
```

**Esperado:** Mismo contenido que `crontab -l`. Si no existe, el alumno debe ejecutar:

```bash
crontab -l > evidencia/cron.txt
```

---

## Paso 7: Reporte final (10 pts)

### 7.1 Ejecutar reporte_final.sh

```bash
./scripts/reporte_final.sh
```

**Esperado:** Termina sin errores. Si falla, significa que faltan archivos prerequisito (reportes o evidencias de pasos anteriores).

### 7.2 Verificar que el reporte existe

```bash
test -f reportes/reporte_final.md && echo "OK" || echo "FALTA"
```

### 7.3 Verificar las 7 secciones del reporte Markdown

```bash
grep -c "^## " reportes/reporte_final.md
```

**Esperado:** `7` secciones.

### 7.4 Verificar contenido clave

```bash
grep -c "TODO\|pendiente" reportes/reporte_final.md
```

**Esperado:** `0` (ningun TODO sin resolver en el reporte final).

```bash
grep "STUDENT_ID\|Alumno" reportes/reporte_final.md
```

**Esperado:** Debe mostrar el ID real del alumno, no "ID_ALUMNO".

---

## Paso 8: Evidencias completas (5 pts)

### 8.1 Verificar que todos los archivos de evidencia existen

```bash
for f in \
  evidencia/setup_estructura.txt \
  evidencia/backup_ejecucion.txt \
  evidencia/rotacion.txt \
  evidencia/cron.txt \
  reportes/reporte_access.txt \
  reportes/reporte_error.txt \
  reportes/reporte_final.md; do
  if [ -f "$f" ]; then
    echo "[OK]    $f"
  else
    echo "[FALTA] $f"
  fi
done
```

**Esperado:** Todos marcan `[OK]`.

### 8.2 Verificar que hay al menos un respaldo

```bash
ls backups/backup_*.tar.gz 2>/dev/null && echo "[OK] Respaldos presentes" || echo "[FALTA] No hay respaldos"
```

---

## Paso 9: Documentacion y limpieza (5 pts)

### 9.1 Verificar que no quedan TODOs pendientes en scripts

```bash
grep -rn "TODO.*pendiente\|echo.*TODO" scripts/
```

**Esperado:** Sin resultados.

### 9.2 Verificar que los scripts estan comentados

```bash
for script in scripts/backup.sh scripts/rotar_backups.sh scripts/analizar_access.sh scripts/analizar_error.sh scripts/reporte_final.sh; do
  COMMENTS=$(grep -c "^[[:space:]]*#" "$script")
  LINES=$(wc -l < "$script")
  echo "$script: $COMMENTS comentarios en $LINES lineas"
done
```

**Esperado:** Cada script debe tener al menos algunos comentarios explicativos.

### 9.3 Verificar que los scripts corren desde la raiz

```bash
./scripts/backup.sh && echo "backup.sh OK"
./scripts/analizar_access.sh && echo "analizar_access.sh OK"
./scripts/analizar_error.sh && echo "analizar_error.sh OK"
```

**Esperado:** Todos terminan sin errores.

---

## Paso 10: Puntos extra (opcional, hasta +20)

### 10.1 Menu interactivo (+5)

```bash
test -f scripts/menu.sh && echo "menu.sh existe" || echo "No existe"
```

Verificar manualmente: ejecutar `./scripts/menu.sh` y probar cada opcion.

### 10.2 Colores en terminal (+2)

```bash
grep -c "033\|\\\\e\[" scripts/menu.sh
```

**Esperado:** Mayor que 0 si implemento colores ANSI.

### 10.3 Validaciones robustas (+3)

```bash
grep -ciE "if \[|require_|validar\|-z \|-d \|-f " scripts/backup.sh scripts/rotar_backups.sh
```

**Esperado:** Varias coincidencias indicando validaciones.

### 10.4 Deteccion avanzada de ataques (+5)

Verificar si el alumno detecto patrones adicionales no listados en los TODOs (ej: brute force por frecuencia de IP, codigos 500 correlacionados, etc.).

### 10.5 Reporte Markdown profesional (+5)

```bash
grep -cE "^#|^\||\`\`\`" reportes/reporte_final.md
```

**Esperado:** Numero alto indica uso de encabezados, tablas y bloques de codigo.

---

## Resumen rapido de verificacion

| Orden | Script/Archivo | Comando de verificacion | Rubrica |
|---|---|---|---:|
| 1 | `config.conf` | `grep STUDENT_ID config.conf` | 10 pts |
| 2 | `setup.sh` | `./scripts/setup.sh` | (parte de 10) |
| 3 | `backup.sh` | `./scripts/backup.sh && ls backups/*.tar.gz` | 15 pts |
| 4 | `rotar_backups.sh` | `./scripts/rotar_backups.sh && cat evidencia/rotacion.txt` | 10 pts |
| 5 | `analizar_access.sh` | `./scripts/analizar_access.sh && cat reportes/reporte_access.txt` | 20 pts |
| 6 | `analizar_error.sh` | `./scripts/analizar_error.sh && cat reportes/reporte_error.txt` | 15 pts |
| 7 | `crontab` | `cat evidencia/cron.txt` | 10 pts |
| 8 | `reporte_final.sh` | `./scripts/reporte_final.sh && cat reportes/reporte_final.md` | 10 pts |
| 9 | Evidencias | `ls evidencia/ reportes/ backups/` | 5 pts |
| 10 | Limpieza | `grep -rn "TODO.*pendiente" scripts/` | 5 pts |
| -- | `menu.sh` (extra) | `./scripts/menu.sh` | +5 pts |
