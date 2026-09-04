#!/usr/bin/env bash
# ============================================================
# lib.sh
# Funciones comunes para los scripts del proyecto.
# ============================================================

# TODO-01: Lee este archivo. No necesitas modificarlo obligatoriamente,
# pero puedes agregar aquí funciones reutilizables si quieres mejorar tu proyecto.

# IMPORTANTE: Los scripts usan set -euo pipefail. Esto significa que si un comando
# como grep no encuentra coincidencias (exit code 1), el script terminará.
# Para evitarlo, agrega "|| true" al final de comandos grep que pueden no encontrar nada.
# Ejemplo: grep -i "patron" archivo || true

set -u

CONFIG_FILE="./config.conf"

load_config() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "ERROR: No se encontró $CONFIG_FILE"
        echo "Ejecuta los scripts desde la raíz del proyecto."
        exit 1
    fi

    # shellcheck disable=SC1090
    source "$CONFIG_FILE"
}

ensure_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
    fi
}

now_stamp() {
    date '+%Y-%m-%d_%H-%M-%S'
}

log_line() {
    local file="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$file"
}

require_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "ERROR: No existe el archivo requerido: $file"
        exit 1
    fi
}

require_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "ERROR: No existe el directorio requerido: $dir"
        exit 1
    fi
}
