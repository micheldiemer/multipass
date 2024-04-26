#!/bin/bash
# @see https://www.cyberciti.biz/tips/bash-aliases-mac-centos-linux-unix.html
alias dir='ls -l'
alias move=mv
alias cls=clear
alias where=which
alias xcopy='cp -R'
alias del=rm
alias md=mkdir
alias ..='cd ..'
alias h='history'
alias path='echo -e ${PATH//:/\\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'
alias ports='netstat -tulanp'
alias update='sudo apt-get update && sudo apt-get upgrade'
alias lt='ls --human-readable --size -1 -S --classify'
alias mnt="mount | awk -F' ' '{ printf \"%s\t%s\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort"
alias gh='history|grep'
alias left='ls -t -1'

if [ -f ~/.bash_functions ]; then
  . ~/.bash_functions
fi
