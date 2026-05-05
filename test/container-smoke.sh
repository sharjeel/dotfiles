#!/usr/bin/env bash
set -euo pipefail

IMAGE_TAG="${IMAGE_TAG:-dotfiles-smoke:local}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "$SCRIPT_DIR/.." && pwd)"
MODE="${1:-test}"
SMOKE_USER="${SMOKE_USER:-sharjeeltest}"
SMOKE_HOME="/home/$SMOKE_USER"
SMOKE_HOSTNAME="${SMOKE_HOSTNAME:-dotfiles-smoke}"
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
  ./test/container-smoke.sh test-optional
                                    # Run smoke checks including zsh optional add-ons
  ./test/container-smoke.sh shell   # Open interactive shell with dotfiles mounted
  ./test/container-smoke.sh shell-optional
                                    # Open shell after installing zsh optional add-ons
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
    --hostname "$SMOKE_HOSTNAME" \
    -e HOME="$SMOKE_HOME" \
    -e USER="$SMOKE_USER" \
    -e LOGNAME="$SMOKE_USER" \
    -e SMOKE_USER="$SMOKE_USER" \
    -e SHELL=/usr/bin/zsh \
    -v "$REPO_DIR:$SMOKE_HOME/.personalconfig" \
    "$IMAGE_TAG" \
    bash -lc '
      set -euo pipefail
      test "$(id -u)" -ne 0
      test "$(id -un)" = "$SMOKE_USER"
      test "$SHELL" = /usr/bin/zsh
      mkdir -p "$HOME/.emacs.d"
      touch "$HOME/.zpreztorc"
      bash "$HOME/.personalconfig/install.sh"
      bash "$HOME/.personalconfig/install.sh"

      command -v zsh >/dev/null
      zsh -lic "true"
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

run_test_optional() {
  build_image
  echo "[smoke] running optional zsh checks"
  podman run --rm \
    --hostname "$SMOKE_HOSTNAME" \
    -e HOME="$SMOKE_HOME" \
    -e USER="$SMOKE_USER" \
    -e LOGNAME="$SMOKE_USER" \
    -e SMOKE_USER="$SMOKE_USER" \
    -e SHELL=/usr/bin/zsh \
    -v "$REPO_DIR:$SMOKE_HOME/.personalconfig" \
    "$IMAGE_TAG" \
    bash -lc '
      set -euo pipefail
      test "$(id -u)" -ne 0
      test "$(id -un)" = "$SMOKE_USER"
      mkdir -p "$HOME/.emacs.d"
      bash "$HOME/.personalconfig/install.sh"
      bash "$HOME/.personalconfig/install-optional.sh" --only-zsh --skip-chsh
      bash "$HOME/.personalconfig/install-optional.sh" --only-zsh --skip-chsh

      test -f "$HOME/.zprezto/init.zsh"
      test -d "$HOME/.zsh-syntax-highlighting"
      test -d "$HOME/.zsh-autosuggestions"
      grep -q "theme '\''skwp'\''" "$HOME/.zpreztorc"
      zsh -lic "true"
      echo "PASS: optional zsh smoke checks"
    '
}

run_shell() {
  local with_optional="${1:-0}"
  build_image
  echo "[smoke] starting interactive shell"
  podman run --rm -it \
    --hostname "$SMOKE_HOSTNAME" \
    -e HOME="$SMOKE_HOME" \
    -e USER="$SMOKE_USER" \
    -e LOGNAME="$SMOKE_USER" \
    -e SMOKE_USER="$SMOKE_USER" \
    -e SMOKE_WITH_OPTIONAL="$with_optional" \
    -e SHELL=/usr/bin/zsh \
    -v "$REPO_DIR:$SMOKE_HOME/.personalconfig" \
    -v "$APT_LISTS_VOLUME:/var/lib/apt/lists" \
    -v "$APT_CACHE_VOLUME:/var/cache/apt" \
    -w "$SMOKE_HOME/.personalconfig" \
    "$IMAGE_TAG" \
    bash -lc '
      set -e
      mkdir -p "$HOME/.emacs.d"
      bash "$HOME/.personalconfig/install.sh" || true
      if [[ "${SMOKE_WITH_OPTIONAL:-0}" == "1" ]]; then
        bash "$HOME/.personalconfig/install-optional.sh" --only-zsh --skip-chsh || true
      fi
      echo "Container ready."
      echo "User: $(id -un) ($(id -u))"
      echo "Host: $(hostname)"
      echo "Repo: $HOME/.personalconfig"
      echo "Home: $HOME"
      echo "APT cache volumes: /var/lib/apt/lists and /var/cache/apt are persisted"
      echo "Try: bash $HOME/.personalconfig/install.sh"
      echo "Try: bash $HOME/.personalconfig/install-optional.sh --only-zsh --skip-chsh"
      exec zsh -l
    '
}

case "$MODE" in
  build)
    build_image
    ;;
  test)
    run_test
    ;;
  test-optional)
    run_test_optional
    ;;
  shell)
    run_shell 0
    ;;
  shell-optional)
    run_shell 1
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
