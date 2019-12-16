    module eff_slime

;-----------------------------------------------------------------------------------------------------------------------

render
    ld de,@rend.vscreen-32
    ld bc,(32*256)+#0f

.fill
    call @math.random_u8 : and c
    ld (de),a : inc e
    djnz .fill

    ld ix,@rend.vscreen+31*32+31
    ld bc,(32*256)+#0f

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
