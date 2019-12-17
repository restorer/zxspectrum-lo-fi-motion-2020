    module math

;-----------------------------------------------------------------------------------------------------------------------

; OUT:
;   a - next random number
; USE:
;   hl
random_u8
    ld hl,.seed : ld a,(hl)
    dup 7 : inc l : add a,(hl) : ld (hl),a : edup
    ld (.seed),a
    ret

    org (($ + 7) / 8) * 8

.seed
    ;   12345678
    db "TGT_TEAM"

;-----------------------------------------------------------------------------------------------------------------------

; signed DE = signed A
; A = undef
expand_a_de
    ld e,a
    rlca
    sbc a,a
    ld d,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; signed HL = signed A
; A = undef
expand_a_hl
    ld l,a
    rlca
    sbc a,a
    ld h,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; HL = -HL
; A = undef
neg_hl
    ld a,h : cpl : ld h,a
    ld a,l : cpl : ld l,a
    inc hl
    ret

;-----------------------------------------------------------------------------------------------------------------------

; HL = (A * HL * 2) / 256
; actually (A * HL / 128) - saves more precision
mul_s16_s8s16_m2d256
    ld b,0
    ld e,a : rlc e : jp nc,1F
    neg : inc b

1   ld e,a : ld d,0
    ld a,h : rlca : jp nc,2F

    ;; + neg_hl
    ld a,h : cpl : ld h,a
    ld a,l : cpl : ld l,a
    inc hl
    ;; - neg_hl

    inc b

2   ;; + mul_s16_s16s16
    ld a,h
    ld c,l
    ld hl,0

    dup 16
        add hl,hl
        rl c
        rla
        jr nc,$+3
        add hl,de
        ; $+3
    edup
    ;; - mul_s16_s16s16

    xor a
    add hl,hl
    ld l,h
    rla : ld h,a
    rrc b
    ret nc

    ;; + neg_hl
    ld a,h : cpl : ld h,a
    ld a,l : cpl : ld l,a
    inc hl
    ;; - neg_hl

    ret

;-----------------------------------------------------------------------------------------------------------------------

; HL = (A * H * 4) / 256
mul_s16_s8s8_m4d256
    ld b,0
    ld l,a : rlc l : jp nc,1F
    neg : inc b

1   ld e,a : ld d,0
    ld a,h : rlc h : jp nc,2F
    neg : inc b

2   ld l,a : ld h,0

    ;; + mul_u16_u16u16
    ld a,h
    ld c,l
    ld hl,0
    dup 16
        add hl,hl
        rl c
        rla
        jr nc,$+3
        add hl,de
        ; $+3
    edup
    ;; - mul_u16_u16u16

    xor a
    add hl,hl
    rla
    add hl,hl
    rla
    ld l,h : ld h,a
    rrc b
    ret nc

    ;; + neg_hl
    ld a,h : cpl : ld h,a
    ld a,l : cpl : ld l,a
    inc hl
    ;; - neg_hl

    ret

;-----------------------------------------------------------------------------------------------------------------------

; HL = A * HL
mul_s16_s8s16
    call expand_a_de
    ; jp mul_s16_s16s16

; HL = HL * DE
; A,C = UNDEF
mul_s16_s16s16
mul_u16_u16u16
    ld a,h
    ld c,l
    ld hl,0

    dup 16
        add hl,hl
        rl c
        rla
        jr nc,$+3
        add hl,de
        ; $+3
    edup

    ret

;-----------------------------------------------------------------------------------------------------------------------

; H'L'HL = B'C'BC * D'E'DE
; A = UNDEF
mul_u32_u32u32
mul_s32_s32s32
    ld hl,0
    exx
    ld hl,0

    dup 32
        sra b
        rr c
        exx
        rr b
        rr c
        jr nc,$+7
        add hl,de
        exx
        adc hl,de
        exx
        ; $+7
        sla e
        rl d
        exx
        rl e
        rl d
    edup

    exx
    ret

;-----------------------------------------------------------------------------------------------------------------------

; L,D,E = HL * DE
mul_s24_s16s16
    ld b,h : ld c,l
    exx : ld bc,0 : exx
    rlc h
    jp nc,1F
    exx : dec b : dec c : exx

1   exx : ld de,0 : exx
    ld a,d : rlca
    jp nc,2F
    exx : dec d : dec e : exx

2   call mul_u32_u32u32
    ld d,h : ld e,l
    exx : ld a,l : exx : ld l,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; HL = H * E
; D = 0
mul_u16_u8u8
    ld l,0 : ld d,l
    sla h
    jr nc,$+3
    ld l,e
    ; $+3

    dup 7
        add hl,hl
        jr nc,$+3
        add hl,de
        ; $+3
    edup

    ret

