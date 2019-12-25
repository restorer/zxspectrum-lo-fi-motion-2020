    module eff_rbars

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ #26
cfg_strength_2 equ #2c
cfg_strength_3 equ #c2
cfg_strength_4 equ #4c

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld b,a
    .4 rrca : and #0f : ld (render.hstrength),a
    ld a,b : and #0f : ld (render.vstrength),a
    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,4
.hstrength equ $-2

    ld (.multiplier),hl
    ld b,high @data.sintab_s8
    ld a,(@mgr.ticks) : .3 rlca : ld c,a
    exx

    xor a : ld hl,buffer : ld b,32

.clear
    ld (hl),a : inc hl
    djnz .clear

    ld de,@rend.vscreen
    ld b,@core_rows

.loop
    exx

    ld hl,0
.multiplier equ $-2

    push bc,hl
    ld a,(bc) : call @math.mul_s16_s8s16
    ld a,h : call @math.expand_a_hl
    ld de,buffer+12 : add hl,de : ex de,hl

    ld hl,tex_1x8 : .8 ldi

    pop hl : inc hl : ld (.multiplier),hl
    pop bc : ld a,c

    add a,6
.vstrength equ $-1

    ld c,a
    exx

    ld hl,buffer : ld c,#ff
    .32 ldi

    dec b : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

tex_1x8
    db 11, 19, 27, 31, 31, 23, 15, 7

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
