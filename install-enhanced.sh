#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=0

for arg in "$@"; do
  if [[ "$arg" == "--dry-run" ]]; then
    DRY_RUN=1
    break
  fi
done

echo "[enhanced] running core dotfiles installer"
if [[ "$DRY_RUN" -eq 1 ]]; then
  bash "$REPO_DIR/install.sh" --dry-run
else
  bash "$REPO_DIR/install.sh"
fi

echo "[enhanced] running optional tooling installer"
bash "$REPO_DIR/install-optional.sh" "$@"

echo "[enhanced] complete"
