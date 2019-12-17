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

    ld a,(ticks+1) : and 15

    add a,a : ld l,a : add a,a : add a,l ; * 6
    add a,low effects : ld l,a
    ld a,high effects : adc a,0 : ld h,a

    ld a,(hl) : inc hl : call @sys.swap
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,(hl) : inc hl : ld (de),a
    ld a,(hl) : inc hl : ld h,(hl) : ld l,a

    ld de,next : push de
    jp hl

    ; ld a,@bank_code : call @sys.swap : call @eff_rain.render

next
    ifdef _BORDERMETER : xor a : out (#fe),a : endif
    jp loop

;-----------------------------------------------------------------------------------------------------------------------

effects
    db @bank_code : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_1 : dw @eff_raskolbas.render
    db @bank_code : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_2 : dw @eff_raskolbas.render
    db @bank_code : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_3 : dw @eff_raskolbas.render
    db @bank_code : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_4 : dw @eff_raskolbas.render

    db @bank_code : dw @eff_fire.config : db @eff_fire.cfg_strength_2 : dw @eff_fire.render
    db @bank_code : dw @eff_slime.config : db @eff_slime.cfg_strength_2 : dw @eff_slime.render
    db @bank_code : dw @eff_fire.config : db @eff_fire.cfg_strength_3 : dw @eff_fire.render
    db @bank_code : dw @eff_slime.config : db @eff_slime.cfg_strength_3 : dw @eff_slime.render

    db @bank_code : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_5 : dw @eff_raskolbas.render
    db @bank_code : dw @eff_interp.config : db @eff_interp.cfg_strength_4 : dw @eff_interp.render

    db @bank_code : dw @eff_plasma.config : db @eff_plasma.cfg_strength_2 : dw @eff_plasma.render
    db @bank_code : dw @eff_interp.config : db @eff_interp.cfg_strength_3 : dw @eff_interp.render
    db @bank_code : dw @eff_plasma.config : db @eff_plasma.cfg_strength_1 : dw @eff_plasma.render
    db @bank_code : dw @eff_interp.config : db @eff_interp.cfg_strength_1 : dw @eff_interp.render

    db @bank_code : dw @eff_rain.config : db @eff_rain.cfg_strength_1 : dw @eff_rain.render
    db @bank_code : dw @eff_rain.config : db @eff_rain.cfg_strength_2 : dw @eff_rain.render

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
