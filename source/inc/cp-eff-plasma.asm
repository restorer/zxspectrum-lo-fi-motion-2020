    module eff_plasma

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %00011000
cfg_strength_2 equ %00011111

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld a,(.config) : cp cfg_strength_2 : jp z,.change_params

    ld a,8 : ld (.param_1),a
    ld a,-4 : ld (.param_2),a
    ld a,-2 : ld (.param_3),a
    ld a,2 : ld (.param_4),a
    jp .entry

.change_params
    ld a,16 : ld (.param_1),a
    ld a,-8 : ld (.param_2),a
    ld a,-4 : ld (.param_3),a
    ld a,4 : ld (.param_4),a

.entry
    ld ix,@rend.vscreen
    ld h,high @data.sintab_u8 : ld d,h

    exx
    ld h,high @data.sintab_u8 : ld d,h

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
    rrca : rrca : rrca

    and cfg_strength_2
.config equ $-1

    ld (ix),a : inc ix
    ld a,l

    add a,8
.param_1 equ $-1

    ld l,a
    ld a,e

    add a,-4
.param_2 equ $-1

    ld e,a
    djnz .loop_cols

    exx
    ld a,l

    add a,-2
.param_3 equ $-1

    ld l,a
    ld a,e

    add a,2
.param_4 equ $-1

    ld e,a
    djnz .loop_rows

    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
