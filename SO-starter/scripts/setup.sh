#!/usr/bin/env bash
# ============================================================
# setup.sh
# Prepara la estructura inicial del proyecto y crea evidencia.
# ============================================================

set -euo pipefail
source ./scripts/lib.sh
load_config

# TODO-02: Ejecuta este script antes de iniciar el proyecto:
# ./scripts/setup.sh

ensure_dir "$BACKUP_DIR"
ensure_dir "$REPORT_DIR"
ensure_dir "$EVIDENCE_DIR"
ensure_dir "$LOG_DIR"

EVIDENCE_FILE="$EVIDENCE_DIR/setup_estructura.txt"

{
    echo "=== Evidencia de preparación del entorno ==="
    echo "Fecha: $(date)"
    echo "Usuario: $(whoami)"
    echo "Directorio actual: $(pwd)"
    echo
    echo "=== Estructura principal ==="
    find . -maxdepth 2 -type d | sort
    echo
    echo "=== Scripts disponibles ==="
    ls -lh scripts/*.sh
    echo
    echo "=== Logs disponibles ==="
    ls -lh "$LOG_DIR"
} | tee "$EVIDENCE_FILE"

echo "Setup terminado. Evidencia guardada en $EVIDENCE_FILE"
