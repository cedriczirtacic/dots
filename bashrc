#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return
[[ $DISPLAY ]] && shopt -s checkwinsize

APIKEYS="${HOME}/.apikeys"
_readlink=readlink
GITUSER=cedriczirtacic

[ -z "$GIT_EDITOR" ] && export GIT_EDITOR=$( which vim )

# Check for API Keys source
if [ -f "$APIKEYS" ]; then
    source $APIKEYS
else
    printf 'API keys file not found (path: %s)\n' "$APIKEYS" 1>&2
fi

# print tmux sessions after login
if which tmux >/dev/null && [ -n "$TMUX" ];then
    echo "TMUX sessions:" && tmux ls;
fi

#if MacOS
if [[ $(uname -s) == "Darwin" && $(which greadlink) ]];then
    #echo "+ seems to be a Mac OS, using greadlink..."
    _readlink=greadlink
    
    #if openssl installed with brew then export needed LD/CPP flags
    brew info openssl|grep -iE "^Not installed" >/dev/null
    if [ $? -eq 1 ];then
        export LDFLAGS=-L/usr/local/opt/openssl/lib
        export CPPFLAGS=-I/usr/local/opt/openssl/include
    fi

    #set the `ls` colors
    export LSCOLORS="exgxcxdxbxegedabagacad"

    #aliases
    alias ls='ls -G'
    alias ll='ls -laG'

    #brew
    alias brewUg="brew upgrade --cleanup"
    alias brewUp="brew update -f"
    
    #airport
    alias airport="/System/Library/PrivateFrameworks/Apple80211.framework/Versions/A/Resources/airport"

    #some homebrew security
    brew analytics off
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CASK_OPTS=--require-sha

    alias updatedb="sudo /usr/libexec/locate.updatedb"
    function power_attached() {
        if [[ `/usr/bin/pmset -g ac 2>&1` != "No adapter attached." ]]
        then
            printf "⚡️ "
        fi
    }
    function proxy_on {
        sudo bash -c '
    networksetup -setsecurewebproxy "wi-fi" 127.0.0.1 8118 && \
        networksetup -setwebproxy "wi-fi" 127.0.0.1 8118
    '
        return $?
    }

    function proxy_off {
        sudo bash -c '
    networksetup -setsecurewebproxystate "Wi-Fi" off && \
        networksetup -setwebproxystate "Wi-Fi" off
    '
        return $?
    }

    function toggle_proxy {
        local PRIVOXY_STATUS=$(brew services list | grep -i privoxy | \
            cut -d' ' -f2)
        printf "Privoxy status: %s\n" "$PRIVOXY_STATUS"
        if [[ $PRIVOXY_STATUS != "started" ]];then
            echo "Start Privoxy before setting up the proxy..."
            return 1
        fi

        local PROXY_STATUS=$(networksetup -getwebproxy "Wi-Fi" | \
            awk '$0~/^Enabled:/{print $2}')
        case $PROXY_STATUS in
            "Yes")
                proxy_off
                echo "Proxy: OFF"
                ;;
            "No")
                proxy_on
                echo "Proxy: ON"
                ;;
        esac
        return $?
    }

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
#aliases for both
alias nmap-shodan="nmap -sn -Pn -n --script=shodan-api --script-args \"shodan-api.apikey=$SHODAN_API_KEY\""
if [ -e $(which vi) -a $(which vim) ];then
    # avoid calling 'vi' if 'vim' installed
    alias vi='vim'
fi
alias svim='sudo vim'
alias lastcomm='vim <(git show --source HEAD)'

#colors
normalfg=`tput sgr0`
redfg=`tput setaf 1`
greenfg=`tput setaf 2`
purplefg=`tput setaf 5`

_exit=0

function check_git() {
    #look for .git directory if we inside of a project
    TPWD=$( $_readlink -f . )
    while [[ "$TPWD" != "/" ]];do
        if [ -f "$TPWD/.git/config" ];then
            #get project name
            project=$( grep -E '[\t\s]*url =' $TPWD/.git/config | awk -F'=' '{print $2}' | sed 's/\s*https*:\/\///' )
            if [[ $project != "" ]]; then
                PS1+=" git "$'\342\206\222'" \[$redfg\]$project\[$normalfg\]"
            fi
            return
        fi
        TPWD=$( $_readlink -f "$TPWD/.." )
    done
}

function check_outcode() {
    [ $_exit -le 0 ] && return
    printf "(%d) " $_exit
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

# discover hosts using Nmap's ping scan
function pingdiscover() {
    local addr=$1
    local NMAP=$( which nmap )
    if [ $? -gt 0 ];then
        echo "- nmap is not present or not in PATH."
        return 1
    fi

    if [ -z "$addr" ];then
        echo "usage: pingdiscover <address>"
        return 2
    fi
    $NMAP -sP -T5 $addr 2>&1 | grep -B1 "Host is up" | grep -v "Nmap done"
}

# stolen from https://github.com/cbodden/dotfiles/blob/master/shells/.zshrc#L194-L205
function man() {
    env \
        LESS_TERMCAP_mb=$(printf $purplefg) \
        LESS_TERMCAP_md=$(printf $purplefg) \
        LESS_TERMCAP_me=$(printf "\e[0m") \
        LESS_TERMCAP_se=$(printf "\e[0m") \
        LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
        LESS_TERMCAP_ue=$(printf "\e[0m") \
        LESS_TERMCAP_us=$(printf "\e[1;32m") \
            man "$@"
}

function _prompt() {
    _exit=$?

    BEGIN_PS1=""
    if [[ $( uname -s ) == "Darwin" ]];then
        BEGIN_PS1="${BEGIN_PS1}$(power_attached)"
    fi
    # Basic prompt:
    #BEGIN_PS1="${BEGIN_PS1}"'\W\[$purplefg\] '$'\312\216'' \[$greenfg\]\$\[$normalfg\] '
    BEGIN_PS1="$BEGIN_PS1\u "$'\320\244'" \h"
    END_PS1=$'\312\216'" \[$purplefg\]\W\n$(check_outcode)\[$greenfg\]\$\[$normalfg\] "
    
    export PS1=$BEGIN_PS1
    check_git
    PS1+=" $END_PS1"
}
PROMPT_COMMAND=_prompt
