# Theme
ZSH_THEME="sharjeel"

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

# Alt-i inserts "sudo apt-get install " at the start of line
insert_apt_get_install () { zle beginning-of-line; zle -U "sudo apt-get install " }
zle -N insert-apt-get-install insert_apt_get_install
bindkey "^[i" insert-apt-get-install

# Al-z inserts glob
insert_glob () { zle -U "**/" }
zle -N insert-glob insert_glob
bindkey "^[z" insert-glob

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

export TERM=xterm-256color

# Enable zsh-autosuggestions
if [ -e ~/.zsh-autosuggestions/autosuggestions.zsh ]; then
   # Setup zsh-autosuggestions
   source ~/.zsh-autosuggestions/autosuggestions.zsh

   # Enable autosuggestions automatically
   zle-line-init() {
      zle autosuggest-start
   }
   zle -N zle-line-init

   # use ctrl+t to toggle autosuggestions(hopefully this wont be needed as
   # zsh-autosuggestions is designed to be unobtrusive)
   bindkey '^T' autosuggest-toggle
   export AUTOSUGGESTION_HIGHLIGHT_COLOR=fg=237
   export AUTOSUGGESTION_HIGHLIGHT_CURSOR=0
fi

export PATH=~/bin/:~/.personalconfig/bin/:$PATH

# Load personal aliases
source $SCRIPT_SOURCE/zshaliases.rc


