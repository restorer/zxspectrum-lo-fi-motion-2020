    module eff_fire

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %00001111
cfg_strength_2 equ %00011000
cfg_strength_3 equ %00111100

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld (render.color_mask),a
    ret

leave equ @mgr.dummy_func

;-----------------------------------------------------------------------------------------------------------------------

render
    ld de,@rend.vscreen+@core_rows*32

    ld bc,(32*256)+cfg_strength_3
.color_mask equ $-2

.fill
    call @math.random_u8 : and c
    ld (de),a : inc e
    djnz .fill

    ld de,@rend.vscreen
    ld hl,@rend.vscreen+32
    ld bc,@rend.vscreen+64
    ld lx,@core_rows

.loop
    ld a,(bc) : inc c
    add a,(hl) : inc l : add a,(hl) : dec l
    rrca : rrca : and 31
    ld (de),a : inc e

    dup 30
        ld a,(bc) : inc c
        add a,(hl) : inc l : add a,(hl) : inc l : add a,(hl) : dec l
        rrca : rrca : and 31
        ld (de),a : inc e
    edup

    ld a,(bc) : inc bc
    add a,(hl) : inc l : add a,(hl) : inc hl
    rrca : rrca : and 31
    ld (de),a : inc de

    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
