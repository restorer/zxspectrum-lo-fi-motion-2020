    module eff_slime

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %00001111
cfg_strength_2 equ %00011000
cfg_strength_3 equ %00100000

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld de,@rend.vscreen-32

    ld bc,(32*256)+cfg_strength_2
.config equ $-2

.fill
    call @math.random_u8 : and c
    ld (de),a : inc e
    djnz .fill

    ld ix,@rend.vscreen+31*32+31
    ld bc,32*256+31

.loop
    dup 31
        ld a,(ix-32) : add a,(ix-64)
        rrca : and c
        ld (ix),a : dec lx
    edup

    ld a,(ix-32) : add a,(ix-64)
    rrca : and c
    ld (ix),a : dec ix

    dec b : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
