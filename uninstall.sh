#!/usr/bin/env bash
# TermGlow uninstaller
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
export TERMGlow_ROOT="$ROOT"
exec "$ROOT/bin/termglow" uninstall
