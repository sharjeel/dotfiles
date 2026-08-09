#!/bin/sh

# Check if emacsclient is available
if command -v emacsclient >/dev/null 2>&1; then
    exec emacsclient -nw --alternate-editor=emacs "$@"

# Fallback to standard emacs if emacsclient is missing
elif command -v emacs >/dev/null 2>&1; then
    exec emacs -nw "$@"

# Ultimate fallback to nano if no emacs is found
elif command -v nano >/dev/null 2>&1; then
    exec nano "$@"

# Absolute last resort: vi (guaranteed to exist on every Unix system)
else
    exec vi "$@"
fi
