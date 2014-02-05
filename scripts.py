#!/usr/bin/python
import os
import sys
from subprocess import call, PIPE, Popen

DEBUG = False

def find_in_files(files_pattern, search_string, after_lines="0", before_lines="0"):
    # TODO: Write help menu
    if files_pattern.startswith("."):
        files_pattern = "*" + files_pattern
    elif not files_pattern.endswith("*"):
        files_pattern = files_pattern + "*"
    if not files_pattern.startswith("*"):
        files_pattern = "*" + files_pattern
    
    arr = ["/bin/grep", "-n", "-A" + after_lines, "-B" + before_lines, 
           '--include=' + files_pattern, "-r", search_string, "."] 
    if DEBUG:
        print " ".join(arr)
    call(arr)

fif=find_in_files

def hilite(*patterns):
    patterns_str = "^|%s" % "|".join(patterns) 
    arr = ["/bin/grep", "--color", "-E", patterns_str]
    if DEBUG:
        print " ".join(arr)
    p = Popen(arr, stdout=None, stdin=sys.stdin, stderr=PIPE)
    p.communicate()




if __name__ == '__main__':
    command = sys.argv[1]
    if '--debug' in sys.argv:
        DEBUG = True
        del sys.argv[sys.argv.index('--debug')]
    if command in locals().keys():
        locals()[command](*sys.argv[2:])
    else:
        print "Invalid command %s" % command
        sys.exit(1)
