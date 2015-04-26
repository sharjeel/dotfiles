#!/bin/sh
# Used with emacsclient as alternate-editor. 
# Tries to instantiate an emacs instance with server running if
# DISPLAY is set. Otherwise spawns a normal emacs instance.
if [ -n "$SSH_CLIENT" ]; then
    emacs --daemon $*
    exit
fi

if [ -n "$DISPLAY" ]; then
    nohup emacs --eval '(server-start)' $* >/dev/null 2>&1 & 
else
    $EDITOR $*
fi

