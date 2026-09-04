# Rúbrica — Proyecto Final de Sistemas Operativos
## Automatización y análisis de seguridad en Linux con Bash

Total: **100 puntos**

| Criterio | Descripción | Puntos |
|---|---|---:|
| Configuración inicial | Ejecuta setup, ajusta config.conf y mantiene estructura correcta | 10 |
| Respaldo con Bash | Completa `backup.sh`, valida rutas, genera `.tar.gz`, registra evidencia | 15 |
| Rotación de respaldos | Completa `rotar_backups.sh`, conserva últimos respaldos y elimina antiguos con evidencia | 10 |
| Cron | Configura tareas automáticas y entrega evidencia de `crontab -l` | 10 |
| Análisis de access.log | Completa detección de IPs, códigos, rutas sensibles, agentes sospechosos, SQLi y traversal | 20 |
| Análisis de error.log | Completa detección de errores, permisos, upstream, rutas inexistentes e IPs frecuentes | 15 |
| Reporte final | Genera `reporte_final.md` claro, ordenado y con conclusiones técnicas | 10 |
| Evidencias | Incluye archivos en `evidencia/`, `reportes/` y `backups/` | 5 |
| Documentación y limpieza | Scripts comentados, legibles y ejecutables desde la raíz | 5 |
| **Total** |  | **100** |

---

## Puntos extra

| Mejora | Puntos extra |
|---|---:|
| Menú interactivo mejorado | +5 |
| Colores y formato legible en terminal | +2 |
| Validaciones robustas adicionales | +3 |
| Detección avanzada de ataques | +5 |
| Reporte Markdown más profesional | +5 |

---

## Checklist rápido de TODOs

El alumno debe resolver como mínimo:

```text
TODO-00A
TODO-03 a TODO-35
```

Opcional para extra:

```text
TODO-36
```
