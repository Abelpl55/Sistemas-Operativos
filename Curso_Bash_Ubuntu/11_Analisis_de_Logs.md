# Leccion 11: Analisis de Logs

## Objetivos

- Entender el formato de logs de servidores web (Nginx/Apache)
- Extraer informacion relevante de access.log y error.log
- Construir reportes de analisis con pipelines de texto
- Detectar patrones de trafico anormal y ataques

---

## 11.1 Que son los Logs

Los **logs** (bitacoras) son archivos de texto donde el sistema operativo y las
aplicaciones registran eventos, errores y actividad. Son fundamentales para:

- **Diagnostico**: Identificar por que fallo algo
- **Seguridad**: Detectar accesos no autorizados o ataques
- **Monitoreo**: Conocer el uso y rendimiento del sistema
- **Auditoria**: Registrar quien hizo que y cuando

### Logs comunes en Linux

| Archivo | Contenido |
|---------|-----------|
| `/var/log/syslog` | Eventos generales del sistema |
| `/var/log/auth.log` | Autenticacion (logins, sudo) |
| `/var/log/kern.log` | Mensajes del kernel |
| `/var/log/nginx/access.log` | Peticiones HTTP al servidor web |
| `/var/log/nginx/error.log` | Errores del servidor web |
| `/var/log/apache2/access.log` | Peticiones HTTP (Apache) |

## 11.2 Formato de access.log (Nginx Combined)

Cada linea de access.log representa una peticion HTTP:

```
192.168.1.15 - - [14/May/2026:10:30:00 -0600] "GET /index.html HTTP/1.1" 200 5432 "https://example.com" "Mozilla/5.0 (Windows NT 10.0)"
```

### Campos del log

| Campo | Posicion (awk) | Ejemplo | Significado |
|-------|----------------|---------|-------------|
| IP del cliente | `$1` | `192.168.1.15` | Quien hizo la peticion |
| Identidad | `$2` | `-` | Siempre `-` (no usado) |
| Usuario | `$3` | `-` | Usuario autenticado |
| Fecha/hora | `$4,$5` | `[14/May/2026:10:30:00 -0600]` | Cuando se hizo |
| Metodo + ruta | `$6,$7,$8` | `"GET /index.html HTTP/1.1"` | Que se pidio |
| Codigo HTTP | `$9` | `200` | Resultado de la peticion |
| Bytes | `$10` | `5432` | Tamano de la respuesta |
| Referer | `$11` | URL de origen | De donde vino |
| User Agent | `$12+` | Navegador/cliente | Con que se conecto |

### Codigos HTTP importantes

| Codigo | Significado | Relevancia en seguridad |
|--------|-------------|------------------------|
| `200` | OK | Peticion exitosa |
| `301/302` | Redireccion | Normal |
| `400` | Bad Request | Peticion malformada |
| `401` | Unauthorized | Fallo de autenticacion |
| `403` | Forbidden | Acceso prohibido |
| `404` | Not Found | Recurso no existe |
| `500` | Internal Server Error | Error del servidor |
| `503` | Service Unavailable | Servidor sobrecargado |

## 11.3 Analisis de access.log

### Seccion 1: Total de lineas

```bash
echo "Total de peticiones: $(wc -l < "$ACCESS_LOG")"
```

### Seccion 2: Top 10 IPs por numero de peticiones

```bash
echo "--- Top 10 IPs ---"
awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head -10
```

Resultado:
```
    132 192.168.1.15
     98 10.0.0.25
     87 172.16.0.100
     76 203.0.113.45
     65 198.51.100.12
```

Una IP con muchas peticiones podria ser:
- Un usuario activo (normal)
- Un bot/crawler (posiblemente normal)
- Un scanner/atacante (sospechoso)

### Seccion 3: Distribucion de codigos HTTP

```bash
echo "--- Codigos HTTP ---"
awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -nr
```

Resultado:
```
    899 200
    188 401
     86 404
     75 403
     42 301
     35 500
     29 503
```

Interpretacion:
- Muchos `401` = Intentos fallidos de login (posible fuerza bruta)
- Muchos `403` = Accesos prohibidos (exploracion de rutas)
- Muchos `404` = Busqueda de archivos inexistentes (scanning)
- Muchos `500/503` = Problemas del servidor o ataques DoS

### Seccion 4: Accesos a rutas sensibles

