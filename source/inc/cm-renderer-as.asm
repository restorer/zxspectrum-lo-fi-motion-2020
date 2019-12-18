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

prepare
    ld hl,#c000 : ld de,#c001 : ld bc,#400 : ld (hl),l : ldir
    ld a,#ff : ld (hl),a : ld bc,#3FF : ldir
    ld hl,#c000 : ld de,#c800 : ld bc,#1000 : ldir

.attrs
    ld hl,#d800 : ld de,#d801 : ld bc,#02ff : ld (hl),l : ldir
    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    ld lx,@core_rows/2
    ld hl,vscreen
    ld bc,33
    ld d,high palette
    exx

    ld bc,#D800+((24-@core_rows/2)/2)*32
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
