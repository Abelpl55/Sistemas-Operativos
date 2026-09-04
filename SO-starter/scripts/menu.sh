#!/usr/bin/env bash
# ============================================================
# menu.sh
# Menú opcional para ejecutar scripts del proyecto.
# ============================================================

set -euo pipefail

# TODO-36: Este archivo es opcional. Puedes mejorarlo para obtener puntos extra.
# Ideas:
# 1. Agregar colores.
# 2. Validar opciones incorrectas.
# 3. Mostrar ubicación de reportes generados.
# 4. Preguntar confirmación antes de rotar respaldos.

while true; do
    echo ""
    echo "=== Menú del proyecto final SO ==="
    echo "1) Preparar entorno"
    echo "2) Generar respaldo"
    echo "3) Rotar respaldos"
    echo "4) Analizar access.log"
    echo "5) Analizar error.log"
    echo "6) Generar reporte final"
    echo "0) Salir"
    echo -n "Elige una opción: "
    read -r opcion

    case "$opcion" in
        1) ./scripts/setup.sh ;;
        2) ./scripts/backup.sh ;;
        3) ./scripts/rotar_backups.sh ;;
        4) ./scripts/analizar_access.sh ;;
        5) ./scripts/analizar_error.sh ;;
        6) ./scripts/reporte_final.sh ;;
        0) echo "Saliendo..."; exit 0 ;;
        *) echo "Opción inválida" ;;
    esac
done
