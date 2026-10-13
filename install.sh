#!/usr/bin/env bash
# install.sh — Instalador del CLI cursor-governance
#
# Uso:
#   ./install.sh
#
# Qué hace:
#   - Verifica que Cursor está instalado
#   - Copia bin/cursor-governance a ~/.local/bin
#   - Ajusta permisos
#   - Añade ~/.local/bin al PATH si no está
#   - Configura ~/.gitignore_global
#   - Configura git core.excludesfile
#
# Qué NO hace:
#   - No clona el catálogo local de governance
#   - Eso lo hace luego: cursor-governance install

set -euo pipefail

INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
CLI_NAME="cursor-governance"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_BIN="$SCRIPT_DIR/bin/$CLI_NAME"
TARGET_BIN="$INSTALL_DIR/$CLI_NAME"
GITIGNORE_GLOBAL="$HOME/.gitignore_global"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1" >&2; }

# Valida que un comando requerido existe
require_command() {
  local cmd="$1"
  if ! command -v "$cmd" >/dev/null 2>&1; then
    log_error "Comando requerido no encontrado: $cmd"
    exit 1
  fi
}

# Añade una línea a un archivo solo si no existe ya
append_if_missing() {
  local line="$1"
  local file="$2"
  touch "$file"
  if ! grep -qxF "$line" "$file" 2>/dev/null; then
    echo "$line" >> "$file"
    return 0  # añadido
  fi
  return 1    # ya existía
}

# Detecta el archivo RC del shell activo
detect_shell_rc() {
  local shell_name
  shell_name="$(basename "${SHELL:-}")"
  case "$shell_name" in
    bash) echo "$HOME/.bashrc" ;;
    zsh)  echo "$HOME/.zshrc" ;;
    fish) echo "$HOME/.config/fish/config.fish" ;;
    *)
      if   [ -f "$HOME/.bashrc" ];   then echo "$HOME/.bashrc"
      elif [ -f "$HOME/.zshrc" ];    then echo "$HOME/.zshrc"
      else                                echo "$HOME/.profile"
      fi
      ;;
  esac
}

# Verifica si Cursor está instalado en ubicaciones conocidas
check_cursor() {
  command -v cursor >/dev/null 2>&1                    && return 0
  [ -d "/Applications/Cursor.app" ]                   && return 0
  [ -f "$HOME/.local/bin/cursor" ]                     && return 0
  [ -f "/usr/bin/cursor" ]                             && return 0
  [ -f "/usr/local/bin/cursor" ]                       && return 0
  [ -d "$HOME/snap/cursor" ]                           && return 0
  ls "$HOME"/Cursor*.AppImage 2>/dev/null | grep -q . && return 0
  return 1
}

# ── Inicio ───────────────────────────────────────────────────────────

echo "============================================================"
echo "  Instalador de Governance CLI"
echo "============================================================"
echo ""

# 1. Verificar dependencias
require_command git
require_command cp
require_command chmod
require_command mkdir

# 2. Verificar que Cursor está instalado
if ! check_cursor; then
  echo ""
  log_error "Cursor no está instalado."
  echo ""
  echo "  La governance requiere Cursor para funcionar."
  echo "  Descárgalo desde: https://cursor.com"
  echo ""
  echo "  Una vez instalado, vuelve a ejecutar este instalador."
  echo ""
  exit 1
fi
log_ok "Cursor detectado"

# 3. Verificar que el binario fuente existe
if [ ! -f "$SOURCE_BIN" ]; then
  log_error "No se encontró el ejecutable fuente: $SOURCE_BIN"
  exit 1
fi

# 4. Instalar el binario
mkdir -p "$INSTALL_DIR"
log_ok "Directorio de instalación listo: $INSTALL_DIR"

cp "$SOURCE_BIN" "$TARGET_BIN"
chmod +x "$TARGET_BIN"
log_ok "CLI instalado en: $TARGET_BIN"

# 5. Gestionar PATH
if echo ":$PATH:" | grep -q ":$INSTALL_DIR:"; then
  log_ok "$INSTALL_DIR ya está en PATH"
else
  RC_FILE="$(detect_shell_rc)"
  log_warn "$INSTALL_DIR no está en tu PATH — añadiéndolo automáticamente..."

  case "$(basename "${SHELL:-}")" in
    fish) PATH_LINE='set -gx PATH $HOME/.local/bin $PATH' ;;
    *)    PATH_LINE='export PATH="$HOME/.local/bin:$PATH"' ;;
  esac

  if append_if_missing "$PATH_LINE" "$RC_FILE"; then
    log_ok "PATH añadido a $RC_FILE"
  else
    log_ok "La entrada PATH ya existía en $RC_FILE"
  fi

  # Exportar para la sesión actual — el CLI funciona sin abrir terminal nueva
  export PATH="$INSTALL_DIR:$PATH"
  log_ok "PATH activo en esta sesión"

  echo ""
  echo "  Para sesiones futuras ejecuta:"
  echo "  source \"$RC_FILE\""
  echo ""
fi

# 6. Configurar gitignore global
echo ""
log_info "Configurando gitignore global..."

changed=false
append_if_missing '.cursor/'                      "$GITIGNORE_GLOBAL" && changed=true
append_if_missing '.cursor-governance.yml.generated' "$GITIGNORE_GLOBAL" && changed=true

git config --global core.excludesfile "$GITIGNORE_GLOBAL"

if [ "$changed" = true ]; then
  log_ok "Gitignore global actualizado: $GITIGNORE_GLOBAL"
else
  log_ok "Gitignore global ya estaba configurado"
fi

# 7. Verificar que el binario instalado responde
echo ""
log_info "Verificando instalación..."
if "$TARGET_BIN" --version >/dev/null 2>&1 || "$TARGET_BIN" help >/dev/null 2>&1; then
  log_ok "CLI operativo"
else
  log_warn "El CLI se instaló pero no responde. Puede que necesites reabrir la terminal."
fi

echo ""
echo "============================================================"
echo "  INSTALACIÓN COMPLETADA"
echo "============================================================"
echo ""
echo "Próximos pasos:"
echo "  1. source \"$(detect_shell_rc)\"         # activar PATH en futuras sesiones"
echo "  2. cursor-governance install              # Instalar catálogo de stacks:"
echo "                                          #   1) PrestaShop 8.x"
echo "                                          #   2) PrestaShop 7.x [legacy]"
echo "                                          #   3) Magento 2.4"
echo "                                          #   4) Node.js 22.x LTS"
echo "  3. cursor-governance doctor               # Verificar instalación"
echo "  4. cd /tu/proyecto"
echo "  5. cursor-governance apply                # Aplicar gobernanza"
echo ""
echo "Si es proyecto nuevo:"
echo "  cursor-governance init --stack prestashop8 --core v2.2.0 --stack-version v2.4.0"
echo ""
