#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." &>/dev/null && pwd)"

fail() {
  printf "error: %s\n" "$1" >&2
  exit 1
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  fail "ObjectiveHUD is a macOS app. Detected OS: $(uname -s)"
fi

if ! command -v swift >/dev/null 2>&1; then
  cat >&2 <<'EOF'
error: `swift` not found.

Install Xcode (recommended) or Command Line Tools:
  - Xcode (App Store), then run once to accept the license
  - or: xcode-select --install

After install, verify:
  swift --version
EOF
  exit 1
fi

if command -v xcode-select >/dev/null 2>&1; then
  if ! xcode-select -p >/dev/null 2>&1; then
    cat >&2 <<'EOF'
error: Xcode Command Line Tools not configured.

Fix:
  xcode-select --install
EOF
    exit 1
  fi
fi

cd "${ROOT_DIR}"

printf "swift: %s\n" "$(swift --version | head -n 1)"
exec swift run ObjectiveHUD "$@"
