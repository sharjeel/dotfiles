# Theme
ZSH_THEME="gentoo"

# Enable Bashmarks
source ~/.local/bin/bashmarks.sh

SCRIPT_SOURCE=$(/bin/readlink -f ${0%/*})
source $SCRIPT_SOURCE/zshaliases.rc

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
export EDITOR="emacs --no-window"

export PATH=~/bin/:~/.personalconfig/bin/:$PATH
# TODO: change the color of the hostname based on the hostname
export PS1="%B%{$fg[red]%}%n@%{$fg[green]%}%m %{$fg[blue]%}%~ $ %{$reset_color%}% "