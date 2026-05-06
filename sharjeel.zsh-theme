#
# Sharjeel's prompt — works as oh-my-zsh theme, prezto theme, and standalone.
#
# Symlinked into prezto's prompt fpath as `prompt_sharjeel_setup`. When sourced
# directly (oh-my-zsh, fallback), the trailing call below sets PROMPT.
#
# Visuals:
# - Bold red `user@`, hostname segment in green (cyan when SSH'ed in)
# - Inside a git work tree, the hostname becomes `[branch <marker>]`:
#     ✔ clean   ✘ dirty (blue)   ? dirty-check timed out (blue)
# - Bold blue cwd, then `$` (blue) or `#` (red, root)
#

# OMZ pre-loads $fg / $fg_bold; prezto and bare zsh do not.
if [[ -z "${fg[red]:-}" ]]; then
  autoload -Uz colors && colors
fi

# Required so $(...) in PROMPT is evaluated each redraw (OMZ sets this
# already; prezto honors $prompt_opts; bare zsh needs it explicit).
setopt PROMPT_SUBST

ZSH_GIT_DIRTY_CHECK_TIMEOUT="${ZSH_GIT_DIRTY_CHECK_TIMEOUT:-0.5s}"
DISABLE_UNTRACKED_FILES_DIRTY="${DISABLE_UNTRACKED_FILES_DIRTY:-true}"

ZSH_THEME_GIT_PROMPT_CLEAN=" ✔"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[blue]%}✘"
ZSH_THEME_GIT_PROMPT_DIRTY_MAYBE=" %{$fg[blue]%}?"

prompt_sharjeel_dirty() {
  local flags=(--porcelain --ignore-submodules=dirty)
  [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]] && flags+=(--untracked-files=no)

  local out rc
  if (( $+commands[timeout] )); then
    out="$(command timeout -s kill "$ZSH_GIT_DIRTY_CHECK_TIMEOUT" \
      git status "${flags[@]}" 2>/dev/null | tail -n1)"
    rc=$?
  else
    out="$(command git status "${flags[@]}" 2>/dev/null | tail -n1)"
    rc=$?
  fi

  if (( rc != 0 )); then
    print -r -- "$ZSH_THEME_GIT_PROMPT_DIRTY_MAYBE"
  elif [[ -n "$out" ]]; then
    print -r -- "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    print -r -- "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

prompt_sharjeel_host_segment() {
  if (( $+commands[git] )) && command git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local branch
    branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null \
      || command git rev-parse --short HEAD 2>/dev/null)"
    print -r -- "%{$hostcolor%}[${branch}$(prompt_sharjeel_dirty)%{$hostcolor%}]"
  else
    hostname | cut -d. -f2
  fi
}

prompt_sharjeel_char() {
  if (( UID == 0 )); then
    print -r -- "%{$fg[red]%}#"
  else
    print -r -- "%{$fg[blue]%}$"
  fi
}

prompt_sharjeel_setup() {
  setopt LOCAL_OPTIONS
  unsetopt XTRACE KSH_ARRAYS
  prompt_opts=(cr percent sp subst)

  if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
    typeset -g hostcolor="$fg[cyan]"
  else
    typeset -g hostcolor="$fg[green]"
  fi

  ZSH_THEME_GIT_PROMPT_PREFIX="%{$hostcolor%}["
  ZSH_THEME_GIT_PROMPT_SUFFIX="%{$hostcolor%}]"

  PROMPT='%{$fg_bold[red]%}%n@%{$hostcolor%}$(prompt_sharjeel_host_segment) %{$fg_bold[blue]%}%(!.%1~.%~) $(prompt_sharjeel_char)%{$reset_color%} '
  RPROMPT=''
}

prompt_sharjeel_setup "$@"
