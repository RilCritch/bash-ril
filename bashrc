#!/usr/bin/bash
### EXPORT ###
export EDITOR='nvim'
export VISUAL='nvim'
export HISTCONTROL=ignoreboth:erasedups
export PAGER='most' # default arcolinux option
# export PAGER='less'
# export PAGER='batman'

# export PAGER=nvimpager

#Ibus settings if you need them
#type ibus-setup in terminal to change settings and start the daemon
#delete the hashtags of the next lines and restart
#export GTK_IM_MODULE=ibus
#export XMODIFIERS=@im=dbus
#export QT_IM_MODULE=ibus

PS1='[\u@\h \W]\$ '

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Adding Directories to path
pathadd() {
    if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
        PATH="${PATH:+"$PATH:"}$1"
    fi
}

pathadd "$HOME/.bin"

pathadd "$HOME/.local/bin"

pathadd "$HOME/.local/rilbin"

pathadd "$HOME/.local/rilbin/color-scripts"

pathadd "$HOME/.local/rilbin/starship"

pathadd "$HOME/.local/rilbin/file-management"

pathadd "$HOME/Documents/Testing/scripts"

pathadd "$HOME/.cargo/bin"

pathadd "$HOME/go/bin"

pathadd "$HOME/Builds/bat-extras/bin"

. "$HOME/.cargo/env"

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

### TEMP STUFF TO ADD TO MY BASH CONFIG FILES ###
export RANGER_LOAD_DEFAULT_RC=FALSE

#shopt
shopt -s autocd  # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob
shopt -s histappend     # do not overwrite history
shopt -s expand_aliases # expand aliases

# import bash configurations files
[[ -f $HOME/Repos/bash-ril/envvars ]] && . ${HOME}/Repos/bash-ril/envvars
[[ -f $HOME/Repos/bash-ril/ansi_escape_sequences ]] && . ${HOME}/Repos/bash-ril/ansi_escape_sequences
[[ -f $HOME/Repos/bash-ril/aliases ]] && . ${HOME}/Repos/bash-ril/aliases
[[ -f $HOME/Repos/bash-ril/functions ]] && . ${HOME}/Repos/bash-ril/functions
[[ -f $HOME/Repos/bash-ril/testing ]] && . ${HOME}/Repos/bash-ril/testing
[[ -f $HOME/Repos/bash-ril/startup ]] && . ${HOME}/Repos/bash-ril/startup

#starship
eval "$(starship init bash)"

# auto completion
# Use bash-completion, if available
[[ -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

[[ -f $HOME/.local/share/bash-completion/gita-completion.bash ]] && . ${HOME}/.local/share/bash-completion/gita-completion.bash

[[ -f $HOME/Builds/qmk_firmware/util/qmk_tab_complete.sh ]] && . ${HOME}/Builds/qmk_firmware/util/qmk_tab_complete.sh

# Start up -- used as reminders (create a script to add and remove reminders)
# echo "Reminders:" | clr blue
# echo "----------" | clr
# echo "1. Looking into xonsh - a shell that is also a python interpreter" | clr green
# echo "2. Create script for handling reminders and and editing and adding them" | clr green

# print-reminders.sh
# print-reminders.sh && lineacross | clr blackL && neofetch
# print-reminders.sh && neofetch
# print-reminders.sh

# toipe -n 10
# ca font-test
# sparky | clr black
# lineacross | clr blackL

# lineacross | clr blackL - 

source /home/rc/.bash_completions/girok.sh

# >>> juliaup initialize >>>

# !! Contents within this block are managed by juliaup !!

case ":$PATH:" in
    *:/home/rc/.juliaup/bin:*)
        ;;

    *)
        export PATH=/home/rc/.juliaup/bin${PATH:+:${PATH}}
        ;;
esac

# <<< juliaup initialize <<<

# |- Startup ->

/home/rc/Documents/rc-scripts/bin/terminfo-rcs/welcome
