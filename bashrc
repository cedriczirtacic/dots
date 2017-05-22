#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -la --color=auto'

#colors
normalfg=$'\e[0m'
redfg=$'\e[38;5;9m'
greenfg=$'\e[38;5;40m'
purplefg=$'\e[38;5;170m'

_exit=0

function check_git() {
    #look for .git directory if we inside of a project
    TPWD=$( readlink -f . )
    while [[ "$TPWD" != "/" ]];do
        if [ -e "$TPWD/.git" ] ;then
            #get project name
            project=$( grep url $TPWD/.git/config | awk -F/ '{print $NF}' )
            PS1+=" git "$'\342\206\222'" $redfg$project$normalfg"
            return
        fi
        TPWD=$( readlink -f $TPWD/.. )
    done
}
function check_outcode() {
    [ $_exit -le 0 ] && return
    printf "(%d)" $_exit
}


function _prompt() {
    _exit=$?

    BEGIN_PS1="\u "$'\320\244'" \h"
    END_PS1=$'\312\216'" $purplefg\W\n$(check_outcode)$greenfg\$$normalfg$(tput sgr0) "
    
    PS1="$BEGIN_PS1"
    check_git
    PS1+=" $END_PS1"
}


PROMPT_COMMAND=_prompt
