    module rend

;-----------------------------------------------------------------------------------------------------------------------

    org (($ + 255) / 256) * 256

ink_tab
    .2 db (#40 or #00)
    .2 db (#40 or #01)
    .2 db (#40 or #02)
    .2 db (#40 or #03)
    .2 db (#40 or #04)
    .2 db (#40 or #05)
    .2 db (#40 or #06)
    .2 db (#40 or #07)
    .240 db (#40 or #07)

paper_tab
    .2 db (#40 or #00)
    .2 db (#40 or #08)
    .2 db (#40 or #10)
    .2 db (#40 or #18)
    .2 db (#40 or #20)
    .2 db (#40 or #28)
    .2 db (#40 or #30)
    .2 db (#40 or #38)
    .240 db (#40 or #38)

    display "ink_tab = ", ink_tab
    display "paper_tab = ", paper_tab

;-----------------------------------------------------------------------------------------------------------------------

render
    ld lx,16

    ld hl,vscreen
    ld d,high paper_tab
    ld bc,33
    exx

    ld bc,#5800+4*32
    ld h,high ink_tab
    ld de,vscreen+32

.loop
    dup 31
        ld a,(de) : ld l,a
        exx : ld e,(hl) : ld a,(de) : inc l : exx
        or (hl) : ld (bc),a
        inc e : inc c
    edup

    ld a,(de) : ld l,a
    exx : ld e,(hl) : ld a,(de) : exx
    or (hl) : ld (bc),a

    exx
    ld a,l : add a,c : ld l,a
    ld a,h : adc a,b : ld h,a
    exx

    ld a,e : add a,33 : ld e,a
    ld a,d : adc a,0 : ld d,a
    inc bc

    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
