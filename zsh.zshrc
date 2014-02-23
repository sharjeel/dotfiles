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
alias reloadzsh=". ~/.zshrc && echo 'ZSH config reloaded from ~/.zshrc'"

# Alias suffixes
alias -s el=emacs

if which google-chrome > /dev/null 2>&1; then
    alias -s html=google-chrome
elif which chromium-browser > /dev/null 2>&1; then
    alias -s html=chromium-browser
else
    alias -s html=firefox
fi


# Alt-S inserts "sudo " at the start of line
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

export PATH=~/bin/:~/.personalconfig/bin/:$PATH

