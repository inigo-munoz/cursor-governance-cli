# rulesets/prestashop/security_patterns.sh
# PrestaShop security pattern detection for governance validation.
# Sourced by the CLI skill runner. Outputs one finding per line.
# Do not depend on CLI internals; only receive file path and echo findings.

detect_sql_injection() {
  local file="$1"
  grep -E "SELECT.*\$_(GET|POST)" "$file" 2>/dev/null >/dev/null && echo "SQL injection risk"
}

detect_missing_input_validation() {
  local file="$1"
  grep -E "\$_(GET|POST)" "$file" 2>/dev/null >/dev/null && echo "missing input validation"
}

run_security_patterns() {
  local file="$1"
  [ -z "$file" ] || [ ! -f "$file" ] && return
  detect_sql_injection "$file"
  detect_missing_input_validation "$file"
}
