# Shared AI shell helpers

aiinit() {
  ~/.personalconfig/bin/ai-init "${1:-.}"
}

aictx() {
  local root="${1:-$PWD}"
  printf 'AI context files under %s\n' "$root"
  find "$root" -maxdepth 3 \
    \( -name 'AGENTS.md' -o -name 'CLAUDE.md' -o -name 'GEMINI.md' -o -path '*/.gemini/settings.json' \) \
    -print \
    | sort
}

airun() {
  local tools=()
  local tool

  for tool in claude gemini codex aichat; do
    (( $+commands[$tool] )) && tools+=("$tool")
  done

  if [[ "${#tools[@]}" -eq 0 ]]; then
    echo "No supported AI CLI found in PATH" >&2
    return 1
  fi

  if (( $+commands[fzf] )); then
    tool="$(printf '%s\n' "${tools[@]}" | fzf --prompt='ai cli > ')" || return 0
  else
    tool="${tools[1]}"
  fi

  [[ -n "$tool" ]] || return 0
  "$tool" "${@:1}"
}
