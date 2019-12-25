    module eff_bigpic

;-----------------------------------------------------------------------------------------------------------------------

render
    ld d,high @data.sintab_u8

    ld a,(@mgr.ticks) : ld c,a : .2 rlca
    ld e,a : ld a,(de)
    and #f8 : ld l,a : ld h,0 : .3 sla hl

    ld a,c : add a,64 : rlca
    ld e,a : ld a,(de)
    .3 rrca : and #1f

    add a,l : adc a,low tex_64x64 : ld l,a
    ld a,h : adc a,high tex_64x64 : ld h,a

    ld de,@rend.vscreen

.loop
    .32 ldi
    ld bc,32 : add hl,bc
    dec lx : jp nz,.loop
    ret

tex_64x64
    incbin "../data/tex_64x64.dat"

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
