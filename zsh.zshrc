# Theme
ZSH_THEME="gentoo"

# Enable Bashmarks
source ~/.local/bin/bashmarks.sh

# Aliases
alias grep='grep --color=auto'
alias wemacs='emacs -nw'
alias fif='~/.personalconfig/scripts.py fif'
alias hilite='~/.personalconfig/scripts.py hilite'
alias sjava='ack-grep -i --java'
alias spython='ack-grep -i --python'
alias sxml='ack-grep -i --xml'

# History
SAVEHIST=10000
HISTSIZE=10000
setopt SHARE_HISTORY

# Alias suffixes
alias -s el=emacs
alias -s html=google-chrome

# Alt-S inserts "sudo " at the start of line
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

export PATH=~/bin/:~/.personalconfig/bin/:$PATH

