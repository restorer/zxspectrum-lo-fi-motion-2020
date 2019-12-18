    module eff_rain

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ 1
cfg_strength_2 equ 7

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld (render.strength),a
    rlca : rlca : ld (render.color_mask),a
    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,@rend.vscreen+(@core_rows-2)*32+31
    ld de,@rend.vscreen+(@core_rows-1)*32+31
    ld b,@core_rows-1

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
.strength equ $-1

    ret z
    ld b,a

.fill
    ld de,@rend.vscreen
    call @math.random_u8 : and 31
    add a,e : ld e,a

    call @math.random_u8

    and 0
.color_mask equ $-1

    ld (de),a

    djnz .fill

    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
