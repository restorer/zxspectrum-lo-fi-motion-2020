    module eff_plasma

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %11000000
cfg_strength_2 equ %11110000

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld a,high @rend.palette_high : ld (@rend.render.palette),a

    ld ix,@rend.vscreen
    ld h,high @data.sintab : ld d,h

    exx
    ld h,high @data.sintab : ld d,h

    ld a,(@mgr.ticks) : ld l,a
    ld a,(@mgr.ticks) : add a,a : ld e,a

    ld bc,32*256+4

.loop_rows
    ld a,(hl) : exx : ld l,a : exx
    ld a,(de) : exx : ld e,a
    ld b,32

.loop_cols
    ld a,(de) : add a,(hl)
    ld c,l : ld l,a : ld a,(hl) : ld l,c

    and cfg_strength_2
.config equ $-1

    ld (ix),a : inc ix

    ld a,l : add a,8 : ld l,a
    ld a,e : sub 4 : ld e,a
    djnz .loop_cols

    exx
    ld a,l : add a,-2 : ld l,a
    inc e : inc e
    djnz .loop_rows

    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
