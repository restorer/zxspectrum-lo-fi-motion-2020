    module eff_plasma

;-----------------------------------------------------------------------------------------------------------------------

render
    ld ix,@rend.vscreen
    ld h,high @data.sintab : ld d,h

    exx
    ld h,high @data.sintab : ld d,h

    ld l,5
.param_1 equ $-1

    ld e,9
.param_2 equ $-1

    ld b,32

.loop_rows
    ld a,(hl) : exx : ld l,a : exx
    ld a,(de) : exx : ld e,a
    ld b,32

.loop_cols
    ld a,(de) : add a,(hl)
    sub l : add a,e
    ld c,l : ld l,a : ld a,(hl) : ld l,c

    rrca : rrca : rrca : rrca : and #0f
    ld (ix),a : inc ix

    dec l : dec l
    ld a,e : sub 4 : ld e,a
    djnz .loop_cols

    exx
    inc l : inc l : inc e
    djnz .loop_rows

    ld a,(.param_1) : add a,2 : ld (.param_1),a
    ld a,(.param_2) : add a,4 : ld (.param_2),a

    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
