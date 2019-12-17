    module eff_rain

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ 1
cfg_strength_2 equ 7

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,@rend.vscreen+30*32+31
    ld de,@rend.vscreen+31*32+31
    ld b,31

.loop
    ld c,#ff
    dup 32 : ldd : edup
    djnz .loop

    xor a : ld b,32

.clear
    ld (de),a : dec e
    djnz .clear

    call @math.random_u8

    and cfg_strength_1
.config equ $-1

    ret z
    ld b,a

.fill
    ld de,@rend.vscreen
    call @math.random_u8 : and 31
    add a,e : ld e,a

    ld a,(.config) : rlca : rlca : ld c,a
    call @math.random_u8 : and c
    ld (de),a

    djnz .fill

    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
