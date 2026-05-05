# Theme
ZSH_THEME="sharjeel"

# Enable Bashmarks
[[ -e ~/.local/bin/bashmarks.sh ]] && source ~/.local/bin/bashmarks.sh

# Set browser for commandline
if [ "$(uname)" = "Darwin" ]; then
    BROWSER=open
elif which google-chrome > /dev/null 2>&1; then
    BROWSER=google-chrome
elif which chromium-browser > /dev/null 2>&1; then
    BROWSER=chromium-browser
elif which firefox > /dev/null 2>&1; then
    BROWSER=firefox
else
    BROWSER=lynx
fi

export BROWSER=$BROWSER

# History
SAVEHIST=10000
HISTSIZE=10000
setopt SHARE_HISTORY


# Alt-S inserts "sudo " at the start of line
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

# Alt-g inserts pipe grep
insert_grep () { zle -U " | grep -B0 -A0 " }
zle -N insert-grep insert_grep
bindkey "^[g" insert-grep

# Alt-i inserts "sudo apt-get install " at the start of line
insert_apt_get_install () { zle beginning-of-line; zle -U "sudo apt-get install " }
zle -N insert-apt-get-install insert_apt_get_install
bindkey "^[i" insert-apt-get-install

# Alt-h inserts history search
insert_history_grep () { zle beginning-of-line; zle -U "history | grepi " }
zle -N insert-history-grep insert_history_grep
bindkey "^[h" insert-history-grep

# Al-z inserts glob
insert_glob () { zle -U "**/" }
zle -N insert-glob insert_glob
bindkey "^[z" insert-glob

# C-x C-l inserts the last line of the output of the last command
zmodload -i zsh/parameter
insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))] | tail -n1)"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

# cd into directory of a file
cdto () { cd `dirname $1`; }
csto () { cdto $(ack-grep --max-count=1 -l --local $1) }
# git diff between branches
gitdiff () { git diff $2 $1:$2; }
# show recent git branches
gitrecentbranches() { git for-each-ref --sort=-committerdate refs/heads/ }
alias git-recent-branches=gitrecentbranches

# Explain shell command
explain () {
        echo "This will send data to external server? Continue (y/n)? "
        read explain_decision
        [[ ( $explain_decision == "y" || $explain_decision == "Y" ) ]] && $BROWSER "http://explainshell.com/explain?cmd=$*" 
}

makeprint() {
    make --eval="print-%: ; @echo \$*=\$(\$*)" print-$*
}

# There is only one default editor in the world
export EDITOR="emacsclient -nw --alternate-editor=emacs"
# if [ -n "$SSH_CLIENT" ]; then
#    export EDITOR="emacs --no-window"
# else
#    export EDITOR="emacs"
# fi

export TERM=xterm-256color

# Enable zsh-autosuggestions only when explicitly requested.
# Use: ZSH_AUTOSUGGEST_ENABLED=1 zsh -l
if [ -e ~/.zsh-autosuggestions/zsh-autosuggestions.zsh ] && [[ "${ZSH_AUTOSUGGEST_ENABLED:-0}" == "1" ]]; then
   # Setup zsh-autosuggestions
   source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh

   # use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
   # zsh-autosuggestions is designed to be unobtrusive)
   bindkey '^T' autosuggest-toggle
   # export AUTOSUGGESTION_HIGHLIGHT_COLOR=fg=237
   # export AUTOSUGGESTION_HIGHLIGHT_CURSOR=0
   ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=237'
fi

# gcloud
if [ -d $HOME/google-cloud-sdk/ ]; then
   # The next line updates PATH for the Google Cloud SDK.
   source "$HOME/google-cloud-sdk/path.zsh.inc"

   # The next line enables bash completion for gcloud.
   source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi



[[ -e ~/.personalconfig/ai.zsh ]] && source ~/.personalconfig/ai.zsh
export PATH=~/bin/:~/.local/bin/:~/.personalconfig/bin/:$PATH

# Common bashmarks directories
export DIR_persconf="$HOME/.personalconfig"

# Load personal aliases
[[ -e ~/.personalconfig/zshaliases.custom.zsh ]] && source ~/.personalconfig/zshaliases.custom.zsh

# g aliased intelligently to bashmark get or git
unalias g 2>/dev/null
g () {
        if [ -z $1 ]; then
           cat ~/.sdirs
           if [ -e ~/.g4d ]; then
              cat ~/.g4d
           fi
           return
        fi

        source $SDIRS
        BASHMARK="$(eval $(echo echo $(echo \$DIR_$1)))"
        if [ -e $BASHMARK ]; then
           cd $BASHMARK
        else
           git "$@"
        fi
}

# Work or machine specific aliases
[[ -e ~/.xrc-work ]] && source ~/.xrc-work
[[ -e ~/.zshrc-work ]] && source ~/.zshrc-work

