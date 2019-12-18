    module eff_logo

;-----------------------------------------------------------------------------------------------------------------------

enter
    ld a,(@sys.swap.or_with) : xor 8 : ld (render.bank_or_with),a
    and 8 : rrca : rrca : or 5 : call @sys.swap

    ld hl,logo
    ld de,#c000
    ld bc,#1b00
    ldir

    ld a,1 : ld (@mgr.loop.render_skip),a
    ret

;-----------------------------------------------------------------------------------------------------------------------

leave
    halt
    xor a : ld (@mgr.loop.render_skip),a : out (#fe),a

    ld a,(@sys.swap.or_with) : xor 8 : ld (@sys.swap.or_with),a
    and 8 : rrca : rrca : or 5 : call @sys.swap
    call @rend.prepare.attrs

    ld a,(@sys.bank) : xor 2 : call @sys.swap
    call @rend.prepare

    ld hl,@rend.vscreen : ld de,@rend.vscreen+1 : ld bc,@core_rows*32
    xor a : ld (hl),a : ldir
    ret

;-----------------------------------------------------------------------------------------------------------------------

render
    halt
    ld a,2 : out (#fe),a

    ld a,0
.bank_or_with equ $-1

    ld (@sys.swap.or_with),a
    ld a,(@sys.bank) : jp @sys.swap

;-----------------------------------------------------------------------------------------------------------------------

logo
    incbin "../data/logo.s"

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
