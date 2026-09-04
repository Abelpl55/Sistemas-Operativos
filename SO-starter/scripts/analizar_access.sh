#!/usr/bin/env bash
# ============================================================
# analizar_access.sh
# Analiza access.log para detectar tráfico y patrones sospechosos.
# ============================================================

set -euo pipefail
source ./scripts/lib.sh
load_config

REPORT_FILE="$REPORT_DIR/reporte_access.txt"
ensure_dir "$REPORT_DIR"
require_file "$ACCESS_LOG"

{
    echo "=== Reporte de access.log ==="
    echo "Fecha: $(date)"
    echo "Archivo analizado: $ACCESS_LOG"
    echo

    echo "1) Total de líneas del log"
    # TODO-14: Muestra el número total de líneas del access.log.
    # Pista: wc -l "$ACCESS_LOG"
    echo "TODO-14 pendiente"
    echo

    echo "2) Top 10 IPs con más peticiones"
    # TODO-15: Obtén la primera columna, ordena, cuenta y muestra el top 10.
    # Pista: awk '{print $1}' "$ACCESS_LOG" | sort | uniq -c | sort -nr | head
    echo "TODO-15 pendiente"
    echo

    echo "3) Códigos HTTP más frecuentes"
    # TODO-16: Extrae el código HTTP y cuenta ocurrencias.
    # Pista: En formato combined de Nginx, el campo $9 (separado por espacios) es el código HTTP.
    # Ejemplo: awk '{print $9}' "$ACCESS_LOG" | sort | uniq -c | sort -nr
    echo "TODO-16 pendiente"
    echo

    echo "4) Rutas sensibles detectadas"
    # TODO-17: Busca rutas como /.env, /phpmyadmin, /wp-login.php, /xmlrpc.php, /server-status, /admin.
    # Pista: grep -E "/\.env|phpmyadmin|wp-login\.php|xmlrpc\.php|server-status|/admin" "$ACCESS_LOG"
    echo "TODO-17 pendiente"
    echo

    echo "5) User agents sospechosos"
    # TODO-18: Busca sqlmap, Nikto, curl, masscan, python-requests, Go-http-client.
    # Pista: grep -iE "sqlmap|Nikto|curl/|masscan|python-requests|Go-http-client" "$ACCESS_LOG"
    # Nota: no todos los agentes tienen la misma cantidad de entradas. Reporta cuáles
    # encontraste y cuántas veces aparece cada uno.
    echo "TODO-18 pendiente"
    echo

    echo "6) Posibles SQL Injection"
    # TODO-19: Busca patrones como UNION, SELECT, OR%201=1, %27, --.
    echo "TODO-19 pendiente"
    echo

    echo "7) Posible path traversal"
    # TODO-20: Busca patrones como ../, %2e%2e, /etc/passwd.
    echo "TODO-20 pendiente"
    echo

    echo "8) Conclusión breve"
    # TODO-21: Escribe una conclusión automática basada en los hallazgos.
    echo "TODO-21 pendiente"
} | tee "$REPORT_FILE"

echo "Reporte generado en $REPORT_FILE"
