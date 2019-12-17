    module eff_raskolbas

;-----------------------------------------------------------------------------------------------------------------------

line_color equ 15

cfg_strength_1 equ 1
cfg_strength_2 equ 2
cfg_strength_3 equ 3
cfg_strength_4 equ 7

cfg_vline equ 1
cfg_hline equ 2
cfg_box   equ 4

config equ render.config

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,@rend.vscreen
    ld bc,32*256

.fade
    dup 31
        dec (hl) : jp p,1F
        ld (hl),c
1       inc l
    edup

    dec (hl) : jp p,1F
    ld (hl),c
1   inc hl

    dec b : jp nz,.fade

    ld a,cfg_vline or cfg_hline or cfg_box
.config equ $-1

    and cfg_vline : jp z,.no_vline

    call @math.random_u8 : ld l,a
    and %01100000 : jp nz,.no_vline

    ld h,high @rend.vscreen
    ld a,l : and 31 : add a,low @rend.vscreen : ld l,a
    ld de,32 : ld b,e
    ld a,line_color

.vline
    ld (hl),a : add hl,de
    djnz .vline

.no_vline
    ld a,(.config) : and cfg_hline : jp z,.no_hline

    call @math.random_u8 : ld l,a
    and %01100000 : jp nz,.no_hline

    ld a,l : and 31 : ld l,a : ld h,0
    dup 5 : sla hl : edup
    ld de,@rend.vscreen : add hl,de
    ld b,32
    ld a,line_color

.hline
    ld (hl),a : inc l
    djnz .hline

.no_hline
    ld a,(.config) : and cfg_box : ret z

    call @math.random_u8 : ld c,a : and %01100000 : ret nz
    ld a,c : and #0f : inc a : ld b,a : ld (.box_width),a

    call @math.random_u8 : and #0f : inc a : ld c,a
    call @math.random_u8 : and #0f : ld l,a

    ld a,l : and 15 : ld l,a : ld h,0
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
