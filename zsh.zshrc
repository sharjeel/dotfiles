# Use Prezto
if [[ -d ~/.zprezto ]]; then
  source ~/.zprezto/init.sh
fi 

# Enable Bashmarks
source ~/.local/bin/bashmarks.sh

# Set browser for commandline
if [ "$(uname)" = "Darwin" ]; then
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

export BROWSER=$BROWSER

# History
SAVEHIST=10000
HISTSIZE=10000
setopt SHARE_HISTORY


# Alt-S inserts "sudo " at the start of line
insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

# Alt-g inserts pipe grep
insert_grep () { zle -U " | grep -B0 -A0 " }
zle -N insert-grep insert_grep
bindkey "^[g" insert-grep

# Alt-i inserts "sudo apt-get install " at the start of line
insert_apt_get_install () { zle beginning-of-line; zle -U "sudo apt-get install " }
zle -N insert-apt-get-install insert_apt_get_install
bindkey "^[i" insert-apt-get-install

# Alt-h inserts history search
insert_history_grep () { zle beginning-of-line; zle -U "history | grepi " }
zle -N insert-history-grep insert_history_grep
bindkey "^[h" insert-history-grep

# Al-z inserts glob
insert_glob () { zle -U "**/" }
zle -N insert-glob insert_glob
bindkey "^[z" insert-glob

# C-x C-l inserts the last line of the output of the last command
zmodload -i zsh/parameter
insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))] | tail -n1)"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

# cd into directory of a file
cdto () { cd `dirname $1`; }
csto () { cdto $(ack-grep --max-count=1 -l --local $1) }
# git diff between branches
gitdiff () { git diff $2 $1:$2; }
# show recent git branches
gitrecentbranches() { git for-each-ref --sort=-committerdate refs/heads/ }
alias git-recent-branches=gitrecentbranches

# Explain shell command
explain () {
        echo "This will send data to external server? Continue (y/n)? "
        read explain_decision
        [[ ( $explain_decision == "y" || $explain_decision == "Y" ) ]] && $BROWSER "http://explainshell.com/explain?cmd=$*" 
}

makeprint() {
    make --eval="print-%: ; @echo \$*=\$(\$*)" print-$*
}

# There is only one default editor in the world
export EDITOR="emacsclient -nw --alternate-editor=emacs"
# if [ -n "$SSH_CLIENT" ]; then
#    export EDITOR="emacs --no-window"
# else
#    export EDITOR="emacs"
# fi

export TERM=xterm-256color

# Enable zsh-autosuggestions
if [ -e ~/.zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
   # Setup zsh-autosuggestions
   source ~/.zsh-autosuggestions/zsh-autosuggestions.zsh

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

# gcloud
if [ -d $HOME/google-cloud-sdk/ ]; then
   # The next line updates PATH for the Google Cloud SDK.
   source "$HOME/google-cloud-sdk/path.zsh.inc"

   # The next line enables bash completion for gcloud.
   source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi


export PATH=~/bin/:~/.local/bin/:~/.personalconfig/bin/:$PATH

# Common bashmarks directories
export DIR_persconf="$HOME/.personalconfig"

# Load personal aliases
source ~/.personalconfig/zshaliases.rc

# g aliased intelligently to bashmark get or git
g () {
        if [ -z $1 ]; then
           cat ~/.sdirs
           if [ -e ~/.g4d ]; then
              cat ~/.g4d
           fi
           return
        fi

        source $SDIRS
        BASHMARK="$(eval $(echo echo $(echo \$DIR_$1)))"
        if [ -e $BASHMARK ]; then
           cd $BASHMARK
        else
           git "$@"
        fi
}

# e for editing with emacs in a single window
e () {
  if [[ -n "$DISPLAY" || ! -n "$SSH_CLIENT" ]]; then
     emacsclient --no-wait --alternate-editor="$HOME/.personalconfig/bin/emacsserv.sh" $@
  else
     emacsclient -nw --alternate-editor="$HOME/.personalconfig/bin/emacsserv.sh" $@
  fi
}

# Work or machine specific aliases
[[ -e ~/.xrc-work ]] && source ~/.xrc-work
[[ -e ~/.zshrc-work ]] && source ~/.zshrc-work

# Prefer to have .zshenv load ZSH aliases so they are available in IPython as well
# if not, load them here.
if ( [ ! -e ~/.zshenv ] || (! egrep -q "^source $HOME/.personalconfig/zshaliases.rc" ~/.zshenv)) {
  [[ -e ~/.personalconfig/zshaliases.rc ]] && source ~/.personalconfig/zshaliases.rc
}
if ( [ ! -e ~/.zshenv ] || (! egrep -q "^source $HOME/.zshaliases-work" ~/.zshenv)) {
  [[ -e ~/.zshaliases-work ]] && source ~/.zshaliases-work
}
