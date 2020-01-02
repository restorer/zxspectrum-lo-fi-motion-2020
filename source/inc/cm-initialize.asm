    module initialize

;-----------------------------------------------------------------------------------------------------------------------

    di

    ld hl,#BE00
    ld de,#BE01
    ld bc,#0100
    ld (hl),#BF
    ldir

    ld a,#C3
    ld (#BFBF),a
    ld hl,@sys.int_handler
    ld (#BFC0),hl

    ld a,#BE
    ld i,a
    im 2

    ld sp,@first_b
    ei

    ;;;;

    ld hl,@last
    ld de,@last+1
    ld bc,@last_b-@last-1
    xor a : ld (hl),a
    ldir

    xor a : call @sys.swap

    ld hl,@bank_0_last
    ld de,@bank_0_last+1
    ld bc,@bank_0_last_b-@bank_0_last-1
    xor a : ld (hl),a
    ldir

    ld a,1 : call @sys.swap

    ld hl,@bank_1_last
    ld de,@bank_1_last+1
    ld bc,@bank_1_last_b-@bank_1_last-1
    xor a : ld (hl),a
    ldir

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
