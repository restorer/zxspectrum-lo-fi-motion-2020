    module eff_slime

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %00001111
cfg_strength_2 equ %00011000
cfg_strength_3 equ %00100000

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld (render.color_mask),a
    ret

leave equ @mgr.dummy_func

;-----------------------------------------------------------------------------------------------------------------------

render
    ld de,@rend.vscreen-32

    ld bc,(32*256)+cfg_strength_2
.color_mask equ $-2

.fill
    call @math.random_u8 : and c
    ld (de),a : inc e
    djnz .fill

    ld de,@rend.vscreen+(@core_rows-1)*32+31
    ld hl,@rend.vscreen+(@core_rows-2)*32+31
    ld bc,@rend.vscreen+(@core_rows-3)*32+31
    ld lx,@core_rows

.loop
    dup 31
        ld a,(bc) : dec c
        add a,(hl) : dec l
        rrca : and 31
        ld (de),a : dec e
    edup

    ld a,(bc) : dec bc
    add a,(hl) : dec hl
    rrca : and 31
    ld (de),a : dec de

    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
