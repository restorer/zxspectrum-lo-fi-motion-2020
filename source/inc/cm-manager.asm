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
    inc a : ld (frames),a

loop
    ld hl,(ticks)

    ld bc,0
.next_effect_ticks equ $-2

    and a : sbc hl,bc : jp c,.render_effect

    ld hl,scenes
.scene_ptr equ $-2

.reenter_scene
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,e : or d : jp nz,.process_scene

    ld a,(hl) : inc hl : ld h,(hl) : ld l,a
    jp .reenter_scene

.process_scene
    ex de,hl : add hl,bc : ld (.next_effect_ticks),hl : ex de,hl
    push hl

    ld a,0
.leave_bank equ $-1

    call @sys.swap

    call dummy_func
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

    ld de,(prev_ticks)
    ld hl,(ticks) : ld (prev_ticks),hl
    and a : sbc hl,de : ld a,l : ld (frames),a

    ld a,(@sys.swap.or_with) : xor 8 : ld (@sys.swap.or_with),a
    and 8 : rrca : rrca : xor 7 : call @sys.swap

    call @rend.render
    call @printer.render

    ifdef _BORDERMETER : ld a,2 : out (#fe),a : endif
    jp loop

;-----------------------------------------------------------------------------------------------------------------------

dummy_func
    ret

;-----------------------------------------------------------------------------------------------------------------------

scenes
    lua allpass
        function make_effect(duration, name, strength)
            sj.add_word(duration)
            sj.parse_code("db @bank_eff_" .. name)
            sj.parse_code("dw @eff_" .. name .. ".enter")

            if strength > 0 then
                sj.parse_code("db @eff_" .. name .. ".cfg_strength_" .. strength)
            else
                sj.add_byte(0)
            end

            sj.parse_code("dw @eff_" .. name .. ".leave")
            sj.parse_code("dw @eff_" .. name .. ".render")
        end

        make_effect(0x0100, "raskolbas", 1)
        make_effect(0x0100, "raskolbas", 2)
        make_effect(0x0100, "raskolbas", 3)
        make_effect(0x0100, "raskolbas", 4)

        --

        make_effect(0x0100, "slime", 1)

        make_effect(0x0080, "fire", 1)
        make_effect(0x0080, "fire", 2)

        make_effect(0x0080, "slime", 2)
        make_effect(0x0080, "slime", 3)

        make_effect(0x0080, "fire", 3)
        make_effect(0x0040, "fire", 2)
        make_effect(0x0040, "fire", 1)

        --

        make_effect(0x0100, "raskolbas", 5)
        make_effect(0x0100, "interp", 2)

        --

        make_effect(0x0100, "plasma", 2)
        make_effect(0x0100, "interp", 1)
        make_effect(0x0100, "plasma", 1)
        make_effect(0x0100, "interp", 3)

        --

        make_effect(0x0100, "rain", 1)
        make_effect(0x0100, "rain", 2)
        make_effect(0x0100, "logo", 0)

        make_effect(0x0080, "burb", 2)
        make_effect(0x0080, "burb", 1)

        --

        make_effect(0x0200, "dina", 1)
        make_effect(0x0200, "rtzoomer", 2)

        --

        make_effect(0x0080, "rbars", 1)
        make_effect(0x0080, "rbars", 2)
        make_effect(0x0100, "dina", 2)

        make_effect(0x0100, "rtzoomer", 1)
        make_effect(0x0080, "rbars", 3)
        make_effect(0x0080, "rbars", 4)

        --

        make_effect(0x0200, "bigpic", 0)

        make_effect(0x0080, "plasma", 2)
        make_effect(0x0080, "interp", 1)
        make_effect(0x0080, "plasma", 1)
        make_effect(0x0040, "interp", 3)
        make_effect(0x0040, "rain", 1)

        --

        make_effect(0x0040, "slime", 3)
        make_effect(0x0020, "slime", 2)
        make_effect(0x0020, "slime", 1)

        make_effect(0x0040, "plasma", 2)
        make_effect(0x0040, "plasma", 1)

        make_effect(0x0040, "fire", 3)
        make_effect(0x0020, "fire", 2)
        make_effect(0x0020, "fire", 1)

        make_effect(0x0040, "interp", 3)
        make_effect(0x0020, "interp", 2)
        make_effect(0x0020, "interp", 1)

        sj.parse_line(".loop")

        make_effect(0x0100, "rain", 2)
        make_effect(0x0100, "rain", 1)

        --

        make_effect(0x100, "dina", 1)
        make_effect(0x100, "rtzoomer", 2)
        make_effect(0x100, "dina", 2)
        make_effect(0x100, "rtzoomer", 1)

    endlua

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
