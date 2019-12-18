    module eff_dina

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
    ld a,(@mgr.ticks) : add a,64
    .2 rlca : ld e,a

    ld d,high @data.sintab_u8
    ld hl,@rend.vscreen
    ld bc,3*256+4

    exx

    ld d,high @data.sintab_u8
    ld b,high image
    ld lx,@core_rows

    ld h,0

.loop
    exx
    ld a,b : add a,e : ld e,a
    ld a,(de)
    exx

    .3 rlca : and #07 : ld l,a
    ld a,(@mgr.ticks) : rlca : ld e,a

    dup 32
        ld a,(de) : srl a : add a,h : and #f0 : or l
        ld c,a : ld a,(bc)
        exx : ld (hl),a : inc hl : ld a,c : exx
        add a,e : ld e,a
        ld a,l : inc a : and #0f : ld l,a
    edup

    ld a,h : add a,#08 : ld h,a
    dec lx : jp nz,.loop
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
