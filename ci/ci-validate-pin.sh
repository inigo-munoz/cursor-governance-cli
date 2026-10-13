#!/usr/bin/env bash
# ci-validate-pin.sh — Validación del governance pin en CI/CD
#
# Uso en GitHub Actions / GitHub Actions:
#   ./ci-validate-pin.sh
#
# Exit codes:
#   0 = Pin válido
#   1 = Pin inválido o ausente

set -e

PIN_FILE=".cursor-governance.yml"

# ── Colores (desactivados en CI si no hay TTY) ───────────────────────
if [ -t 1 ]; then
  RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
else
  RED=''; GREEN=''; YELLOW=''; NC=''
fi

fail() { echo -e "${RED}ERROR:${NC} $1" >&2; exit 1; }
warn() { echo -e "${YELLOW}WARN:${NC}  $1"; }
ok()   { echo -e "${GREEN}OK:${NC}    $1"; }

echo "============================================================"
echo "  Governance — Validación de pin"
echo "============================================================"
echo ""

# 1. Archivo existe
[ -f "$PIN_FILE" ] || fail "No existe $PIN_FILE en $(pwd)
  El pin de governance es obligatorio en todos los proyectos 
  Ejecuta: cursor-governance init --stack <stack> --core <ver> --stack-version <ver>"

# 2. Campos obligatorios
for field in stack core stack_version; do
  grep -q "^${field}:" "$PIN_FILE" \
    || fail "Campo '$field' no encontrado en $PIN_FILE"
done

# 3. Extraer valores
STACK=$(grep "^stack:"         "$PIN_FILE" | cut -d: -f2 | tr -d '[:space:]')
CORE_VER=$(grep "^core:"      "$PIN_FILE" | cut -d: -f2 | tr -d '[:space:]')
STACK_VER=$(grep "^stack_version:" "$PIN_FILE" | cut -d: -f2 | tr -d '[:space:]')

# 4. Validar stack — familias y variantes conocidas
case "$STACK" in
  prestashop|prestashop7|prestashop8) ;;
  magento|magento22|magento24|magento248) ;;
  node|nodejs|nodejs20|nodejs22) ;;
  python|python3) ;;
  *)
    fail "Stack desconocido: '$STACK'
  Stacks válidos: prestashop8, prestashop7, magento24, nodejs22
  Actualiza el pin o añade el stack al registry de core."
    ;;
esac

# 5. Validar formato semver (vX.Y.Z o vX.Y.Z-pN)
SEMVER_REGEX="^v[0-9]+\.[0-9]+\.[0-9]+(-p[0-9]+)?$"

[[ "$CORE_VER"  =~ $SEMVER_REGEX ]] \
  || fail "Formato de versión core inválido: '$CORE_VER' (esperado: vX.Y.Z)"

[[ "$STACK_VER" =~ $SEMVER_REGEX ]] \
  || fail "Formato de stack_version inválido: '$STACK_VER' (esperado: vX.Y.Z)"

# 6. Comprobar que no hay valores vacíos
[ -n "$STACK" ]     || fail "Campo 'stack' está vacío"
[ -n "$CORE_VER" ]  || fail "Campo 'core' está vacío"
[ -n "$STACK_VER" ] || fail "Campo 'stack_version' está vacío"

# 7. Todo OK
echo ""
ok "Pin válido"
echo ""
echo "  Stack:          $STACK"
echo "  Core:           $CORE_VER"
echo "  Stack version:  $STACK_VER"
echo ""

exit 0
