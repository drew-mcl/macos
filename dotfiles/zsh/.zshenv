# shellcheck disable=SC1090,SC2155

# --- Keychain Secrets --------------------------------------------------------
# Load secrets from macOS Keychain into environment variables.
# Secrets are stored with service name "macos:<VAR_NAME>"
#
# To add a secret:   keychain-set GITHUB_PAT "your-token-here"
# To get a secret:   keychain-get GITHUB_PAT
# To list secrets:   keychain-list
# To remove a secret: keychain-rm GITHUB_PAT

# Secrets to load on shell start (add variable names here)
_KEYCHAIN_SECRETS=(
  GITHUB_PAT
)

# Load secrets silently - only exports if the secret exists
_load_keychain_secrets() {
  local service_prefix="macos"
  local var
  for var in "${_KEYCHAIN_SECRETS[@]}"; do
    local value
    value=$(security find-generic-password -a "$USER" -s "${service_prefix}:${var}" -w 2>/dev/null) || continue
    export "${var}=${value}"
  done
}

# Helper: Set a secret in Keychain
keychain-set() {
  local var="$1" value="$2"
  if [[ -z $var || -z $value ]]; then
    echo "Usage: keychain-set VAR_NAME value" >&2
    return 1
  fi
  # Delete existing entry if present (ignore errors)
  security delete-generic-password -a "$USER" -s "macos:${var}" 2>/dev/null || true
  # Add new entry
  security add-generic-password -a "$USER" -s "macos:${var}" -w "$value"
  echo "Stored ${var} in Keychain"
  # Also export immediately in current shell
  export "${var}=${value}"
}

# Helper: Get a secret from Keychain
keychain-get() {
  local var="$1"
  if [[ -z $var ]]; then
    echo "Usage: keychain-get VAR_NAME" >&2
    return 1
  fi
  security find-generic-password -a "$USER" -s "macos:${var}" -w 2>/dev/null
}

# Helper: Remove a secret from Keychain
keychain-rm() {
  local var="$1"
  if [[ -z $var ]]; then
    echo "Usage: keychain-rm VAR_NAME" >&2
    return 1
  fi
  security delete-generic-password -a "$USER" -s "macos:${var}" 2>/dev/null && \
    echo "Removed ${var} from Keychain" || \
    echo "Secret ${var} not found" >&2
}

# Helper: List all macos secrets in Keychain
keychain-list() {
  echo "Secrets in Keychain (macos:*):"
  security dump-keychain 2>/dev/null | grep -A4 '"macos:' | grep '"svce"' | \
    sed 's/.*"macos:\([^"]*\)".*/  \1/' | sort -u
}

# Load secrets on shell start
_load_keychain_secrets

# --- Editor -------------------------------------------------------------------
export EDITOR=nvim
export VISUAL=nvim

# --- Workstation Paths --------------------------------------------------------
export MACOS_SETUP="$HOME/repos/macos"
export OBSIDIAN_VAULT="$HOME/Documents/Obsidian"

# --- Claude Code Configuration ------------------------------------------------
export CLAUDE_CODE_ENABLE_TASKS=true