;-----------------------------------------------------------------------------------------------------------------------

; D = D / E
; A = D % E
; E = UNDEF
div_u8_u8u8
    xor a

    dup 8
        sla d
        rla
        cp e
        jp c,$+5
        sub e
        inc d
        ; $+5
    edup

    ret

; SLIGHTLY FASTER, BUT NOT WORKING:
;
; ; A = D / E
; ; E = D % E
; ; D = UNDEF
; div_u8_u8u8
;     xor a
;
;     dup 8
;         rl d
;         rla
;         sub e
;         jp nc,$+4
;         add a,e
;         ; $+4
;     edup
;
;     ld e,a
;     ld a,d : cpl
;     ret

;-----------------------------------------------------------------------------------------------------------------------

; DE = DE / BC
; HL = DE % BC
; A = UNDEF
div_u16_u16u16
    ld hl,0

    dup 16
        rl e
        rl d
        adc hl,hl
        sbc hl,bc
        jr nc,$+3
        add hl,bc
        ; $+3
    edup

    ld a,e : rla : cpl : ld e,a
    ld a,d : rla : cpl : ld d,a
    ret

;-----------------------------------------------------------------------------------------------------------------------

; DE = DE / BC
; A,L = UNDEF
div_s16_s16s16
    ld l,0
    ld a,d : rlca : jp nc,1F
    ld a,d : cpl : ld d,a
    ld a,e : cpl : ld e,a
    inc de : inc l

1   ld a,b : rlca : jp nc,2F
    ld a,b : cpl : ld b,a
    ld a,c : cpl : ld c,a
    inc bc : inc l

2   ld a,l : ld (.should_neg),a

    ;; + div_u16_u16u16
    ld hl,0

    dup 16
        rl e
        rl d
        adc hl,hl
        sbc hl,bc
        jr nc,$+3
        add hl,bc
        ; $+3
    edup

    ld a,e : rla : cpl : ld e,a     ; (1) TODO: optimize (see 2)
    ld a,d : rla : cpl : ld d,a
    ;; - div_u16_u16u16

    ld a,#00
.should_neg equ $-1

    rrca : ret nc
    ld a,d : cpl : ld d,a           ; (2) TODO: optimize (see 1)
    ld a,e : cpl : ld e,a
    inc de
    ret

;-----------------------------------------------------------------------------------------------------------------------

; DE = (L,D,E) / BC
; A,H = UNDEF
div_u16_u24u16
    ld a,b : cpl : ld b,a
    ld a,c : cpl : ld c,a
    inc bc

    ld a,l
    ld hl,0
    sla e
    rl d
    rla

    dup 24
        adc hl,hl
        add hl,bc
        jr c,$+4
        sbc hl,bc
        ; $+4
        rl e
        rl d
        rla
    edup

    ret

;-----------------------------------------------------------------------------------------------------------------------

; DE = (L,D,E) / BC
; A,H = UNDEF
; USE STACK
div_s16_s24s16
    ld h,0
    ld a,l : rlca : jp nc,1F
    ld a,l : cpl : ld l,a
    ld a,d : cpl : ld d,a
    ld a,e : cpl : ld e,a
    ld a,e : add a,1 : ld e,a
    ld a,d : adc a,0 : ld d,a
    ld a,l : adc a,0 : ld l,a
    inc h

1   ld a,b : rlca : jp nc,2F
    ld a,b : cpl : ld b,a
    ld a,c : cpl : ld c,a
    inc bc : inc h

2   ld a,h : ld (.should_neg),a
    call div_u16_u24u16 ; TODO: inline

    ld a,#00
.should_neg equ $-1

    rrca : ret nc
    ld a,d : cpl : ld d,a
    ld a,e : cpl : ld e,a
    inc de
    ret

;-----------------------------------------------------------------------------------------------------------------------

; DE = (DE * 256) / BC
; A,L = UNDEF
; USE STACK
div_s16_s16s16_m256
    ld l,0

    ld a,d
    rlca
    jp nc,1F

    inc l
    ld a,d : cpl : ld d,a
    ld a,e : cpl : ld e,a
    inc de

1   ld a,b
    rlca
    jp nc,2F

    inc l
    ld a,b : cpl : ld b,a
    ld a,c : cpl : ld c,a
    inc bc

2   push hl
    ld l,d : ld d,e : ld e,0
    call div_u16_u24u16
    pop hl

    rrc l
    ret nc

    ld a,d : cpl : ld d,a
    ld a,e : cpl : ld e,a
    inc de
    ret

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
