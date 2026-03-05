#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-dotfiles-smoke:local}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MODE="${1:-test}"
APT_LISTS_VOLUME="${APT_LISTS_VOLUME:-dotfiles-apt-lists}"
APT_CACHE_VOLUME="${APT_CACHE_VOLUME:-dotfiles-apt-cache}"

if ! command -v podman >/dev/null 2>&1; then
  echo "podman is required for this smoke test" >&2
  exit 1
fi

if ! podman info >/dev/null 2>&1; then
  echo "podman is installed but not ready (try: podman machine init && podman machine start)" >&2
  exit 1
fi

usage() {
  cat <<'EOF'
Usage:
  ./test/container-smoke.sh build   # Build/rebuild the test image
  ./test/container-smoke.sh test    # Run automated idempotency smoke checks
  ./test/container-smoke.sh shell   # Open interactive shell with dotfiles mounted
EOF
}

build_image() {
  echo "[smoke] building $IMAGE_TAG"
  podman build -f "$SCRIPT_DIR/Dockerfile.smoke" -t "$IMAGE_TAG" "$SCRIPT_DIR"
}

run_test() {
  build_image
  echo "[smoke] running automated checks"
  podman run --rm \
    -e HOME=/tmp/testhome \
    -v "$REPO_DIR:/tmp/testhome/.personalconfig" \
    "$IMAGE_TAG" \
    bash -lc '
      set -euo pipefail
      mkdir -p "$HOME/.emacs.d"
      touch "$HOME/.zpreztorc"
      bash "$HOME/.personalconfig/install.sh"
      bash "$HOME/.personalconfig/install.sh"

      command -v zsh >/dev/null
      test -L "$HOME/.tmux.conf"
      test "$(readlink "$HOME/.tmux.conf")" = "$HOME/.personalconfig/tmux.conf"
      test -L "$HOME/.ackrc"
      test "$(readlink "$HOME/.ackrc")" = "$HOME/.personalconfig/ack.ackrc"
      grep -q "source $HOME/.personalconfig/zshrc.custom.zsh" "$HOME/.zshrc"
      grep -q "source $HOME/.personalconfig/bashmarks.sdirs" "$HOME/.sdirs"
      grep -q "emacs.init.el" "$HOME/.emacs.d/init.el"
      grep -q "theme '\''skwp'\''" "$HOME/.zpreztorc"
      echo "PASS: automated smoke checks"
    '
}

run_shell() {
  build_image
  echo "[smoke] starting interactive shell"
  podman run --rm -it \
    -e HOME=/tmp/testhome \
    -v "$REPO_DIR:/tmp/testhome/.personalconfig" \
    -v "$APT_LISTS_VOLUME:/var/lib/apt/lists" \
    -v "$APT_CACHE_VOLUME:/var/cache/apt" \
    -w /tmp/testhome/.personalconfig \
    "$IMAGE_TAG" \
    bash -lc '
      set -e
      mkdir -p "$HOME/.emacs.d"
      bash "$HOME/.personalconfig/install.sh" || true
      echo "Container ready."
      echo "Repo: $HOME/.personalconfig"
      echo "Home: $HOME"
      echo "APT cache volumes: /var/lib/apt/lists and /var/cache/apt are persisted"
      echo "Try: bash $HOME/.personalconfig/install.sh"
      exec bash
    '
}

case "$MODE" in
  build)
    build_image
    ;;
  test)
    run_test
    ;;
  shell)
    run_shell
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    echo "unknown mode: $MODE" >&2
    usage >&2
    exit 2
    ;;
esac
