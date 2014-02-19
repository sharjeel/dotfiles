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

# Alias suffixes
alias -s el=emacs
alias -s html=google-chrome



export PATH=~/bin/:~/.personalconfig/bin/:$PATH

