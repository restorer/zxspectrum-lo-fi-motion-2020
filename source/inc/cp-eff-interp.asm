    module eff_interp

;-----------------------------------------------------------------------------------------------------------------------

cfg_strength_1 equ %00000111
cfg_strength_2 equ %00001111
cfg_strength_3 equ %00011111

config equ interp_line.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld a,(@mgr.ticks)
    call get_point
    ld d,a : ld e,0
    ld (interp.left_pt),de

    ld a,(@mgr.ticks) : add a,a
    call get_point
    ld h,a : ld l,e

    and a : sbc hl,de
    dup 5 : sra hl : edup
    ld (interp.left_pt_add),hl

    ;;;;

    ld a,(@mgr.ticks) : .2 add a,a
    call get_point
    ld d,a : ld e,0
    ld (interp.right_pt),de

    ld a,(@mgr.ticks) : .3 add a,a
    call get_point
    ld h,a : ld l,e

    and a : sbc hl,de
    dup 5 : sra hl : edup
    ld (interp.right_pt_add),hl

    ; fallthrough

; IN:
;   (.left_pt) - left point
;   (.right_pt) - right point
;   (.left_pt_add) - left point addition
;   (.right_pt_add) - right point addition
interp
    ld ix,@rend.vscreen
    ld ly,32

.loop
    ld de,0
.left_pt equ $-2

    ld hl,0
.right_pt equ $-2

    call interp_line

    ld hl,(.left_pt)

    ld de,0
.left_pt_add equ $-2

    add hl,de
    ld (.left_pt),hl

    ld hl,(.right_pt)

    ld de,0
.right_pt_add equ $-2

    add hl,de
    ld (.right_pt),hl

    dec ly : jp nz,.loop
    ret

; IN:
;   de - left point
;   hl - right point
;   ix - *line
interp_line
    push de
    and a : sbc hl,de
    dup 5 : sra hl : edup
    ex de,hl
    pop hl

    ld c,cfg_strength_3
.config equ $-1

    dup 31
        ld a,h : and c : ld (ix),a
        add hl,de : inc lx
    edup

    ld a,h : and c : ld (ix),a
    inc ix : ret

; IN:
;   a - value
; OUT:
;   a - point
; USE:
;   hl
get_point
    ld h,high @data.sintab : ld l,a
    ld a,(hl)
    rrca : rrca : rrca : and 31
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
