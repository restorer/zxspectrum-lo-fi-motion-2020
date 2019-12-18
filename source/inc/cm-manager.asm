    module mgr

;-----------------------------------------------------------------------------------------------------------------------

init
    halt
    xor a : call @sys.attr_fill

    ld a,5 : call @sys.swap
    call @rend.prepare

    ld a,7 : call @sys.swap
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
    push hl

    ld a,0
.leave_bank equ $-1

    call @sys.swap

    call dummy_leave
.leave_ptr equ $-2

    pop hl
    ld a,(hl) : inc hl : ld (.render_bank),a : ld (.leave_bank),a : call @sys.swap
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,(hl) : inc hl

    push hl
    ex de,hl
    ld de,.after_enter : push de
    jp hl

.after_enter
    pop hl

    ld e,(hl) : inc hl : ld d,(hl) : inc hl : ld (.leave_ptr),de
    ld e,(hl) : inc hl : ld d,(hl) : inc hl : ld (.render_ptr),de
    ld (.scene_ptr),hl

.render_effect
    ld a,0
.render_bank equ $-1

    call @sys.swap

    call 0
.render_ptr equ $-2

    ifdef _BORDERMETER : xor a : out (#fe),a : endif

    ld a,0
.render_skip equ $-1

    and a : jp nz,loop

    halt

    ld a,(@sys.swap.or_with) : xor 8 : ld (@sys.swap.or_with),a
    and 8 : rrca : rrca : xor 7 : call @sys.swap
    call @rend.render

    ifdef _BORDERMETER : ld a,2 : out (#fe),a : endif
    jp loop

;-----------------------------------------------------------------------------------------------------------------------

dummy_leave
    ret

;-----------------------------------------------------------------------------------------------------------------------

scenes
    dw #0100 : db @bank_eff_raskolbas
    dw @eff_raskolbas.enter : db @eff_raskolbas.cfg_strength_1 : dw dummy_leave : dw @eff_raskolbas.render

    dw #0100 : db @bank_eff_raskolbas
    dw @eff_raskolbas.enter : db @eff_raskolbas.cfg_strength_2 : dw dummy_leave : dw @eff_raskolbas.render

    dw #0100 : db @bank_eff_raskolbas
    dw @eff_raskolbas.enter : db @eff_raskolbas.cfg_strength_3 : dw dummy_leave : dw @eff_raskolbas.render

    dw #0100 : db @bank_eff_raskolbas
    dw @eff_raskolbas.enter : db @eff_raskolbas.cfg_strength_4 : dw dummy_leave : dw @eff_raskolbas.render

    ;;;;

    dw #0100 : db @bank_eff_slime
    dw @eff_slime.enter : db @eff_slime.cfg_strength_1 : dw dummy_leave : dw @eff_slime.render

    dw #0080 : db @bank_eff_fire
    dw @eff_fire.enter : db @eff_fire.cfg_strength_1 : dw dummy_leave : dw @eff_fire.render

    dw #0080 : db @bank_eff_fire
    dw @eff_fire.enter : db @eff_fire.cfg_strength_2 : dw dummy_leave : dw @eff_fire.render

    dw #0080 : db @bank_eff_slime
    dw @eff_slime.enter : db @eff_slime.cfg_strength_2 : dw dummy_leave : dw @eff_slime.render

    dw #0080 : db @bank_eff_slime
    dw @eff_slime.enter : db @eff_slime.cfg_strength_3 : dw dummy_leave : dw @eff_slime.render

    dw #0080 : db @bank_eff_fire
    dw @eff_fire.enter : db @eff_fire.cfg_strength_3 : dw dummy_leave : dw @eff_fire.render

    dw #0040 : db @bank_eff_fire
    dw @eff_fire.enter : db @eff_fire.cfg_strength_2 : dw dummy_leave : dw @eff_fire.render

    dw #0040 : db @bank_eff_fire
    dw @eff_fire.enter : db @eff_fire.cfg_strength_1 : dw dummy_leave : dw @eff_fire.render

    ;;;;

    dw #0100 : db @bank_eff_raskolbas
    dw @eff_raskolbas.enter : db @eff_raskolbas.cfg_strength_5 : dw dummy_leave : dw @eff_raskolbas.render

    dw #0100 : db @bank_eff_interp
    dw @eff_interp.enter : db @eff_interp.cfg_strength_2 : dw dummy_leave : dw @eff_interp.render

    ;;;;

    dw #0100 : db @bank_eff_plasma
    dw @eff_plasma.enter : db @eff_plasma.cfg_strength_2 : dw dummy_leave : dw @eff_plasma.render

    dw #0100 : db @bank_eff_interp
    dw @eff_interp.enter : db @eff_interp.cfg_strength_1 : dw dummy_leave : dw @eff_interp.render

    dw #0100 : db @bank_eff_plasma
    dw @eff_plasma.enter : db @eff_plasma.cfg_strength_1 : dw dummy_leave : dw @eff_plasma.render

    dw #0100 : db @bank_eff_interp
    dw @eff_interp.enter : db @eff_interp.cfg_strength_3 : dw dummy_leave : dw @eff_interp.render

    ;;;;

    dw #0100 : db @bank_eff_rain
    dw @eff_rain.enter : db @eff_rain.cfg_strength_1 : dw dummy_leave : dw @eff_rain.render

    dw #0100 : db @bank_eff_rain
    dw @eff_rain.enter : db @eff_rain.cfg_strength_2 : dw dummy_leave : dw @eff_rain.render

    dw #0100 : db 0
    dw @eff_logo.enter : db 0 : dw @eff_logo.leave : dw @eff_logo.render

    dw #0080 : db @bank_eff_burb
    dw @eff_burb.enter : db @eff_burb.cfg_strength_2 : dw dummy_leave : dw @eff_burb.render

    dw #0080 : db @bank_eff_burb
    dw @eff_burb.enter : db @eff_burb.cfg_strength_1 : dw dummy_leave : dw @eff_burb.render

    ;;;;

.loop

    dw #0100 : db @bank_eff_rtzoomer
    dw @eff_rtzoomer.enter : db 0 : dw dummy_leave : dw @eff_rtzoomer.render

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
