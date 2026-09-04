# Leccion 12: Automatizacion con Cron

## Objetivos

- Entender que es cron y como funciona
- Configurar tareas programadas con `crontab`
- Escribir expresiones cron para diferentes intervalos
- Generar evidencia de configuracion cron para el proyecto

---

## 12.1 Que es Cron

**Cron** es un servicio de Linux que ejecuta comandos o scripts de forma automatica
en horarios programados. Es el equivalente a las "Tareas Programadas" de Windows.

Casos de uso:
- Ejecutar backups cada noche a las 2:00 AM
- Rotar logs cada semana
- Analizar logs de seguridad cada hora
- Limpiar archivos temporales cada dia

### Verificar que cron esta activo

```bash
$ systemctl status cron
# O en algunas distribuciones:
$ systemctl status crond

# Deberia mostrar: Active: active (running)
```

## 12.2 Formato de Crontab

Cada linea de crontab tiene 5 campos de tiempo + el comando:

```
* * * * * comando_a_ejecutar
│ │ │ │ │
│ │ │ │ └── Dia de la semana (0-7, donde 0 y 7 = domingo)
│ │ │ └──── Mes (1-12)
│ │ └────── Dia del mes (1-31)
│ └──────── Hora (0-23)
└────────── Minuto (0-59)
```

### Valores especiales

| Caracter | Significado | Ejemplo |
|----------|-------------|---------|
| `*` | Todos los valores | `* * * * *` = cada minuto |
| `,` | Lista de valores | `1,15,30` = min 1, 15 y 30 |
| `-` | Rango | `1-5` = lunes a viernes |
| `/` | Cada N | `*/5` = cada 5 (minutos/horas/etc.) |

## 12.3 Ejemplos de Expresiones Cron

| Expresion | Significado |
|-----------|-------------|
| `* * * * *` | Cada minuto |
| `0 * * * *` | Cada hora (en el minuto 0) |
| `0 2 * * *` | Todos los dias a las 2:00 AM |
| `0 0 * * 0` | Cada domingo a medianoche |
| `*/5 * * * *` | Cada 5 minutos |
| `0 9-17 * * 1-5` | Cada hora de 9 AM a 5 PM, lunes a viernes |
| `0 2 * * 1` | Cada lunes a las 2:00 AM |
| `0 0 1 * *` | El primero de cada mes a medianoche |
| `30 4 * * *` | Todos los dias a las 4:30 AM |
| `0 */6 * * *` | Cada 6 horas |

### Expresiones del proyecto

Para el proyecto se requieren al menos 4 tareas programadas:

```
# Backup diario a las 2:00 AM
0 2 * * * /home/alumno/proyecto/scripts/backup.sh

# Rotacion semanal los domingos a las 3:00 AM
0 3 * * 0 /home/alumno/proyecto/scripts/rotar_backups.sh

# Analisis de access.log cada 6 horas
0 */6 * * * /home/alumno/proyecto/scripts/analizar_access.sh

# Analisis de error.log diario a las 6:00 AM
0 6 * * * /home/alumno/proyecto/scripts/analizar_error.sh
```

## 12.4 Comandos de Crontab

### Editar el crontab

```bash
# Abrir editor de crontab del usuario actual
$ crontab -e

# Primera vez preguntara que editor usar:
# 1. /bin/nano (recomendado para principiantes)
# 2. /usr/bin/vim
```

### Ver el crontab actual

```bash
$ crontab -l
```

### Eliminar el crontab (cuidado)

```bash
$ crontab -r     # Elimina TODAS las tareas
```

## 12.5 Configurar Cron Paso a Paso

### Paso 1: Asegura que los scripts son ejecutables

```bash
$ chmod +x scripts/*.sh
```

### Paso 2: Usa rutas absolutas

Cron ejecuta los comandos sin tu entorno (PATH, directorio de trabajo).
Siempre usa **rutas absolutas**:

```bash
# INCORRECTO (cron no sabe donde estan):
0 2 * * * ./scripts/backup.sh

# CORRECTO (ruta completa):
0 2 * * * /home/alumno/proyecto/scripts/backup.sh

# ALTERNATIVA (cambiar directorio primero):
0 2 * * * cd /home/alumno/proyecto && ./scripts/backup.sh
```

### Paso 3: Editar crontab

```bash
$ crontab -e
```

Agrega las lineas (despues de los comentarios existentes):

```cron
# Proyecto SO - Tareas automatizadas
# Backup diario a las 2:00 AM
0 2 * * * cd /home/alumno/proyecto && ./scripts/backup.sh >> /tmp/cron_backup.log 2>&1

# Rotacion semanal domingos a las 3:00 AM
0 3 * * 0 cd /home/alumno/proyecto && ./scripts/rotar_backups.sh >> /tmp/cron_rotacion.log 2>&1

# Analisis access.log cada 6 horas
0 */6 * * * cd /home/alumno/proyecto && ./scripts/analizar_access.sh >> /tmp/cron_access.log 2>&1

# Analisis error.log diario a las 6:00 AM
0 6 * * * cd /home/alumno/proyecto && ./scripts/analizar_error.sh >> /tmp/cron_error.log 2>&1
```

### Paso 4: Verificar

```bash
$ crontab -l
```

### Redireccion de salida en cron

