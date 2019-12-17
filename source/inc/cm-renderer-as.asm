    module rend

;-----------------------------------------------------------------------------------------------------------------------

    org (($ + 255) / 256) * 256

palette
    .4 db (#40 or #00)
    .4 db (#40 or #08)
    .4 db (#40 or #10)
    .4 db (#40 or #18)
    .4 db (#40 or #20)
    .4 db (#40 or #28)
    .4 db (#40 or #30)
    .4 db (#40 or #38)
    .112 db (#40 or #38)
    .112 db #40

    .4 db (#40 or #00)
    .4 db (#40 or #01)
    .4 db (#40 or #02)
    .4 db (#40 or #03)
    .4 db (#40 or #04)
    .4 db (#40 or #05)
    .4 db (#40 or #06)
    .4 db (#40 or #07)
    .112 db (#40 or #07)
    .112 db #40

;-----------------------------------------------------------------------------------------------------------------------

render
    ld lx,16
    ld hl,vscreen
    ld bc,33
    ld d,high palette
    exx

    ld bc,#D800+4*32
    ld h,(high palette)+1
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

    exx : add hl,bc : exx

    ld a,e : add a,33 : ld e,a
    ld a,d : adc a,0 : ld d,a
    inc bc

    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
