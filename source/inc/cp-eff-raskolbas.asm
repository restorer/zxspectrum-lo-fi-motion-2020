    module eff_raskolbas

;-----------------------------------------------------------------------------------------------------------------------

line_color equ 31

cfg_vline equ 1
cfg_hline equ 2
cfg_box   equ 4

cfg_strength_1 equ cfg_vline
cfg_strength_2 equ cfg_hline
cfg_strength_3 equ cfg_vline or cfg_box
cfg_strength_4 equ cfg_hline or cfg_box
cfg_strength_5 equ cfg_vline or cfg_hline or cfg_box

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld b,a

    cp cfg_vline or cfg_hline or cfg_box : ld a,%11100000 : jp nz,1F
    ld a,%01100000
1   ld (render_gfx.box_strength),a

    ld a,b : and cfg_vline : ld (render_gfx.is_vline),a
    ld a,b : and cfg_hline : ld (render_gfx.is_hline),a
    ld a,b : and cfg_box : ld (render_gfx.is_box),a

    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,@rend.vscreen
    ld b,@core_rows
    ld a,(@mgr.frames) : ld c,a

.fade
    dup 31
        ld a,(hl) : sub c : jp p,2F
        xor a
2       ld (hl),a : inc l
    edup

    ld a,(hl) : sub c : jp p,3F
    xor a
3   ld (hl),a : inc hl

    dec b : jp nz,.fade
    ld b,c

4   push bc : call render_gfx : pop bc
    djnz 4B : ret

render_gfx
    ld a,0
.should_skip equ $-1

    xor 1 : ld (.should_skip),a
    ret z

    ld a,0
.is_vline equ $-1

    and a : jp z,.draw_hline

    call @math.random_u8 : ld l,a
    and %01100000 : jp nz,.draw_hline

    ld h,high @rend.vscreen
    ld a,l : and 31 : add a,low @rend.vscreen : ld l,a
    ld de,32 : ld a,line_color
    if @core_rows == 32 : ld b,e : else : ld b,@core_rows : endif

.vline
    ld (hl),a : add hl,de
    djnz .vline

.draw_hline

    ld a,0
.is_hline equ $-1

    and a : jp z,.draw_box

    call @math.random_u8 : ld e,a
    and %01100000 : jp nz,.draw_box

    if @core_rows == 32
        ld a,e : and 31 : ld l,a : ld h,0
    else
        ld d,0
        ld bc,@core_rows
        call @math.div_u16_u16u16
    endif

    dup 5 : sla hl : edup
    ld de,@rend.vscreen : add hl,de
    ld b,32 : ld a,line_color

.hline
    ld (hl),a : inc l
    djnz .hline

.draw_box

    ld a,0
.is_box equ $-1

    and a : ret z

    call @math.random_u8 : ld c,a

    and %11100000
.box_strength equ $-1

    ret nz

    if @core_rows == 32
        ld a,c : and #0f
    else
        ld e,c : ld d,0
        ld bc,@core_rows/2
        call @math.div_u16_u16u16
        ld a,l
    endif

    inc a : ld b,a : ld (.box_width),a

    call @math.random_u8 : and #0f : inc a : ld c,a
    call @math.random_u8

    if @core_rows == 32
        and #0f : ld l,a : ld h,0
    else
        push bc
        ld e,a : ld d,0
        ld bc,@core_rows/2
        call @math.div_u16_u16u16
        pop bc
    endif

    dup 5 : sla hl : edup
    ld de,@rend.vscreen : add hl,de

    ex de,hl
    call @math.random_u8 : and #0f
    add a,e : ld l,a
    ld h,d

    ld d,0 : ld a,32 : sub b : ld e,a
    ld a,line_color

.box
    ld (hl),a : inc l : djnz .box
    add hl,de

    ld b,0
.box_width equ $-1

    dec c : jp nz,.box
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
