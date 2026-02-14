#!/usr/bin/env bash

# Description ->
#
# |- Summary: Main bashrc entry point
#             - Sources all configuration modules in order
#             - Handles interactive/non-interactive shell detection
#             - Detects distro for conditional sourcing
#
# |- Dependencies:
#             - starship

# Document Info ->
#
# |- Author: RilCritch
#
# |- Last Update: 02/14/2026

# |- Directories ->

BASH_HOME="${HOME}/Repos/bash-ril"

# |- Interactive and non-interactive ->

# bash config files
[[ -f "${BASH_HOME}/envvars" ]] && . "${BASH_HOME}/envvars"
[[ -f "${BASH_HOME}/paths" ]] && . "${BASH_HOME}/paths"

# |- Distro detection ->

[[ -f /etc/os-release ]] && . /etc/os-release

# |- Non-interactive config stops here ->

[[ $- != *i* ]] && return

# |- Interactive ->

# bash config files
[[ -f "${BASH_HOME}/options" ]] && . "${BASH_HOME}/options"
[[ -f "${BASH_HOME}/ansi_escape_sequences" ]] && . "${BASH_HOME}/ansi_escape_sequences"
[[ -f "${BASH_HOME}/aliases" ]] && . "${BASH_HOME}/aliases"
[[ -f "${BASH_HOME}/completion" ]] && . "${BASH_HOME}/completion"
[[ -f "${BASH_HOME}/testing" ]] && . "${BASH_HOME}/testing"

# function modules
[[ -f "${BASH_HOME}/modules/utilities" ]] && . "${BASH_HOME}/modules/utilities"
[[ -f "${BASH_HOME}/modules/directory_listing" ]] && . "${BASH_HOME}/modules/directory_listing"
[[ -f "${BASH_HOME}/modules/fzf_navigation" ]] && . "${BASH_HOME}/modules/fzf_navigation"
[[ -f "${BASH_HOME}/modules/navigation" ]] && . "${BASH_HOME}/modules/navigation"
[[ -f "${BASH_HOME}/modules/file_manipulation" ]] && . "${BASH_HOME}/modules/file_manipulation"

# cross-distro package modules
[[ -f "${BASH_HOME}/modules/aliases_flatpak" ]] && . "${BASH_HOME}/modules/aliases_flatpak"

# distro-specific modules
case "${ID}" in
    arch|endeavouros|manjaro)
        [[ -f "${BASH_HOME}/modules/aliases_arch" ]] && . "${BASH_HOME}/modules/aliases_arch"
        ;;
    debian|ubuntu|linuxmint|pop)
        [[ -f "${BASH_HOME}/modules/aliases_debian" ]] && . "${BASH_HOME}/modules/aliases_debian"
        ;;
esac
[[ "${ID}" == "arcolinux" ]] && \
    [[ -f "${BASH_HOME}/modules/aliases_arcolinux" ]] && . "${BASH_HOME}/modules/aliases_arcolinux"

# starship | prompt
eval "$(starship init bash)"

# |- Startup ->

## /home/rc/Documents/rc-scripts/bin/terminfo-rcs/welcome-tree
 
sleep 0.1
sparky | clr cyanL && lineacross | clr blackL

# echo -e "${cyan}note: ${reset}Set up help script for commands in my environment\n"


# export NVM_DIR="$HOME/.config/nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Vim options - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# vim: ts=4 sts=4 sw=4 et
# vim:fileencoding=utf-8:foldmethod=marker
