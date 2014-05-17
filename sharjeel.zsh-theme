# SSH session gets a different hostcolor
if [ -n "$SSH_CLIENT" ]; then
   export hostcolor=$fg[cyan]
else
   export hostcolor=$fg[green]
fi

ZSH_THEME_GIT_PROMPT_CLEAN=" ✔"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[blue]%}✘"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$hostcolor%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$hostcolor%}]"
DISABLE_UNTRACKED_FILES_DIRTY="true"

function prompt_char {
	if [ $UID -eq 0 ]; then echo "$fg[red]#"; else echo "$fg[blue]$"; fi
}

function host_prompt {
             IS_GIT=$(command git rev-parse --is-inside-work-tree 2> /dev/null)
             if [[ -n $IS_GIT ]]
             then
                echo "$(git_prompt_info)"
             else
                echo "%m"
             fi
}

PROMPT='%{$fg_bold[red]%}%n@%{$hostcolor%}$(host_prompt) %{$fg_bold[blue]%}%(!.%1~.%~) $(prompt_char)%{$reset_color%} '
