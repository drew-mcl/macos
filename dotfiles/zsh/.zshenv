# shellcheck disable=SC1090,SC2155

# --- Keychain Secrets --------------------------------------------------------
# Load secrets from macOS Keychain into environment variables.
# Secrets are stored with service name "laptop-setup:<VAR_NAME>"
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
  local service_prefix="laptop-setup"
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
  security delete-generic-password -a "$USER" -s "laptop-setup:${var}" 2>/dev/null || true
  # Add new entry
  security add-generic-password -a "$USER" -s "laptop-setup:${var}" -w "$value"
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
  security find-generic-password -a "$USER" -s "laptop-setup:${var}" -w 2>/dev/null
}

# Helper: Remove a secret from Keychain
keychain-rm() {
  local var="$1"
  if [[ -z $var ]]; then
    echo "Usage: keychain-rm VAR_NAME" >&2
    return 1
  fi
  security delete-generic-password -a "$USER" -s "laptop-setup:${var}" 2>/dev/null && \
    echo "Removed ${var} from Keychain" || \
    echo "Secret ${var} not found" >&2
}

# Helper: List all laptop-setup secrets in Keychain
keychain-list() {
  echo "Secrets in Keychain (laptop-setup:*):"
  security dump-keychain 2>/dev/null | grep -A4 '"laptop-setup:' | grep '"svce"' | \
    sed 's/.*"laptop-setup:\([^"]*\)".*/  \1/' | sort -u
}

# Load secrets on shell start
_load_keychain_secrets
