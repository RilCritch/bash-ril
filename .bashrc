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

if [ -d "$HOME/.bin" ]; then
	PATH="$HOME/.bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
	PATH="$HOME/.local/bin:$PATH"
fi

if [ -d "$HOME/scripts" ]; then
	PATH="$HOME/scripts:$PATH"
fi

if [ -d "$HOME/.cargo/bin" ]; then
	PATH="$HOME/.cargo/bin:$PATH"
fi

# if which ruby >/dev/null && which gem >/dev/null; then
# 	PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
# fi

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

### TEMP STUFF TO ADD TO MY BASH CONFIG FILES ###
export FZF_DEFAULT_COMMAND="fd"
export RANGER_LOAD_DEFAULT_RC=FALSE

#shopt
shopt -s autocd  # change to named directory
shopt -s cdspell # autocorrects cd misspellings
shopt -s cmdhist # save multi-line commands in history as single line
shopt -s dotglob
shopt -s histappend     # do not overwrite history
shopt -s expand_aliases # expand aliases

# import bash configurations files
[[ -f $HOME/Repos/bash-ril/ansi_escape_sequences ]] && . $HOME/Repos/bash-ril/ansi_escape_sequences
[[ -f $HOME/Repos/bash-ril/aliases ]] && . $HOME/Repos/bash-ril/aliases
[[ -f $HOME/Repos/bash-ril/envvars ]] && . $HOME/Repos/bash-ril/envvars
[[ -f $HOME/Repos/bash-ril/functions ]] && . $HOME/Repos/bash-ril/functions

#Generic color list
{
	c1='[31m'
	c2='[32m'
	c3='[33m'
	c4='[34m'
	c5='[35m'
	c6='[36m'
	c7='[37m'
	c8='[38m'
	cR='[m'
}

# Created by `pipx` on 2023-06-25 22:48:45
export PATH="$PATH:/home/rc/.local/bin"

#starship
eval "$(starship init bash)"

# Start up -- used as reminders (create a script to add and remove reminders)
# echo "Reminders:" | clr blue
# echo "----------" | clr
# echo "1. Looking into xonsh - a shell that is also a python interpreter" | clr green
# echo "2. Create script for handling reminders and and editing and adding them" | clr green

# print-reminders.sh
# print-reminders.sh && lineacross | clr blackL && neofetch
# print-reminders.sh && neofetch
# print-reminders.sh
