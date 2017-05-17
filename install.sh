#!/bin/bash
[ ! -z $1 ] && dest=$1 || dest=$HOME
for f in $( find . -maxdepth 1 \! -regex "\(.\|./\(.git\|README.md\|install.sh\)\)" -printf "%f\n" );do
    if [ -e $dest/.$f ];then
        echo "+ file exists, doing a backup of $f"
        cp -rf $dest/.$f $dest/.$f.backup
    fi
    cp -rf ./$f $dest/.$f
done

if [ ! -e "$dest/.vim/bundle/Vundle.vim" ];then
    git clone https://github.com/VundleVim/Vundle.vim.git $dest/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi
