#!/usr/bin/env bash
# ============================================================
# reporte_final.sh
# Integra resultados principales en un reporte final Markdown.
# ============================================================

set -euo pipefail
source ./scripts/lib.sh
load_config

ensure_dir "$REPORT_DIR"
FINAL_REPORT="$REPORT_DIR/reporte_final.md"

# TODO-29: Antes de generar el reporte final, valida que existan:
# reportes/reporte_access.txt
# reportes/reporte_error.txt
# evidencia/backup_ejecucion.txt
# evidencia/rotacion.txt

{
    echo "# Reporte final — Proyecto Final de Sistemas Operativos"
    echo
    echo "## 1. Información general"
    echo
    echo "- Alumno/equipo: $STUDENT_ID"
    echo "- Fecha: $(date)"
    echo "- Proyecto: $PROJECT_NAME"
    echo

    echo "## 2. Resumen de respaldos"
    echo
    # TODO-30: Agrega lista de respaldos generados en BACKUP_DIR.
    echo "TODO-30: agregar respaldos generados."
    echo

    echo "## 3. Evidencia de rotación"
    echo
    # TODO-31: Inserta o resume evidencia/rotacion.txt si existe.
    echo "TODO-31: agregar resumen de rotación."
    echo

    echo "## 4. Resumen de access.log"
    echo
    # TODO-32: Inserta las partes más importantes de reportes/reporte_access.txt.
    echo "TODO-32: agregar resumen de access.log."
    echo

    echo "## 5. Resumen de error.log"
    echo
    # TODO-33: Inserta las partes más importantes de reportes/reporte_error.txt.
    echo "TODO-33: agregar resumen de error.log."
    echo

    echo "## 6. Configuración de cron"
    echo
    # TODO-34: Explica las tareas configuradas en cron e incluye evidencia/cron.txt.
    echo "TODO-34: agregar configuración de cron."
    echo

    echo "## 7. Conclusiones"
    echo
    # TODO-35: Escribe una conclusión técnica: qué se automatizó, qué ataques se detectaron y qué aprendiste.
    echo "TODO-35: agregar conclusión final."
} > "$FINAL_REPORT"

echo "Reporte final generado en $FINAL_REPORT"
