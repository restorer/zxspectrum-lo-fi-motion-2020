        device zxspectrum128

        org #7000

entry   di : ld sp,unpacker_first_inner
        ld hl,unpacker_first : ld de,unpacker_first_inner : ld bc,unpacker_last-unpacker_first : ldir
        jp unpacker_first_inner

unpacker_first
        disp #b800

unpacker_first_inner
        ld a,#10 : call swap : ld hl,page_0 : call dehrust.DEHRUST
        ld a,#11 : call swap : ld hl,page_1 : ld bc,data_last-page_1 : ldir
        ld a,#17 : call swap : ld hl,main : ld bc,page_0-main : ldir
        ld hl,#c000 : ld de,#6000 : call dehrust.DEHRUST
        jp #6000

swap    ld bc,#7FFD : out (c),a
        ld de,#c000 : ret

        include "inc/cm-dehrust.asm"
unpacker_last_inner

        ent
unpacker_last

main    incbin "_build/lfm-main.hrust1"
page_0  incbin "_build/lfm-page0.hrust1"
page_1  incbin "_build/lfm-page1.bin"
data_last

        display "entry                : ", entry
        display "data_last            : ", data_last
        display "unpacker_first_inner : ", unpacker_first_inner
        display "unpacker_last_inner  : ", unpacker_last_inner

        savesna "_build/pack.sna", @entry
        labelslist "_build/pack.l"

        savebin "_build/lfm-pack.bin", @entry, @data_last-@entry

        ; emptytrd "_build/prezu.trd"
        ; savetrd "_build/prezu.trd", "main.C", @first, @last-first
        ; page 0 : savetrd "_build/zu.trd", "bank_0.C", #c000, @bank_0_last-#c000
