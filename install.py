"""Sharjeel's Scripts installation
Usage:
   install.py [ --all | PACKAGE ... ]
"""

import os
import sys
import fileinput
from os import path
from os.path import join as pathjoin

from docopt import docopt

def abspathjoin(a,b):
    return path.abspath(path.join(a,b)).replace('\\', '/')
CUR_DIR = path.split(path.abspath(__file__))[0]
HOME = os.environ.get("HOME")

def file_replace_line(filename, to_replace, replwith):
    """ Replace a line in file with another line 
    replline can be a substring or a pattern
    """
    replaced = False
    for line in fileinput.input(filename, inplace=True):
        if (callable(to_replace) and to_replace(line)) or \
                (not callable(to_replace) and to_replace in line):
            if callable(replwith):
                line = replwith(line)
            else:
                line = replwith
            replaced = True
        sys.stdout.write(line)

    return replaced

def file_replace_or_append(filename, to_replace, replwith, at_end=True):
    if not file_replace_line(filename, to_replace, replwith):
        if at_end:
            with open(filename, "a") as initel_file:
                initel_file.write(replwith + '\n')
        else:
            with file(filename, 'r') as original: data = original.read()
            with file(filename, 'w') as modified: 
                modified.write("%s\n%s" % (replwith, data))

    return True

def emacs():
    APPHOME = os.environ.get("APPDATA") if sys.platform == 'win32' else os.environ.get("HOME")
    initel = pathjoin(APPHOME, ".emacs.d", "init.el")
    emacs_dot_file = pathjoin(CUR_DIR, "emacs.init.el")
    repl_func = lambda x: "(load-file (expand-file-name" in x and "; sharjeels global init.el file" in x
    repl_string = '(load-file (expand-file-name "%s" )) ; sharjeels global init.el file' % emacs_dot_file
    file_replace_or_append(initel, repl_func, repl_string, at_end=False)

    print "Emacs linked"
    return True


def bashmarks():
    if sys.platform == 'win32':
        print "No bashmarks support for windows"
        return False

    BASHMARKS_FILE = pathjoin(HOME, ".sdirs")
    MY_BASHMARKS_DOT_FILE = pathjoin(CUR_DIR, "bashmarks.sdirs")
    file_replace_or_append(BASHMARKS_FILE, "source ", "source " + MY_BASHMARKS_DOT_FILE )
    
    print "Bashmarks linked"
    return True

if __name__ == '__main__':
    arguments = docopt(__doc__)
    
    if arguments['--all']:
        packages = ['emacs', 'bashmarks']
    else:
        packages = arguments.get('PACKAGE')

    for p in packages:
        globals()[p]()