# Prefer to have .zshenv load ZSH aliases so they are available in IPython as well
# if not, load them here.
if ( [ ! -e ~/.zshenv ] || (! egrep -q "^source $HOME/.personalconfig/zshaliases.custom.zsh" ~/.zshenv)) {
  [[ -e ~/.personalconfig/zshaliases.custom.zsh ]] && source ~/.personalconfig/zshaliases.custom.zsh
}
if ( [ ! -e ~/.zshenv ] || (! egrep -q "^source $HOME/.zshaliases-work" ~/.zshenv)) {
  [[ -e ~/.zshaliases-work ]] && source ~/.zshaliases-work
}

setup_fallback_prompt() {
  setopt PROMPT_SUBST

  typeset -g fallback_host_color="%F{green}"
  if [[ -n "$SSH_CLIENT" ]]; then
    fallback_host_color="%F{cyan}"
  fi

  fallback_prompt_char() {
    if [[ "$UID" -eq 0 ]]; then
      print -r -- "%F{red}#"
    else
      print -r -- "%F{blue}$"
    fi
  }

  fallback_git_prompt() {
    (( $+commands[git] )) || return 1
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 1

    local branch dirty git_status
    branch="$(command git symbolic-ref --quiet --short HEAD 2>/dev/null \
      || command git rev-parse --short HEAD 2>/dev/null)" || return 1

    if (( $+commands[timeout] )); then
      git_status="$(command timeout -s kill 0.5s git status --porcelain --untracked-files=no 2>/dev/null | tail -n1)"
      if [[ "$?" -ne 0 ]]; then
        dirty="%F{blue}?"
      fi
    else
      git_status="$(command git status --porcelain --untracked-files=no 2>/dev/null | tail -n1)"
    fi

    if [[ -z "$dirty" ]]; then
      if [[ -n "$git_status" ]]; then
        dirty="%F{blue}x"
      else
        dirty="%F{green}+"
      fi
    fi

    print -r -- "${fallback_host_color}[${branch} ${dirty}${fallback_host_color}]"
  }

  fallback_host_prompt() {
    fallback_git_prompt || print -r -- "${fallback_host_color}%m"
  }

  fallback_dir_prompt() {
    print -r -- "%(!.%1~.%~)"
  }

  PROMPT='%F{red}%n@$(fallback_host_prompt) %F{blue}$(fallback_dir_prompt) $(fallback_prompt_char)%f '
}

# Use Prezto when installed; otherwise use a small built-in prompt.
if [[ -f ~/.zprezto/init.zsh ]]; then
  zstyle ':prezto:module:prompt' theme 'skwp'
  if [[ -d "${ZDOTDIR:-$HOME}/.zprezto/runcoms" ]]; then
    for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/z*; do
      if [[ ! -e "${ZDOTDIR:-$HOME}/.${rcfile:t}" ]]; then
        ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
      fi
    done
  fi
  source ~/.zprezto/init.zsh
else
  setup_fallback_prompt
fi

# Keep syntax-highlighting last for better widget integration.
if [ -e ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
   source ~/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
   typeset -gA ZSH_HIGHLIGHT_STYLES
   ZSH_HIGHLIGHT_STYLES[command]='fg=green'
   ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
fi

# aichat specific features
# ALT-E to do zsh completion
# aiselect command to change models
if (( $+commands[aichat] )); then
    _aichat_zsh() {
        if [[ -n "$BUFFER" ]]; then
            local _old=$BUFFER
            BUFFER+="⌛"
            zle -I && zle redisplay
            BUFFER=$(aichat -e "$_old")
            zle end-of-line
        fi
    }
    zle -N _aichat_zsh
    bindkey '\ee' _aichat_zsh

    AICHAT_CONFIG_FILE="${HOME}/.config/aichat/config.yaml"

    aiselect() {
	local config_file="${AICHAT_CONFIG_FILE:-$HOME/.config/aichat/config.yaml}"

	if [[ ! -f "$config_file" ]]; then
	    echo "Config file not found: $config_file" >&2
	    return 1
	fi

	if ! command -v yq >/dev/null 2>&1; then
	    echo "yq is required" >&2
	    return 1
	fi

	if ! command -v fzf >/dev/null 2>&1; then
	    echo "fzf is required" >&2
	    return 1
	fi

	local current_model
	current_model="$(yq -r '.model // ""' "$config_file")"

	local selected
	selected="$(
    yq -r '.clients[].models[].name' "$config_file" \
      | awk 'NF && !seen[$0]++' \
      | fzf --prompt="aichat model > " --header="Current: ${current_model}"
  )" || return 0

	[[ -z "$selected" ]] && return 0

	yq -i -y '.model = "ollama:'"$selected"'"' "$config_file" || {
	    echo "Failed to update model in $config_file" >&2
	    return 1
	}

	echo "Updated default model to: ollama:$selected"
    }

fi
