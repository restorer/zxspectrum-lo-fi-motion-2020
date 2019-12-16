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

    org #6000

@first_b

@first

@entry
    include "inc/cm-initialize.asm"

    call @mgr.init
    jp @mgr.run

    include "inc/cm-system.asm"
    include "inc/cm-manager.asm"
    include "inc/cp-math.asm"
    include "inc/cp-eff-fire.asm"
    include "inc/cp-eff-rain.asm"
    include "inc/cp-eff-slime.asm"
    include "inc/cm-renderer-as.asm"
    include "inc/cp-pt3player-as.asm"

@data

@last

    include "inc/vm-system.asm"
    include "inc/vp-pt3player.asm"
    include "inc/vm-renderer-as.asm"

@last_b
    include "inc/misc-last.asm"
