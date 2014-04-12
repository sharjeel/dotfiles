# Theme
ZSH_THEME="gentoo"

# Enable Bashmarks
source ~/.local/bin/bashmarks.sh

SCRIPT_SOURCE=$(/bin/readlink -f ${0%/*})

# Set browser for commandline
if [ "$(uname)" = "Linux" ]; then
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

# History
SAVEHIST=10000
HISTSIZE=10000
setopt SHARE_HISTORY


# Alt-S inserts "sudo " at the start of line
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

# cd into directory of a file
cdto () { cd `dirname $1`; }
# git diff between branches
gitdiff () { git diff $2 $1:$2; }

# There is only one default editor in the world
if [ -n "$SSH_CLIENT" ]; then
   export EDITOR="emacs --no-window"
else
   export EDITOR="emacs"
fi

export PATH=~/bin/:~/.personalconfig/bin/:$PATH
if [ -n "$SSH_CLIENT" ]; then
   hostcolor=$fg[cyan]
   # TODO: Different hostname color for different hostnames
else
   hostcolor=$fg[green]
fi
export PS1="%B%{$fg[red]%}%n@%{$fg[cyan]%}%m %{$fg[blue]%}%~ $ %{$reset_color%}% "

# Load personal aliases
source $SCRIPT_SOURCE/zshaliases.rc
