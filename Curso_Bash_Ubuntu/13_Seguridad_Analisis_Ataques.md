# Leccion 13: Seguridad y Analisis de Ataques

## Objetivos

- Comprender los ataques web mas comunes (OWASP Top 10)
- Detectar patrones de ataque en logs de servidor
- Entender como funcionan SQL Injection y Path Traversal
- Interpretar resultados de analisis para generar conclusiones de seguridad

---

## 13.1 Por que la Seguridad en Sistemas Operativos

Como administrador de servidores, eres la primera linea de defensa. Los logs son
tu herramienta principal para:

- **Detectar** ataques en progreso o pasados
- **Identificar** la fuente de ataques (IPs, herramientas)
- **Documentar** incidentes para respuesta
- **Prevenir** futuros ataques ajustando configuraciones

## 13.2 Tipos de Ataques Web

### Reconocimiento (Information Gathering)

El atacante busca informacion sobre el servidor antes de atacar:

```
# Acceso a rutas sensibles
GET /.env                    # Variables de entorno (contrasenas, API keys)
GET /phpmyadmin              # Panel de base de datos
GET /wp-login.php            # Login de WordPress
GET /xmlrpc.php              # API de WordPress (explotable)
GET /server-status           # Info del servidor Apache
GET /admin                   # Paneles de administracion
```

**Deteccion en logs**:
```bash
$ grep -iE '/\.env|phpmyadmin|wp-login\.php|xmlrpc\.php|server-status|/admin' access.log
```

**Por que es peligroso**: Si el atacante encuentra `.env`, obtiene contrasenas
de bases de datos, API keys, tokens secretos.

### Escaneo con Herramientas Automatizadas

Los atacantes usan herramientas que dejan huella en el User-Agent:

| Herramienta | User-Agent | Proposito |
|-------------|------------|-----------|
| **sqlmap** | `sqlmap/1.x` | SQL Injection automatizada |
| **Nikto** | `Nikto/2.x` | Scanner de vulnerabilidades web |
| **masscan** | `masscan` | Scanner de puertos ultra-rapido |
| **curl** | `curl/7.x` | Peticiones HTTP manuales/scripted |
| **python-requests** | `python-requests/2.x` | Scripts de ataque en Python |
| **Go-http-client** | `Go-http-client/1.1` | Bots escritos en Go |

**Deteccion en logs**:
```bash
$ grep -iE 'sqlmap|Nikto|curl/|masscan|python-requests|Go-http-client' access.log
```

**Un user-agent de herramienta no siempre es malicioso** (curl es muy comun en
scripts legitimos), pero combinado con otros indicadores es sospechoso.

## 13.3 SQL Injection (SQLi)

### Que es

SQL Injection ocurre cuando un atacante inserta codigo SQL malicioso en una
peticion para manipular la base de datos.

### Como funciona

Supongamos un login vulnerable:

```sql
-- Consulta normal
SELECT * FROM usuarios WHERE usuario='admin' AND password='123456'

-- Ataque: el atacante escribe en el campo de password: ' OR 1=1--
SELECT * FROM usuarios WHERE usuario='admin' AND password='' OR 1=1--'
-- OR 1=1 siempre es verdadero => acceso sin contrasena
-- -- comenta el resto de la consulta
```

### Patrones en los logs

Los ataques SQLi aparecen en las URLs como:

```
GET /buscar?q=zapatos' UNION SELECT username,password FROM users--
GET /producto?id=1 OR 1=1
GET /login?user=admin'--
GET /api?search=%27%20OR%201=1--     (URL encoded)
```

| Patron en el log | Significado |
|------------------|-------------|
| `UNION SELECT` | Combinar consultas para extraer datos |
| `OR 1=1` | Condicion siempre verdadera (bypass) |
| `OR%201=1` | Mismo pero URL-encoded (espacio = %20) |
| `%27` | Comilla simple `'` URL-encoded |
| `--` | Comentario SQL (ignora el resto) |
| `DROP TABLE` | Intentar eliminar tablas |