```bash
echo "--- Rutas sensibles ---"
SENSIBLES=$(grep -iE '/\.env|phpmyadmin|wp-login\.php|xmlrpc\.php|server-status|/admin' "$ACCESS_LOG" || true)
if [ -n "$SENSIBLES" ]; then
    echo "$SENSIBLES"
    echo ""
    echo "Total: $(echo "$SENSIBLES" | wc -l) accesos sospechosos"
else
    echo "Ninguno detectado."
fi
```

Estas rutas son objetivos comunes de atacantes:
- `/.env` - Variables de entorno (contrasenas, API keys)
- `/phpmyadmin` - Panel de base de datos
- `/wp-login.php` - Login de WordPress
- `/xmlrpc.php` - API de WordPress (vulnerable)
- `/admin` - Panel de administracion

### Seccion 5: User agents sospechosos

```bash
echo "--- User agents de herramientas de escaneo ---"
AGENTS=$(grep -iE 'sqlmap|Nikto|curl/|masscan|python-requests|Go-http-client' "$ACCESS_LOG" || true)
if [ -n "$AGENTS" ]; then
    echo "$AGENTS" | head -5
    echo "Total: $(echo "$AGENTS" | wc -l)"
else
    echo "Ninguno detectado."
fi
```

### Seccion 6: Intentos de SQL Injection

```bash
echo "--- SQL Injection ---"
SQLI=$(grep -iE 'UNION|SELECT|OR%201=1|%27|--' "$ACCESS_LOG" || true)
if [ -n "$SQLI" ]; then
    echo "$SQLI" | head -5
    echo "Total intentos: $(echo "$SQLI" | wc -l)"
else
    echo "Ninguno detectado."
fi
```

### Seccion 7: Intentos de Path Traversal

```bash
echo "--- Path Traversal ---"
TRAVERSAL=$(grep -iE '\.\./|%2e%2e|/etc/passwd' "$ACCESS_LOG" || true)
if [ -n "$TRAVERSAL" ]; then
    echo "$TRAVERSAL" | head -5
    echo "Total intentos: $(echo "$TRAVERSAL" | wc -l)"
else
    echo "Ninguno detectado."
fi
```

### Seccion 8: Conclusion

```bash
TOTAL_SENSIBLES=$(grep -ciE '/\.env|phpmyadmin|wp-login|/admin' "$ACCESS_LOG" || true)
TOTAL_AGENTS=$(grep -ciE 'sqlmap|Nikto|curl/|masscan' "$ACCESS_LOG" || true)
TOTAL_SQLI=$(grep -ciE 'UNION|SELECT|OR%201=1|%27|--' "$ACCESS_LOG" || true)
TOTAL_TRAVERSAL=$(grep -ciE '\.\./|%2e%2e|/etc/passwd' "$ACCESS_LOG" || true)

echo "=== RESUMEN ==="
echo "Accesos a rutas sensibles: $TOTAL_SENSIBLES"
echo "Agentes de escaneo:        $TOTAL_AGENTS"
echo "Intentos SQL injection:    $TOTAL_SQLI"
echo "Intentos path traversal:   $TOTAL_TRAVERSAL"
```

## 11.4 Formato de error.log (Nginx)

```
2026/05/14 10:30:00 [error] 1234#1234: *5678 access forbidden by rule, client: 203.0.113.45, server: example.com, request: "GET /.env HTTP/1.1"
```

| Parte | Significado |
|-------|-------------|
| `2026/05/14 10:30:00` | Fecha y hora |
| `[error]` | Nivel de severidad |
| `1234#1234` | PID del proceso |
| `*5678` | ID de conexion |
| `access forbidden by rule` | Mensaje de error |
| `client: 203.0.113.45` | IP del cliente |
| `server: example.com` | Servidor que recibio la peticion |
| `request: "GET /.env"` | Peticion que causo el error |

## 11.5 Analisis de error.log

