    module eff_fire

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %00001111
cfg_strength_2 equ %00011000
cfg_strength_3 equ %00111100

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld de,@rend.vscreen+@core_rows*32

    ld bc,(32*256)+cfg_strength_3
.config equ $-2

.fill
    call @math.random_u8 : and c
    ld (de),a : inc e
    djnz .fill

    ld ix,@rend.vscreen
    ld bc,(@core_rows*256)+31

.loop
    ld a,(ix+32) : add a,(ix+33) : add a,(ix+64)
    rrca : rrca : and c
    ld (ix),a : inc lx

    dup 30
        ld a,(ix+31) : add a,(ix+32) : add a,(ix+33) : add a,(ix+64)
        rrca : rrca : and c
        ld (ix),a : inc lx
    edup

    ld a,(ix+31) : add a,(ix+32) : add a,(ix+64)
    rrca : rrca : and c
    ld (ix),a : inc ix

    dec b : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
