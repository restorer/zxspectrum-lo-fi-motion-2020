    module printer

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,(@mgr.ticks)

    ld bc,0
.next_page_ticks equ $-2

    and a : sbc hl,bc : jp c,.render_page

    ld hl,pages
.page_ptr equ $-2

.reenter_page
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,e : or d : jp nz,.process_page

    ld a,(hl) : inc hl : ld h,(hl) : ld l,a
    jp .reenter_page

.process_page
    ex de,hl : add hl,bc : ld (.next_page_ticks),hl : ex de,hl
    ld (.render_text_ptr),hl

.find_next_page
    ld a,(hl) : and a : jp z,.next_page_found

    add a,3 : add a,l : ld l,a
    ld a,h : adc a,0 : ld h,a
    jp .find_next_page

.next_page_found
    inc hl : ld (.page_ptr),hl

.render_page

    ld de,0
.clear_text_ptr_5 equ $-2

    ld a,(@sys.bank) : and 2 : jp z,.check_clear

    ld de,0
.clear_text_ptr_7 equ $-2

.check_clear
    ld a,d : or e : call nz,clear_lines

    ld hl,0
.render_text_ptr equ $-2

    ld a,(@sys.bank) : and 2 : jp nz,.fill_clear_7
    ld (.clear_text_ptr_5),hl : jp render_lines

.fill_clear_7
    ld (.clear_text_ptr_7),hl

render_lines
    ld a,(hl) : and a : ret z
    inc hl : ld b,a

    ld a,(hl) : inc hl
    exx : ld l,a : ld bc,#c820 : exx

    ld a,(hl) : inc hl
    ld (.color_bottom),a
    or %01000000 : ld (.color_top),a

.loop
    ld a,(hl) : inc hl
    exx : ld e,a

    ld d,high @data.font
    ld h,b

    dup 7 : ld a,(de) : ld (hl),a : inc d : inc h : edup
    ld a,(de) : ld (hl),a

    ld d,high @data.font : set 7,e
    ld h,b : ld a,l : add a,c : ld l,a

    dup 7 : ld a,(de) : ld (hl),a : inc d : inc h : edup
    ld a,(de) : ld (hl),a

    ld h,#d9

    ld (hl),%01001111
.color_bottom equ $-1

    ld a,l : sub c : ld l,a

    ld (hl),%00001111
.color_top equ $-1

    inc l : exx
    djnz .loop
    jp render_lines

; IN:
;   de - *lines
clear_lines
    ld a,(de) : and a : ret z
    inc de : ld b,a

    ld a,(de) : ld l,a

    ld a,b : add a,2 : add a,e : ld e,a
    ld a,d : adc a,0 : ld d,a
    push de

    ld c,#c8
    ld de,#ff

.loop
    ld h,c
    dup 4 : ld (hl),d : inc h : edup
    dup 3 : ld (hl),e : inc h : edup : ld (hl),e

    ld h,c : ld a,l : add a,32 : ld l,a
    dup 4 : ld (hl),d : inc h : edup
    dup 3 : ld (hl),e : inc h : edup : ld (hl),e

    ld a,-31 : add a,l : ld l,a
    djnz .loop

    pop de
    jp clear_lines

;-----------------------------------------------------------------------------------------------------------------------

pages
    dw #0040
    db 16, 3*32+8, %00001111, " CODE: RESTORER "
    db 0

    dw #0040
    db 16, 4*32+8, %00001111, " CODE: RESTORER "
    db 0

    dw 0 : dw pages

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
