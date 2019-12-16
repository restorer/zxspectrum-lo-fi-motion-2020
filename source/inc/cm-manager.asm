    module mgr

;-----------------------------------------------------------------------------------------------------------------------

init
    halt
    xor a : call @sys.attr_fill

    ld hl,#4000 : ld de,#4001 : ld bc,#400 : ld (hl),l : ldir
    ld a,#ff : ld (hl),a : ld bc,#3FF : ldir
    ld hl,#4000 : ld de,#4800 : ld bc,#1000 : ldir

    ld a,#17 : call @sys.swap
    ld hl,#4000 : ld de,#c000 : ld bc,#1b00 : ldir

    ret

;-----------------------------------------------------------------------------------------------------------------------

run
    ld a,1 : ld (@sys.is_music_played),a

loop
    halt

    call @rend.render
    ifdef _BORDERMETER : ld a,2 : out (#fe),a : endif

    if @bank_code : ld a,@bank_code : else : xor a : endif
    call @sys.swap

    ld a,(ticks+1)

    and 3 : jr nz,1F
    call @eff_fire.render : jr next

1   dec a : jr nz,2F
    call @eff_rain.render : jr next

2   dec a : jr nz,3F
    call @eff_slime.render : jr next

3   call @eff_interp.render

next
    ifdef _BORDERMETER : xor a : out (#fe),a : endif
    jp loop

;-----------------------------------------------------------------------------------------------------------------------

on_int_pre
    ifdef _BORDERMETER : ld a,1 : out (#fe),a : endif

    ld a,(@sys.bank) : ld (on_int_post.bank),a
    if @bank_code : ld a,@bank_code : else : xor a : endif
    jp @sys.swap

on_note
    ret

on_int_post
    ld hl,(ticks) : inc hl : ld (ticks),hl

    ld a,0
.bank equ $-1

    jp @sys.swap

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
