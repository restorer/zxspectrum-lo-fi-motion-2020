    module sys

;-----------------------------------------------------------------------------------------------------------------------

; IN:
;   a - bank
; OUT:
;   (bank) - bank
;   a - bank | %0001?000
; USE:
;   stack
swap
    push bc
    ld (bank),a

    or #10
.or_with equ $-1

    ld bc,#7FFD
    out (c),a
    pop bc
    ret

;-----------------------------------------------------------------------------------------------------------------------

; IN:
;   a - color (0 up to 7)
; USE:
;   bc
;   de
;   hl
attr_fill
    out (#FE),a
    ld b,a
    rlca
    rlca
    rlca
    or b

; IN:
;   a - attribute
; USE:
;   bc
;   de
;   hl
attr_fill_s
    ld hl,#5800
    ld de,#5801
    ld bc,#02FF
    ld (hl),a
    ldir
    ret

;-----------------------------------------------------------------------------------------------------------------------

; IN:
;   hl - screen address
; OUT:
;   hl - next cell (8 lines) in the screen
; USE:
;   a
dw_8_hl
    ld a,l : add a,#20 : ld l,a
    ret nc
    ld a,h : add a,8 : ld h,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; IN:
;   de - screen address
; OUT:
;   de - next cell (8 lines) in the screen
; USE:
;   a
dw_8_de
    ld a,e : add a,#20 : ld e,a
    ret nc
    ld a,d : add a,8 : ld d,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; IN:
;   hl - screen address
; OUT:
;   hl - next line in the screen
; USE:
;   a
dw_hl
    inc h
    ld a,h : and 7
    ret nz
    ld a,l : add a,#20 : ld l,a
    ret c
    ld a,h : sub 8 : ld h,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; IN:
;   de - screen address
; OUT:
;   de - next line in the screen
; USE:
;   a
dw_de
    inc d
    ld a,d : and 7
    ret nz
    ld a,e : add a,#20 : ld e,a
    ret c
    ld a,d : sub 8 : ld d,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; USE:
;   a
;   bc
turbo_on
    xor a
    ld bc,#EFF7 ; pentagon-1024
    out (c),a

    ;;;; disabled, because will conflict with non-full #7FFD port decoding
    ; ld bc,#1FFD ; kay-1024
    ; out (c),a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; USE:
;   a
;   bc
turbo_off
    ld a,#10 ; pentagon-1024
    ld bc,#EFF7
    out (c),a

    ;;;; disabled, because will conflict with non-full #7FFD port decoding
    ; ld a,8            ; kay-1024
    ; ld bc,#1FFD
    ; out (c),a
    ret

;-----------------------------------------------------------------------------------------------------------------------

int_handler
    push af,bc,de,hl,ix,iy
    exa : exx
    push af,bc,de,hl

    call @mgr.on_int

    pop hl,de,bc,af
    exx : exa
    pop iy,ix,hl,de,bc,af

    ei
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
