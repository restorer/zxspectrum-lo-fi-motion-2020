    module eff_dina

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ high @data.tex_16x16_1
cfg_strength_2 equ high @data.tex_16x16_2

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld (render.texptr),a
    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    ld a,(@mgr.ticks) : add a,64
    .2 rlca : ld e,a

    ld d,high @data.sintab_u8
    ld hl,@rend.vscreen
    ld bc,3*256+4

    exx

    ld d,high @data.sintab_u8

    ld b,0
.texptr equ $-1

    ld lx,@core_rows

    ld h,0

.loop
    exx
    ld a,b : add a,e : ld e,a
    ld a,(de)
    exx

    .3 rlca : and #07 : ld l,a
    ld a,(@mgr.ticks) : rlca : ld e,a

    dup 32
        ld a,(de) : srl a : add a,h : and #f0 : or l
        ld c,a : ld a,(bc)
        exx : ld (hl),a : inc hl : ld a,c : exx
        add a,e : ld e,a
        ld a,l : inc a : and #0f : ld l,a
    edup

    ld a,h : add a,#08 : ld h,a
    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
