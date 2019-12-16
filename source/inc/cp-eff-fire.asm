    module eff_fire

;-----------------------------------------------------------------------------------------------------------------------

render
    ld de,@rend.vscreen+32*32
    ld bc,(32*256)+%00111100

.fill
    call @math.random : and c
    ld (de),a : inc e
    djnz .fill

    ld ix,@rend.vscreen
    ld bc,(32*256)+%00111100

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
