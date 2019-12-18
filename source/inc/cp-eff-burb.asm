    module eff_burb

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ 1
cfg_strength_2 equ 7

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,@rend.vscreen+32
    ld de,@rend.vscreen
    ld b,@core_rows-1

.loop
    ld c,#ff
    dup 32 : ldi : edup
    djnz .loop

    xor a : ld b,32

.clear
    ld (de),a : inc e
    djnz .clear

    call @math.random_u8

    and cfg_strength_1
.config equ $-1

    ret z
    ld b,a

.fill
    ld de,@rend.vscreen+(@core_rows-1)*32
    call @math.random_u8 : and 31
    add a,e : ld e,a

    ld a,(.config) : rlca : rlca : ld c,a
    call @math.random_u8 : and c
    ld (de),a

    djnz .fill
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
