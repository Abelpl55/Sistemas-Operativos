#!/usr/bin/env bash
# ============================================================
# analizar_error.sh
# Analiza error.log para detectar eventos relevantes del servidor.
# ============================================================

set -euo pipefail
source ./scripts/lib.sh
load_config

REPORT_FILE="$REPORT_DIR/reporte_error.txt"
ensure_dir "$REPORT_DIR"
require_file "$ERROR_LOG"

{
    echo "=== Reporte de error.log ==="
    echo "Fecha: $(date)"
    echo "Archivo analizado: $ERROR_LOG"
    echo

    echo "1) Total de líneas del log"
    # TODO-22: Cuenta el total de líneas de error.log.
    echo "TODO-22 pendiente"
    echo

    echo "2) Eventos access forbidden"
    # TODO-23: Busca ocurrencias de access forbidden.
    echo "TODO-23 pendiente"
    echo

    echo "3) Eventos permission denied"
    # TODO-24: Busca ocurrencias de permission denied.
    echo "TODO-24 pendiente"
    echo

    echo "4) Archivos o rutas inexistentes"
    # TODO-25: Busca No such file or directory, open() failed, 404 o rutas inexistentes.
    echo "TODO-25 pendiente"
    echo

    echo "5) Problemas de upstream"
    # TODO-26: Busca upstream, connection refused, timeout, buffered to a temporary file.
    echo "TODO-26 pendiente"
    echo

    echo "6) IPs que aparecen en errores"
    # TODO-27: Extrae IPs desde las líneas de error y muestra las más frecuentes.
    # Pista: grep -oE 'client: ([0-9]{1,3}\.){3}[0-9]{1,3}' "$ERROR_LOG"
    echo "TODO-27 pendiente"
    echo

    echo "7) Conclusión breve"
    # TODO-28: Escribe una conclusión sobre los errores principales.
    echo "TODO-28 pendiente"
} | tee "$REPORT_FILE"

echo "Reporte generado en $REPORT_FILE"
