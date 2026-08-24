#!/usr/bin/env bash
# Build-time only (invoked from the Dockerfile). Turns a plain "one domain
# per line" list into the nginx map entries used by $connect_allowed in
# nginx.conf. Each domain matches itself and any subdomain.
set -euo pipefail

INPUT="${1:?usage: generate-allowed-domains-map.sh <allowed-domains.conf> <output-file>}"
OUT="${2:?}"

: > "$OUT"

while IFS= read -r line || [ -n "$line" ]; do
    trimmed="$(printf '%s' "$line" | sed -e 's/^[[:space:]]*//')"
    [ -z "$trimmed" ] && continue
    [ "${trimmed#\#}" != "$trimmed" ] && continue

    domain="${line%%#*}"
    if [ "$domain" = "$line" ]; then
        comment=""
    else
        comment="${line#*#}"
        comment="$(printf '%s' "$comment" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    fi
    domain="$(printf '%s' "$domain" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [ -z "$domain" ] && continue

    escaped="$(printf '%s' "$domain" | sed 's/\./\\./g')"
    if [ -n "$comment" ]; then
        printf '"~*(^|\\.)%s$" 1; # %s\n' "$escaped" "$comment" >> "$OUT"
    else
        printf '"~*(^|\\.)%s$" 1;\n' "$escaped" >> "$OUT"
    fi
done < "$INPUT"
