#!/bin/bash

cd "$(dirname "$0")"

mkdir -p _build

[ -e _build/main.sna ] && rm _build/main.sna
[ -e _build/main.l ] && rm _build/main.l
[ -e _build/main-output.log ] && rm _build/main-output.log

sjasmplus main.asm > _build/main-output.log
RES="$?"
[ -e _build/main-output.log ] && echo "----" && cat _build/main-output.log && echo "----"
[ $RES != "0" ] && exit

if [ "$1" != "--norun" ] ; then
    [ -e _build/main.sna ] && zemu -l _build/main.l _build/main.sna
fi
