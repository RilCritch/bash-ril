#!/usr/bin/bash

# |- Directories ->

BASH_PATH="${HOME}/Repos/bash-ril"

# |- Interactive and non-interactive ->

# bash config files
[[ -f "${BASH_PATH}/envvars" ]] && . "${BASH_PATH}/envvars"
[[ -f "${BASH_PATH}/paths" ]] && . "${BASH_PATH}/paths"

# |- Non-interactive config stops here ->

[[ $- != *i* ]] && return

# |- Interactive ->

# bash config files
[[ -f "${BASH_PATH}/options" ]] && . "${BASH_PATH}/options"
[[ -f "${BASH_PATH}/ansi_escape_sequences" ]] && . "${BASH_PATH}/ansi_escape_sequences"
[[ -f "${BASH_PATH}/aliases" ]] && . "${BASH_PATH}/aliases"
[[ -f "${BASH_PATH}/functions" ]] && . "${BASH_PATH}/functions"
[[ -f "${BASH_PATH}/completion" ]] && . "${BASH_PATH}/completion"
[[ -f "${BASH_PATH}/testing" ]] && . "${BASH_PATH}/testing"

# starship | prompt
eval "$(starship init bash)"

# |- Startup ->

/home/rc/Documents/rc-scripts/bin/terminfo-rcs/welcome-tree
echo

# echo -e "${cyan}note: ${reset}Set up help script for commands in my environment\n"

