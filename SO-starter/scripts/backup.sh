#!/usr/bin/env bash
# ============================================================
# backup.sh
# Genera un respaldo comprimido .tar.gz de una carpeta origen.
# ============================================================

set -euo pipefail
source ./scripts/lib.sh
load_config

EVIDENCE_FILE="$EVIDENCE_DIR/backup_ejecucion.txt"
ensure_dir "$BACKUP_DIR"
ensure_dir "$EVIDENCE_DIR"

# TODO-03: Valida que SOURCE_DIR exista.
# Pista: usa require_dir "$SOURCE_DIR" o una condición if [ ! -d ... ].

# TODO-04: Crea una variable TIMESTAMP usando la función now_stamp.
# Ejemplo esperado: 2026-05-13_22-30-00
TIMESTAMP=""

# TODO-05: Crea el nombre del archivo de respaldo.
# Debe tener este formato aproximado:
# backup_sitio_web_2026-05-13_22-30-00.tar.gz
BACKUP_FILE=""

# TODO-06: Ejecuta tar para comprimir SOURCE_DIR dentro de BACKUP_DIR.
# Pista:
# tar -czf "$BACKUP_FILE" "$SOURCE_DIR"

# TODO-07: Registra la evidencia con tee.
# Debe incluir fecha, carpeta respaldada, archivo generado y tamaño.

{
    echo "=== Ejecución de backup.sh ==="
    echo "Fecha: $(date)"
    echo "SOURCE_DIR=$SOURCE_DIR"
    echo "BACKUP_DIR=$BACKUP_DIR"
    echo
    echo "TODO: aquí debe mostrarse el respaldo generado."
} | tee "$EVIDENCE_FILE"

# TODO-08: Reemplaza el mensaje siguiente por una confirmación real.
echo "TODO: backup.sh todavía debe completarse."
