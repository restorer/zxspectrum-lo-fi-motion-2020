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
    xor a : ld (on_int.is_inactive),a

loop
    ld hl,(ticks)
    ld bc,(next_ticks)
    and a : sbc hl,bc : jp c,.render_effect

    ld hl,scenes
.scene_ptr equ $-2

.reenter_scene
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,e : or d : jp nz,.process_scene

    ld a,(hl) : inc hl : ld h,(hl) : ld l,a
    jp .reenter_scene

.process_scene
    ex de,hl : add hl,bc : ld (next_ticks),hl : ex de,hl

    ld a,(hl) : inc hl : ld (.effect_bank),a : call @sys.swap
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,(hl) : inc hl : ld (de),a
    ld e,(hl) : inc hl : ld d,(hl) : inc hl : ld (.effect_ptr),de
    ld (.scene_ptr),hl

.render_effect
    ld a,0
.effect_bank equ $-1

    call @sys.swap

    call 0
.effect_ptr equ $-2

    ifdef _BORDERMETER : xor a : out (#fe),a : endif

    halt

    ld a,(@sys.swap.or_with) : xor 8 : ld (@sys.swap.or_with),a
    and 8 : rrca : rrca : xor 7 : call @sys.swap
    call @rend.render

    ifdef _BORDERMETER : ld a,2 : out (#fe),a : endif
    jp loop

;-----------------------------------------------------------------------------------------------------------------------

scenes
    dw #0100 : db @bank_eff_raskolbas : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_1 : dw @eff_raskolbas.render
    dw #0100 : db @bank_eff_raskolbas : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_2 : dw @eff_raskolbas.render
    dw #0100 : db @bank_eff_raskolbas : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_3 : dw @eff_raskolbas.render
    dw #0100 : db @bank_eff_raskolbas : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_4 : dw @eff_raskolbas.render

    dw #0100 : db @bank_eff_fire : dw @eff_fire.config : db @eff_fire.cfg_strength_2 : dw @eff_fire.render
    dw #0100 : db @bank_eff_slime : dw @eff_slime.config : db @eff_slime.cfg_strength_2 : dw @eff_slime.render
    dw #0100 : db @bank_eff_fire : dw @eff_fire.config : db @eff_fire.cfg_strength_3 : dw @eff_fire.render
    dw #0100 : db @bank_eff_slime : dw @eff_slime.config : db @eff_slime.cfg_strength_3 : dw @eff_slime.render

    dw #0100 : db @bank_eff_raskolbas : dw @eff_raskolbas.config : db @eff_raskolbas.cfg_strength_5 : dw @eff_raskolbas.render
    dw #0100 : db @bank_eff_interp : dw @eff_interp.config : db @eff_interp.cfg_strength_3 : dw @eff_interp.render

.loop
    dw #0100 : db @bank_eff_plasma : dw @eff_plasma.config : db @eff_plasma.cfg_strength_2 : dw @eff_plasma.render
    dw #0100 : db @bank_eff_interp : dw @eff_interp.config : db @eff_interp.cfg_strength_1 : dw @eff_interp.render
    dw #0100 : db @bank_eff_plasma : dw @eff_plasma.config : db @eff_plasma.cfg_strength_1 : dw @eff_plasma.render
    dw #0100 : db @bank_eff_interp : dw @eff_interp.config : db @eff_interp.cfg_strength_3 : dw @eff_interp.render

    dw #0100 : db @bank_eff_rain : dw @eff_rain.config : db @eff_rain.cfg_strength_1 : dw @eff_rain.render
    dw #0100 : db @bank_eff_rain : dw @eff_rain.config : db @eff_rain.cfg_strength_2 : dw @eff_rain.render

    dw 0 : dw scenes.loop

;-----------------------------------------------------------------------------------------------------------------------

on_int
    ifdef _BORDERMETER : ld a,1 : out (#fe),a : endif

    ld a,1
.is_inactive equ $-1

    and a : ret nz

    ld hl,(ticks) : inc hl : ld (ticks),hl
    ld a,(@sys.bank) : ld (.bank),a

    if @bank_player : ld a,@bank_player : else : xor a : endif
    call @sys.swap : call @player.PLAY

    ld a,0
.bank equ $-1

    jp @sys.swap

on_note
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