```bash
# Sin redireccion: cron envia la salida por email (puede no funcionar)
0 2 * * * /ruta/script.sh

# Redirigir stdout y stderr a un log
0 2 * * * /ruta/script.sh >> /tmp/mi_log.log 2>&1

# Descartar toda la salida
0 2 * * * /ruta/script.sh > /dev/null 2>&1
```

## 12.6 Generar Evidencia de Cron

El proyecto requiere un archivo `evidencia/cron.txt` con tu configuracion:

```bash
# Guardar la configuracion de cron como evidencia
$ crontab -l > evidencia/cron.txt 2>&1

# O crearla manualmente si cron no esta disponible:
$ cat > evidencia/cron.txt << 'EOF'
# Proyecto SO - Configuracion de Cron
# Alumno: [TU_ID]
# Fecha: [FECHA]

# Backup diario a las 2:00 AM
0 2 * * * cd /home/alumno/proyecto && ./scripts/backup.sh >> /tmp/cron_backup.log 2>&1

# Rotacion semanal domingos a las 3:00 AM
0 3 * * 0 cd /home/alumno/proyecto && ./scripts/rotar_backups.sh >> /tmp/cron_rotacion.log 2>&1

# Analisis access.log cada 6 horas
0 */6 * * * cd /home/alumno/proyecto && ./scripts/analizar_access.sh >> /tmp/cron_access.log 2>&1

# Analisis error.log diario a las 6:00 AM
0 6 * * * cd /home/alumno/proyecto && ./scripts/analizar_error.sh >> /tmp/cron_error.log 2>&1
EOF
```

## 12.7 Debugging de Cron

### Problemas comunes

| Problema | Causa | Solucion |
|----------|-------|----------|
| El script no se ejecuta | Falta permiso de ejecucion | `chmod +x script.sh` |
| "command not found" | Ruta no absoluta | Usar ruta completa |
| Variables no definidas | Cron no carga .bashrc | Definir variables en el script |
| No genera archivos | Directorio de trabajo incorrecto | Usar `cd` antes del script |
| No hay salida | Sin redireccion | Agregar `>> log 2>&1` |

### Verificar que cron ejecuto algo

```bash
# Ver logs del sistema (buscar cron)
$ grep CRON /var/log/syslog | tail -20

# O en systemd
$ journalctl -u cron --since "1 hour ago"
```

### Probar un cron rapido

Para verificar que tu configuracion funciona, programa algo para el proximo minuto:

```bash
$ crontab -e

# Agrega una tarea que se ejecute en 1-2 minutos:
42 15 * * * echo "Funciona! $(date)" >> /tmp/test_cron.txt

# Espera y verifica:
$ cat /tmp/test_cron.txt
# Deberia mostrar: Funciona! jue may 14 15:42:00 CST 2026

# No olvides eliminar la tarea de prueba despues
```

## 12.8 Alternativas a Cron

### systemd timers (moderno)

```bash
# Ver timers activos
$ systemctl list-timers

# Los timers de systemd son mas flexibles pero mas complejos
```

### at (ejecucion unica)

```bash
# Ejecutar un comando una sola vez en un tiempo futuro
$ echo "script.sh" | at 2:00 AM tomorrow

# Ver tareas pendientes
$ atq
```

### watch (repetir en tiempo real)

```bash
# Ejecutar un comando cada 5 segundos
$ watch -n 5 'ls -la backups/'
```

---

## Ejercicios

### [PRACTICA 12.1] Expresiones cron
Escribe la expresion cron para:
1. Cada 15 minutos
2. Todos los dias a las 11:30 PM
3. Cada lunes y jueves a las 8:00 AM
4. El dia 1 y 15 de cada mes a medianoche
5. Cada hora de 9 AM a 6 PM de lunes a viernes

### [PRACTICA 12.2] Configurar cron basico
1. Crea un script `fecha.sh` que escriba la fecha en un archivo
2. Programa cron para ejecutarlo cada 2 minutos
3. Espera 6 minutos y verifica que se ejecuto 3 veces
4. Elimina la tarea de cron

### [PRACTICA 12.3] Cron para el proyecto
Configura las 4 tareas cron del proyecto y guarda la evidencia:
```bash
$ crontab -l > evidencia/cron.txt
$ cat evidencia/cron.txt
```

### [PRACTICA 12.4] Diagnostico
Describe que harias si:
1. Tu tarea cron no se ejecuta
2. Se ejecuta pero no genera archivos
3. Se ejecuta pero da errores de "command not found"

---

## Resumen

| Concepto | Comando/Sintaxis |
|----------|-----------------|
| Editar cron | `crontab -e` |
| Ver cron | `crontab -l` |
| Eliminar cron | `crontab -r` |
| Cada minuto | `* * * * *` |
| Cada hora | `0 * * * *` |
| Diario 2 AM | `0 2 * * *` |
| Semanal domingo | `0 3 * * 0` |
| Cada N minutos | `*/N * * * *` |
| Cada N horas | `0 */N * * *` |
| Guardar evidencia | `crontab -l > evidencia/cron.txt` |

### Formato

```
minuto hora dia_mes mes dia_semana comando
(0-59) (0-23) (1-31) (1-12) (0-7)
```

**Siguiente leccion**: [13 - Seguridad y Analisis de Ataques](13_Seguridad_Analisis_Ataques.md)
