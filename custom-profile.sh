#!/bin/bash

export HISTTIMEFORMAT="%d/%m/%y %T "
export HISTSIZE="10000"
export EDITOR="vim"

# Don't clobber the history when closing multiple shells
shopt -s histappend
alias tml='tmux list-sessions'
alias tma='tmux attach-session -t'
alias tmn='tmux new-session -s'
alias vi='vim'
alias myip='ifconfig.co'

### Check /etc/ENVIRO | Default to DEV ###
# to set status to  prod : echo "prod" >> /etc/ENVIRO
ENVIRO=dev
if [ -r /etc/ENVIRO ] 
then
    ENVIRO=$(grep -v '^$\|^\s*\#' /etc/ENVIRO | tail -n 1)
fi

#### Bash Prompt Colour ####
restore='\[\033[00m\]'
black='\[\033[00;30m\]'
firebrick='\[\033[00;31m\]'
red='\[\033[01;31m\]'
yellow='\033[01;33m\]'
forest='\[\033[00;32m\]'
green='\[\033[01;32m\]'
brown='\[\033[00;33m\]'
navy='\[\033[00;34m\]'
blue='\[\033[01;34m\]'
purple='\[\033[00;35m\]'
magenta='\[\033[01;35m\]'
cadet='\[\033[00;36m\]'
cyan='\[\033[01;36m\]'
gray='\[\033[00;37m\]'
white='\[\033[01;37m\]'

DIR_INFO="$blue\w \\$ $restore"
TIME="$gray[$blue\t$gray]$restore"

prod() 
{
    BASH_PROMPT="$firebrick\h $DIR_INFO"
}

qas() 
{
    BASH_PROMPT="$yellow\h $DIR_INFO"
}

dev() 
{
     BASH_PROMPT="$cyan\h $DIR_INFO"
}

systems()
{
     BASH_PROMPT="$purple\h $DIR_INFO"
}

print_sum()
{
    #[ -f /root/system-summary.sh ] && /root/system-summary.sh
    echo "* IP Address : "
    for ip in $(hostname -I); do echo -e " - $ip "; done
    echo -e "* Public IP Address : "; 
    echo -ne " - "; myip
    echo
    echo "-----------------------------------------------------------"
}

#############################################
#                   MAIN                    #
#############################################

if [ "$TERM" != 'dumb'  ] && [ -n "$BASH" ]
then
    case "$ENVIRO" in
            prod)
                prod
                ;;

            qas|stg)
                qas
                ;;
            systems)
                systems
                ;;
            *)
                dev
    esac

    # Display username for non-root user
    if [ $UID -ne "0" ]
    then
        BASH_PROMPT="$green\u$firebrick@$BASH_PROMPT"
    else
        # root users will be greeted by summary information
        print_sum
    fi
    export PS1="$TIME $BASH_PROMPT"

    # Change screen title
    if [ $TERM == "screen" ]
    then
        MYHOST=`hostname -s`
        echo -e '\033k c2 \033\\'
    fi
fi

