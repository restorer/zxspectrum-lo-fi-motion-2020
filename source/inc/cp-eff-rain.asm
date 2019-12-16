    module eff_rain

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,@rend.vscreen+30*32+31
    ld de,@rend.vscreen+31*32+31
    ld b,31

.loop
    ld c,#ff
    dup 32 : ldd : edup
    djnz .loop

    ld de,@rend.vscreen
    ld b,32

.fill
    call @math.random_u8 : ld c,a

    and %11110001 : jp z,1F
    xor a : jp 2F

1   ld a,c : and #0f

2   ld (de),a : inc e
    djnz .fill

    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
