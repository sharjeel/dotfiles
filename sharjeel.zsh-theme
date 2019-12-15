# SSH session gets a different hostcolor
if [ -n "$SSH_CLIENT" ]; then
   export hostcolor=$fg[cyan]
else
   export hostcolor=$fg[green]
fi

ZSH_GIT_DIRTY_CHECK_TIMEOUT="0.5s"
ZSH_THEME_GIT_PROMPT_CLEAN=" ✔"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[blue]%}✘"
ZSH_THEME_GIT_PROMPT_DIRTY_MAYBE=" %{$fg[blue]%}?"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$hostcolor%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$hostcolor%}]"
DISABLE_UNTRACKED_FILES_DIRTY="true"

function prompt_char {
	if [ $UID -eq 0 ]; then echo "$fg[red]#"; else echo "$fg[blue]$"; fi
}


# Checks if working tree is dirty, also add timeout
parse_git_dirty() {
  local STATUS=''
  local FLAGS
  FLAGS=('--porcelain')
  if [[ "$(command git config --get oh-my-zsh.hide-dirty)" != "1" ]]; then
    if [[ $POST_1_7_2_GIT -gt 0 ]]; then
      FLAGS+='--ignore-submodules=dirty'
    fi
    if [[ "$DISABLE_UNTRACKED_FILES_DIRTY" == "true" ]]; then
      FLAGS+='--untracked-files=no'
    fi
    STATUS=$(command timeout -s kill $ZSH_GIT_DIRTY_CHECK_TIMEOUT cat <(git status ${FLAGS} 2> /dev/null | tail -n1))
    if [ $? -ne 0 ]; then
      echo "$ZSH_THEME_GIT_PROMPT_DIRTY_MAYBE"
      return
    fi
  fi
  if [[ -n $STATUS ]]; then
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  else
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  fi
}

function host_prompt {
  IS_GIT=$(command git rev-parse --is-inside-work-tree 2> /dev/null)
  if [[ -n $IS_GIT ]]
  then
    echo "$(git_prompt_info)"
  else
    # echo "%m"
    hostname | cut -d"." -f2
  fi
}

function dir_prompt {
    echo "%(!.%1~.%~)"
}

PROMPT='%{$fg_bold[red]%}%n@%{$hostcolor%}$(host_prompt) %{$fg_bold[blue]%}$(dir_prompt) $(prompt_char)%{$reset_color%} '
