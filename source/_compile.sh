#!/bin/bash

cd "$(dirname "$0")"

mkdir -p _build

[ -e _build/lfm-main.bin ] && rm _build/lfm-main.bin
[ -e _build/lfm-page0.bin ] && rm _build/lfm-page0.bin
[ -e _build/lfm-page1.bin ] && rm _build/lfm-page1.bin

[ -e _build/main.l ] && rm _build/main.l
[ -e _build/main-output.log ] && rm _build/main-output.log
[ -e _build/main.sna ] && rm _build/main.sna

[ -e _build/lfm-main.hrust1 ] && rm _build/lfm-main.hrust1
[ -e _build/lfm-page0.hrust1 ] && rm _build/lfm-page0.hrust1
[ -e _build/lfm-page1.hrust1 ] && rm _build/lfm-page1.hrust1

[ -e _build/pack.l ] && rm _build/pack.l
[ -e _build/pack-output.log ] && rm _build/pack-output.log
[ -e _build/pack.sna ] && rm _build/pack.sna

[ -e _build/pack.sna ] && rm _build/lfm.tap

sjasmplus main.asm > _build/main-output.log
RES="$?"
[ -e _build/main-output.log ] && echo "----" && cat _build/main-output.log && echo "----"
[ $RES != "0" ] && exit

if [ "$1" = "--pack" ] || [ "$2" = "--pack" ] ; then
    hrust1opt -r _build/lfm-main.bin _build/lfm-main.hrust1
    hrust1opt -r _build/lfm-page0.bin _build/lfm-page0.hrust1
    hrust1opt -r _build/lfm-page1.bin _build/lfm-page1.hrust1

    sjasmplus pack.asm > _build/pack-output.log
    RES="$?"
    [ -e _build/pack-output.log ] && echo "----" && cat _build/pack-output.log && echo "----"
    [ $RES != "0" ] && exit

    # if [ "$1" != "--norun" ] && [ "$2" != "--norun" ] ; then
    #     [ -e _build/pack.sna ] && zemu -l _build/pack.l _build/pack.sna
    # fi

    ruby tapmaker.rb
elif [ "$1" != "--norun" ] ; then
    [ -e _build/main.sna ] && zemu -l _build/main.l _build/main.sna
fi
