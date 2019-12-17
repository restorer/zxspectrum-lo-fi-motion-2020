    device zxspectrum128

; inc/<prefix>-name-<suffix>.asm
;
; prefix:
;     cm - code main
;     cp - code page
;     vm - vars main
;     vp - vars page
;     lua - lua functions
;     misc - miscellanious
;
; suffix:
;     as - aligned start
;     ae - aligned end
;     ab - aligned both (start and end)

    ; define _BORDERMETER

;-----------------------------------------------------------------------------------------------------------------------

@bank_player equ 0
@bank_eff_fire equ 0
@bank_eff_rain equ 0
@bank_eff_slime equ 0
@bank_eff_interp equ 0
@bank_eff_raskolbas equ 0
@bank_eff_plasma equ 0

;-----------------------------------------------------------------------------------------------------------------------

    org #c000,0

@music
    incbin "data/music.pt3"

    include "inc/cp-pt3player-as.asm"
    include "inc/cp-eff-fire.asm"
    include "inc/cp-eff-rain.asm"
    include "inc/cp-eff-slime.asm"
    include "inc/cp-eff-interp.asm"
    include "inc/cp-eff-raskolbas.asm"
    include "inc/cp-eff-plasma.asm"

@bank_0_last
    include "inc/vp-pt3player.asm"

@bank_0_last_b

;-----------------------------------------------------------------------------------------------------------------------

;-----------------------------------------------------------------------------------------------------------------------

    org #6000

@first_b

@first

@entry
    include "inc/cm-initialize.asm"

    ld a,@bank_player : call @sys.swap
    ld hl,@music : call @player.INIT

    call @mgr.init
    jp @mgr.run

    include "inc/cm-system.asm"
    include "inc/cm-manager.asm"
    include "inc/cm-math.asm"
    include "inc/cm-data.asm"
    include "inc/cm-renderer-as.asm"

@data

@last

    include "inc/vm-system.asm"
    include "inc/vm-manager.asm"
    include "inc/vm-renderer-as.asm"

@last_b
    include "inc/misc-last.asm"
