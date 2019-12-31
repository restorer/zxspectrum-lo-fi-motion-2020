    module eff_burb

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ 1
cfg_strength_2 equ 7

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld (render.strength),a
    rlca : rlca : ld (render.color_mask),a
    ret

leave equ @mgr.dummy_func

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
.strength equ $-1

    ret z
    ld b,a

.fill
    ld de,@rend.vscreen+(@core_rows-1)*32
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
