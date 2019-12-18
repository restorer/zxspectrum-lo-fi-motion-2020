    module eff_rtzoomer

;-----------------------------------------------------------------------------------------------------------------------

    org (($ + 255) / 256) * 256

image

    lua allpass
        for i = 0, 15 do
            for j = 0, 15 do
                sj.add_byte(bit_xor(i * 2, j * 2))
            end
        end
    endlua

;-----------------------------------------------------------------------------------------------------------------------

enter
    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    ld b,high @data.sintab_s8
    ld a,(@mgr.ticks) : ld c,a

    ld a,(bc) : call @math.expand_a_hl : ld (.row_dx),hl : .4 sla hl : ld (.line_dy),hl
    ld a,c : add a,64 : ld c,a
    ld a,(bc) : sra a : call @math.expand_a_hl : ld (.line_dx),hl
    ld a,c : add a,128 : ld c,a
    ld a,(bc) : call @math.expand_a_hl : .2 sla hl : ld (.row_dy),hl

    ld a,(@mgr.ticks) : rlca : ld c,a
    ld a,(bc) : ld h,a : ld l,0 : .4 sra hl

    ld a,c : add a,64 : ld c,a
    ld a,(bc)

    ld b,high image

    exx

    ld h,a : ld l,0
    ld bc,@rend.vscreen
    ld lx,@core_rows

.loop
    push hl

    ld de,#0000
.line_dy equ $-2

    exx
    push hl

    ld de,#0100
.line_dx equ $-2

    dup 31
        ld a,h : and #0f : ld h,a
        exx : ld a,h : and #f0 : exx : or h
        ld c,a : ld a,(bc) : exx : ld (bc),a : add hl,de : inc c : exx
        add hl,de
    edup

    ld a,h : and #0f : ld h,a
    exx : ld a,h : and #f0 : exx : or h
    ld c,a : ld a,(bc) : exx : ld (bc),a : inc bc : exx

    pop hl

    ld de,#0000
.row_dx equ $-2

    add hl,de
    exx
    pop hl

    ld de,#1000
.row_dy equ $-2

    add hl,de
    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
