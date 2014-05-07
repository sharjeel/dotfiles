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


function prompt_char {
	if [ $UID -eq 0 ]; then echo "$fg[red]#"; else echo "$fg[blue]$"; fi
}

function host_prompt {
             GIT_STATUS=$(command git status -s ${SUBMODULE_SYNTAX} 2> /dev/null | tail -n1)
             if [[ -n $GIT_STATUS ]]
             then
                echo "$(git_prompt_info)"
             else
                echo "%m"
             fi
}

PROMPT='%{$fg_bold[red]%}%n@%{$hostcolor%}$(host_prompt) %{$fg_bold[blue]%}%(!.%1~.%~) $(prompt_char)%{$reset_color%} '
