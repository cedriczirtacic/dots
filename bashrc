#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

_readlink=readlink
GITUSER=cedriczirtacic
[ -z "$GIT_EDITOR" ] && export GIT_EDITOR=$( which vim )

#if MacOS
if [[ $(uname -s) == "Darwin" && $(which greadlink) ]];then
    echo "+ seems to be a Mac OS, using greadlink..."
    _readlink=greadlink
    #set the `ls` colors
    export LSCOLORS="exgxcxdxbxegedabagacad"

    #aliases
    alias ls='ls -G'
    alias ll='ls -laG'

    #brew
    alias brewUg="brew upgrade --cleanup"
    alias brewUp="brew update -f"

    alias updatedb="/usr/libexec/locate.updatedb"
else
#if Linux
    #aliases
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'

    # if pacman installed then use aliases
    if which pacman >/dev/null 2>&1 ;then
        alias pacS='pacman -S'
        alias pacSi='pacman -S -i'
        alias pacSs='pacman -S -s -q'
        alias pacQi='pacman -Q -i'
        alias pacQl='pacman -Q -l'
        alias pacR='pacman -R -v'
    fi
fi
#alias for both
alias svim='sudo vim'

#colors
normalfg=$'\e[0m'
redfg=$'\e[38;5;9m'
greenfg=$'\e[38;5;40m'
purplefg=$'\e[38;5;170m'

_exit=0

function check_git() {
    #look for .git directory if we inside of a project
    TPWD=$( $_readlink -f . )
    while [[ "$TPWD" != "/" ]];do
        if [ -e "$TPWD/.git" ] ;then
            #get project name
            project=$( grep url $TPWD/.git/config | awk -F/ '{print $NF}' )
            PS1+=" git "$'\342\206\222'" $redfg$project$normalfg"
            return
        fi
        TPWD=$( $_readlink -f $TPWD/.. )
    done
}

function check_outcode() {
    [ $_exit -le 0 ] && return
    printf "(%d)" $_exit
}

#create a repo on github.com
function gh_create() {
    local repo=$1

    curl -u $GITUSER https://api.github.com/user/repos -d "{\"name\":\"$repo\"}";
    git clone git@github.com:$GITUSER/$repo.git
}

# use objdump to disassemble an specific function
function objdumpf() {
    local file=$1
    local func=$2
    objdump -D $file | perl -ne "if (/<$func>/){print;while(<>){exit if(/^\r*\n$/g);print}}"
}

# use gdb to disassemble an specific function
function gdbf() {
    local file=$1
    local func=$2
    gdb -batch -ex "file $file" -ex "disas $func"
}

function _prompt() {
    _exit=$?

    BEGIN_PS1=""
    if [[ $( uname -s ) == "Darwin" ]];then
        BEGIN_PS1="${BEGIN_PS1}☠️  "
    fi
    BEGIN_PS1="$BEGIN_PS1\u "$'\320\244'" \h"
    END_PS1=$'\312\216'" $purplefg\W\n$(check_outcode)$greenfg\$$normalfg$(tput sgr0) "
    
    PS1="$BEGIN_PS1"
    check_git
    PS1+=" $END_PS1"
}

PROMPT_COMMAND=_prompt
