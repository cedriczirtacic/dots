#!/bin/bash
_find=find
if [[ $(uname -s) == "Darwin" && $( which gfind) ]];then
    echo "+ seems to be a Mac OS, using gfind..."
    _find=gfind
fi

[ ! -z $1 ] && dest=$1 || dest=$HOME
for f in $( $_find . -maxdepth 1 \! -regex "\(.\|./\(.git\|README.md\|install.sh\)\)" -printf "%f\n" );do
    if [ -e $dest/.$f ];then
        echo "+ file exists, doing a backup of $f"
        mv -f $dest/.$f $dest/.$f.backup
    fi
    ln -s $(pwd)/$f $dest/.$f
done

if [ ! -e "$dest/.vim/bundle/Vundle.vim" ];then
    git clone https://github.com/VundleVim/Vundle.vim.git $dest/.vim/bundle/Vundle.vim
    vim +PluginInstall +PluginClean +qall
fi
