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

export PATH=~/bin/:~/.personalconfig/bin/:$PATH

