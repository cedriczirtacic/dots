#!/bin/bash

function perror() {
    echo -e "$1" 1>&2
}

_find=find
if [[ $(uname -s) == "Darwin" && $( which gfind) ]];then
    which gfind >/dev/null 2>&1
    if [ $? -gt 0 ];then
        perror "- install findutil and coreutil\nExiting..."
        exit 1
    fi
    perror "+ seems to be a Mac OS, using gfind..."
    _find=gfind
fi

# clone and install gef
if ! [ -d "./gef" ]; then
    git clone https://github.com/hugsy/gef.git
fi
cat <<EOF > gdbinit
source $(pwd)/gef/gef.py
set disassembly-flavor att
EOF

[ ! -z $1 ] && dest=$1 || dest=$HOME
for f in $( $_find . -maxdepth 1 \! -regex "\(.\|./\(.git.*\|README.md\|install.sh\|gef\)\)" -printf "%f\n" );do
    if [ -e $dest/.$f ];then
        echo "+ file exists, doing a backup of $f"
        # remove previous backups
        [ -e $dest/.$f.backup ] && rm -f $dest/.$f.backup
        mv -f $dest/.$f $dest/.$f.backup
    fi
    ln -s $(pwd)/$f $dest/.$f
done

if ! [ -e "$dest/.vim/bundle/Vundle.vim" ];then
    git clone https://github.com/VundleVim/Vundle.vim.git $dest/.vim/bundle/Vundle.vim
    vim +PluginInstall +PluginClean +qall
fi

# to be used with iTerm2 or Hyper (.ttfs so can be used anywhere if needed) 
if ! [ -e "./fonts" ];then
    FONTZIP="https://github.com/source-foundry/Hack/archive/master.zip"
    mkdir fonts && cd fonts
    if ! which wget >/dev/null;then
        curl -sL $FONTZIP \
            > master.zip
    else
        wget -q $FONTZIP
    fi
    unzip -qq master.zip && \
        rm -f master.zip
    cd ..
fi

# load new bash source
. $dest/.bashrc