**Deteccion en logs**:
```bash
$ grep -iE 'UNION|SELECT|OR%201=1|%27|--' access.log
```

## 13.4 Path Traversal (Directory Traversal)

### Que es

Path Traversal permite al atacante acceder a archivos fuera del directorio
web usando `../` para navegar hacia arriba en la estructura de directorios.

### Como funciona

```
Servidor web:  /var/www/html/
Peticion normal: GET /pagina.html  => lee /var/www/html/pagina.html

Ataque: GET /../../../etc/passwd
=> El servidor resuelve: /var/www/html/../../../etc/passwd
=> Que equivale a: /etc/passwd
```

### Patrones en los logs

```
GET /../../../../etc/passwd
GET /images/%2e%2e/%2e%2e/etc/shadow
GET /download?file=../../../etc/hosts
```

| Patron | Significado |
|--------|-------------|
| `../` | Navegar al directorio padre |
| `%2e%2e` | `..` URL-encoded (%2e = `.`) |
| `/etc/passwd` | Archivo de usuarios de Linux |
| `/etc/shadow` | Archivo de contrasenas (hashes) |
| `/etc/hosts` | Configuracion de red |
| `/proc/self/environ` | Variables de entorno del proceso |

**Deteccion en logs**:
```bash
$ grep -iE '\.\./|%2e%2e|/etc/passwd' access.log
```

## 13.5 Otros Ataques Comunes

### Fuerza Bruta (Brute Force)

Intentar muchas combinaciones de usuario/contrasena:

```
POST /login 401    # Intento fallido
POST /login 401    # Intento fallido
POST /login 401    # Intento fallido
... (cientos o miles de intentos)
POST /login 200    # Posible acceso exitoso
```

**Indicadores**:
- Muchos codigos 401 desde la misma IP
- Peticiones POST repetidas al mismo endpoint
- Intervalos regulares entre peticiones

**Deteccion**:
```bash
# Contar 401 por IP
$ grep '" 401 ' access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -5
```

### Cross-Site Scripting (XSS)

Inyectar JavaScript en paginas web:

```
GET /buscar?q=<script>alert('hack')</script>
GET /perfil?nombre=%3Cscript%3Edocument.cookie%3C/script%3E
```

**Deteccion**:
```bash
$ grep -iE '<script|%3Cscript|javascript:|onerror=' access.log
```

### Denegacion de Servicio (DoS)

Sobrecarga el servidor con muchas peticiones:

**Indicadores en error.log**:
- `upstream connection refused` - Backend no responde
- `upstream timed out` - Backend tardo demasiado
- `buffered to a temporary file` - Memoria agotada
- `connection prematurely closed` - Conexion interrumpida

**Deteccion**:
```bash
$ grep -ciE 'upstream|connection refused|timeout|buffered|prematurely closed' error.log
```

## 13.6 Analisis Forense: Cruzando Datos

La verdadera habilidad esta en **correlacionar** datos de multiples fuentes:

### Encontrar IPs sospechosas

```bash
#!/usr/bin/env bash

echo "=== IPs con actividad sospechosa ==="

# IPs con mas errores 403 (acceso prohibido)
echo ""
echo "--- IPs con mas 403 ---"
grep '" 403 ' access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -5

# IPs con intentos de SQL injection
echo ""
echo "--- IPs con SQLi ---"
grep -iE 'UNION|SELECT|OR%201=1' access.log | awk '{print $1}' | sort -u

# IPs que aparecen tanto en access como en error log
echo ""
echo "--- IPs en ambos logs ---"
ACCESS_IPS=$(awk '{print $1}' access.log | sort -u)
ERROR_IPS=$(grep -oE 'client: [0-9.]+' error.log | sed 's/client: //' | sort -u)

# Comparar las dos listas
comm -12 <(echo "$ACCESS_IPS") <(echo "$ERROR_IPS")
```

### Perfil de un atacante

