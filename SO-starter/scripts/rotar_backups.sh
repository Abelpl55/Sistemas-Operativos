#!/usr/bin/env bash
# ============================================================
# rotar_backups.sh
# Conserva solamente los últimos MAX_BACKUPS respaldos.
# ============================================================

set -euo pipefail
source ./scripts/lib.sh
load_config

EVIDENCE_FILE="$EVIDENCE_DIR/rotacion.txt"
ensure_dir "$BACKUP_DIR"
ensure_dir "$EVIDENCE_DIR"

# TODO-09: Valida que MAX_BACKUPS sea un número mayor que 0.

# TODO-10: Lista los respaldos ordenados del más reciente al más antiguo.
# Pista: ls -1t "$BACKUP_DIR"/backup_*.tar.gz

# TODO-11: Cuenta cuántos respaldos existen.
# Pista: wc -l

# TODO-12: Si hay más de MAX_BACKUPS, elimina los más antiguos.
# Pista: tail -n +$((MAX_BACKUPS + 1))

# TODO-13: Registra en evidencia qué respaldos se conservaron y cuáles se eliminaron.

{
    echo "=== Rotación de respaldos ==="
    echo "Fecha: $(date)"
    echo "BACKUP_DIR=$BACKUP_DIR"
    echo "MAX_BACKUPS=$MAX_BACKUPS"
    echo
    echo "TODO: aquí debe aparecer la lista de respaldos conservados y eliminados."
} | tee "$EVIDENCE_FILE"

echo "TODO: rotar_backups.sh todavía debe completarse."