```bash
#!/usr/bin/env bash
set -euo pipefail

LOG="./logs/error.log"

{
    echo "=== ANALISIS DE ERROR LOG ==="
    echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""

    echo "--- 1. Total de errores ---"
    echo "$(wc -l < "$LOG") lineas"
    echo ""

    echo "--- 2. Accesos prohibidos (access forbidden) ---"
    echo "$(grep -c 'access forbidden' "$LOG" || true) eventos"
    echo ""

    echo "--- 3. Permisos denegados (permission denied) ---"
    echo "$(grep -c 'permission denied' "$LOG" || true) eventos"
    echo ""

    echo "--- 4. Archivos no encontrados ---"
    echo "$(grep -cE 'No such file|open\(\) .* failed' "$LOG" || true) eventos"
    echo ""

    echo "--- 5. Problemas de upstream (backend) ---"
    echo "$(grep -ciE 'upstream|connection refused|timeout|buffered|prematurely closed' "$LOG" || true) eventos"
    echo ""

    echo "--- 6. Top IPs en errores ---"
    grep -oE 'client: ([0-9.]+)' "$LOG" | sed 's/client: //' | sort | uniq -c | sort -nr | head -10
    echo ""

    echo "--- 7. Conclusion ---"
    echo "Los errores de tipo 'access forbidden' indican intentos de acceso"
    echo "a rutas protegidas. Los errores de upstream pueden indicar problemas"
    echo "con el servidor backend o posibles ataques de denegacion de servicio."

} | tee reportes/reporte_error.txt
```

## 11.6 Generando el Reporte Final

El reporte final consolida toda la informacion en un documento Markdown:

```bash
#!/usr/bin/env bash
set -euo pipefail

REPORTE="reportes/reporte_final.md"

{
    echo "# Reporte Final del Proyecto"
    echo ""
    echo "**Alumno:** $STUDENT_ID"
    echo "**Fecha:** $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "## 1. Backups"
    echo ""
    echo '```'
    ls -lh backups/*.tar.gz 2>/dev/null || echo "No hay backups"
    echo '```'
    echo ""
    echo "## 2. Rotacion"
    echo ""
    echo '```'
    if [ -f "evidencia/rotacion.txt" ]; then
        cat evidencia/rotacion.txt
    else
        echo "(sin evidencia)"
    fi
    echo '```'
    echo ""
    echo "## 3. Analisis de Access Log"
    echo ""
    echo '```'
    if [ -f "reportes/reporte_access.txt" ]; then
        cat reportes/reporte_access.txt
    else
        echo "(sin reporte)"
    fi
    echo '```'
    echo ""
    echo "## 4. Analisis de Error Log"
    echo ""
    echo '```'
    if [ -f "reportes/reporte_error.txt" ]; then
        cat reportes/reporte_error.txt
    else
        echo "(sin reporte)"
    fi
    echo '```'

} > "$REPORTE"

echo "Reporte final generado: $REPORTE"
```

---

## Ejercicios

### [PRACTICA 11.1] Analizar un log basico
Crea un archivo `mi_access.log` con al menos 20 lineas simuladas y analiza:
1. Top 5 IPs
2. Distribucion de codigos HTTP
3. Rutas mas solicitadas

### [PRACTICA 11.2] Detectar ataques
Usando el access.log del proyecto SO-Finish:
1. Cuenta los intentos de SQL injection
2. Identifica las IPs que generan mas errores 403
3. Lista las herramientas de escaneo detectadas

### [PRACTICA 11.3] Reporte automatico
Escribe un script que genere un reporte en formato Markdown con:
- Fecha del analisis
- Resumen ejecutivo (1 parrafo)
- Tabla de hallazgos
- Recomendaciones

### [PRACTICA 11.4] Correlacion
Escribe un script que cruce datos entre access.log y error.log:
- Encuentra IPs que aparecen en ambos logs
- Para esas IPs, muestra que tipo de actividad tienen

---

## Resumen

| Analisis | Pipeline |
|----------|---------|
| Total de lineas | `wc -l < log` |
| Top IPs | `awk` &#124; `sort` &#124; `uniq -c` &#124; `sort -nr` &#124; `head -10` |
| Codigos HTTP | `awk` &#124; `sort` &#124; `uniq -c` &#124; `sort -nr` |
| Rutas sensibles | `grep -iE '/\.env\|phpmyadmin\|/admin'` |
| SQL injection | `grep -iE 'UNION\|SELECT\|OR%201=1'` |
| Path traversal | `grep -iE '\.\./\|%2e%2e\|/etc/passwd'` |
| Scanners | `grep -iE 'sqlmap\|Nikto\|masscan'` |
| IPs en errores | `grep -oE` &#124; `sed` &#124; `sort` &#124; `uniq -c` &#124; `sort -nr` |

**Siguiente leccion**: [12 - Automatizacion con Cron](12_Automatizacion_Cron.md)