```bash
#!/usr/bin/env bash
# Analizar toda la actividad de una IP sospechosa

IP_SOSPECHOSA="203.0.113.45"

echo "=== Perfil de actividad: $IP_SOSPECHOSA ==="

echo ""
echo "--- Total de peticiones ---"
grep -c "$IP_SOSPECHOSA" access.log

echo ""
echo "--- Codigos HTTP ---"
grep "$IP_SOSPECHOSA" access.log | awk '{print $9}' | sort | uniq -c | sort -nr

echo ""
echo "--- Rutas solicitadas ---"
grep "$IP_SOSPECHOSA" access.log | awk '{print $7}' | sort | uniq -c | sort -nr | head -10

echo ""
echo "--- User Agent ---"
grep "$IP_SOSPECHOSA" access.log | grep -oE '"[^"]*"$' | sort -u

echo ""
echo "--- Errores generados ---"
grep "$IP_SOSPECHOSA" error.log | head -5
```

## 13.7 Recomendaciones de Seguridad

Basado en el analisis, un reporte profesional incluye recomendaciones:

| Hallazgo | Riesgo | Recomendacion |
|----------|--------|---------------|
| Accesos a /.env | Critico | Bloquear acceso en configuracion del servidor |
| SQL Injection | Alto | Usar consultas parametrizadas, WAF |
| Path Traversal | Alto | Validar y sanitizar rutas, chroot |
| Scanners detectados | Medio | Bloquear IPs, rate limiting |
| Fuerza bruta (401s) | Medio | Implementar fail2ban, CAPTCHA |
| Errores upstream | Medio | Monitorear backend, escalado |

---

## Ejercicios

### [PRACTICA 13.1] Identifica el ataque
Para cada linea de log, identifica que tipo de ataque es:
```
1. GET /login?user=admin'%20OR%201=1-- HTTP/1.1
2. GET /../../../etc/passwd HTTP/1.1
3. GET /.env HTTP/1.1
4. POST /login HTTP/1.1 (aparece 500 veces desde la misma IP)
5. GET /search?q=<script>alert(1)</script> HTTP/1.1
```

### [PRACTICA 13.2] Analisis completo
Usando los logs del proyecto SO-Finish:
1. Identifica las 3 IPs mas sospechosas
2. Para cada una, documenta que tipo de ataque realizaron
3. Genera un mini-reporte con hallazgos y recomendaciones

### [PRACTICA 13.3] Script de alerta
Escribe un script que:
1. Analice access.log
2. Detecte IPs con mas de 50 peticiones en total
3. De esas, identifique cuales tienen actividad maliciosa
4. Genere una lista de IPs para bloquear

### [PRACTICA 13.4] Tabla de ataques
Completa la tabla con los comandos grep apropiados:

| Ataque | Comando grep para detectarlo |
|--------|----------------------------|
| SQL Injection | `grep -iE ??? access.log` |
| Path Traversal | `grep -iE ??? access.log` |
| Reconocimiento | `grep -iE ??? access.log` |
| Scanners | `grep -iE ??? access.log` |

---

## Resumen

| Ataque | Patron en log | Comando de deteccion |
|--------|-------------|---------------------|
| Reconocimiento | `/.env`, `/admin`, `/phpmyadmin` | `grep -iE '/\.env\|/admin\|phpmyadmin'` |
| SQL Injection | `UNION`, `SELECT`, `OR 1=1`, `--` | `grep -iE 'UNION\|SELECT\|OR%201=1'` |
| Path Traversal | `../`, `%2e%2e`, `/etc/passwd` | `grep -iE '\.\./\|%2e%2e\|/etc/passwd'` |
| Scanners | `sqlmap`, `Nikto`, `masscan` | `grep -iE 'sqlmap\|Nikto\|masscan'` |
| Fuerza bruta | Muchos 401 | `grep` &#124; `awk` &#124; `sort` &#124; `uniq -c` |
| DoS | `upstream`, `timeout`, `refused` | `grep -iE 'upstream\|timeout\|refused'` |

**Siguiente leccion**: [14 - Manejo de Errores y Buenas Practicas](14_Manejo_Errores_Buenas_Practicas.md)
