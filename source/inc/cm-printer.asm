    module printer

;-----------------------------------------------------------------------------------------------------------------------

render
    ld hl,(@mgr.ticks)

    ld bc,0
.next_page_ticks equ $-2

    and a : sbc hl,bc : jp c,.render_page

    ld hl,pages
.page_ptr equ $-2

.reenter_page
    ld e,(hl) : inc hl : ld d,(hl) : inc hl
    ld a,e : or d : jp nz,.process_page

    ld a,(hl) : inc hl : ld h,(hl) : ld l,a
    jp .reenter_page

.process_page
    ex de,hl : add hl,bc : ld (.next_page_ticks),hl : ex de,hl

    ld a,1
    ld (specs+print_spec.curr_ptr),hl
    ld (specs+print_spec.curr_pixels),a
    ld (specs+print_spec+print_spec.curr_ptr),hl
    ld (specs+print_spec+print_spec.curr_pixels),a

.find_next_page
    ld a,(hl) : and a : jp z,.next_page_found

    add a,3 : add a,l : ld l,a
    ld a,h : adc a,0 : ld h,a
    jp .find_next_page

.next_page_found
    inc hl : ld (.page_ptr),hl

.render_page
    ld a,(@sys.bank) : and 2
    ld l,a : srl l
    add a,a : add a,l ; *= 5

    add a,low specs : ld lx,a
    ld a,high specs : adc a,0 : ld hx,a

    ld a,(ix+print_spec.curr_pixels) : and a : jp z,.render_page_attributes
    ld (ix+print_spec.curr_pixels),0

    ld de,(ix+print_spec.prev_ptr)
    ld a,d : or e : call nz,clear_pixels

    ld hl,(ix+print_spec.curr_ptr)
    ld (ix+print_spec.prev_ptr),hl
    jp render_pixels

.render_page_attributes
    ld de,(ix+print_spec.curr_ptr)

; IN:
;   de - *lines
render_attributes
    ld a,(de) : and a : ret z
    inc de : ld b,a

    ld a,(de) : ld l,a : inc de
    ld a,(de) : ld c,a

    ld a,b : inc a : add a,e : ld e,a
    ld a,d : adc a,0 : ld d,a
    push de

    ld a,c : or %01000000 : ld e,a
    ld d,32 : ld h,#d9

.loop
    ld (hl),e
    ld a,l : add a,d : ld l,a
    ld (hl),c
    ld a,l : add a,-31 : ld l,a
    djnz .loop

    pop de
    jp render_attributes

; IN:
;   hl - *lines
render_pixels
    ld a,(hl) : and a : ret z
    inc hl : ld b,a

    ld a,(hl) : inc hl
    exx : ld l,a : ld bc,#c820 : exx

    ld a,(hl) : inc hl
    ld (.color_bottom),a
    or %01000000 : ld (.color_top),a

.loop
    ld a,(hl) : inc hl
    exx : ld e,a

    ld d,high @data.font
    ld h,b

    dup 7 : ld a,(de) : ld (hl),a : inc d : inc h : edup
    ld a,(de) : ld (hl),a

    ld d,high @data.font : set 7,e
    ld h,b : ld a,l : add a,c : ld l,a

    dup 7 : ld a,(de) : ld (hl),a : inc d : inc h : edup
    ld a,(de) : ld (hl),a

    ld h,#d9

    ld (hl),%01001111
.color_bottom equ $-1

    ld a,l : sub c : ld l,a

    ld (hl),%00001111
.color_top equ $-1

    inc l : exx
    djnz .loop
    jp render_pixels

; IN:
;   de - *lines
clear_pixels
    ld a,(de) : and a : ret z
    inc de : ld b,a

    ld a,(de) : ld l,a

    ld a,b : add a,2 : add a,e : ld e,a
    ld a,d : adc a,0 : ld d,a
    push de

    ld c,#c8
    ld de,#ff

.loop
    ld h,c
    dup 4 : ld (hl),d : inc h : edup
    dup 3 : ld (hl),e : inc h : edup : ld (hl),e

    ld h,c : ld a,l : add a,32 : ld l,a
    dup 4 : ld (hl),d : inc h : edup
    dup 3 : ld (hl),e : inc h : edup : ld (hl),e

    ld a,-31 : add a,l : ld l,a
    djnz .loop

    pop de
    jp clear_pixels

;-----------------------------------------------------------------------------------------------------------------------

pages
    lua allpass

        function make_skip(duration)
            sj.add_word(duration)
            sj.add_byte(0)
        end

        function make_page(duration, texts)
            sj.add_word(duration)

            for _, text in ipairs(texts) do
                local str, y, x_off, paper, ink = unpack(text)
                local str_len = str:len()
                local x

                if x_off <= -100 then
                    x = -x_off - 100
                elseif x_off >= 100 then
                    x = 32 - str_len - (x_off - 100)
                else
                    x = math.floor((32 - str_len) / 2) + x_off
                end

                if x < 0 then
                    x = 0
                end

                if x + str_len > 32 then
                    x = 32 - str_len
                end

                sj.add_byte(str_len)
                sj.add_byte(y * 32 + x)
                sj.add_byte(paper * 8 + ink)

                for str_idx = 1, str_len do
                    sj.add_byte(str:byte(str_idx))
                end
            end

            sj.add_byte(0)
        end

        make_skip(0x0100 * 8)

        make_page(0x0010, { { " EMPTY SPACES ", 0, 100, 1, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 102, 3, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 104, 2, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 106, 0, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 108, 2, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 110, 3, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 112, 1, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, 114, 0, 7 } })

        make_page(0x0010, { { " ABANDONED PLACES ", 2, -100, 4, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -102, 7, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -104, 6, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -106, 5, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -108, 4, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -110, 6, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -112, 7, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, -114, 5, 0 } })

        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 101, 1, 7 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 102, 5, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 103, 7, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 104, 3, 7 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 105, 2, 7 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 106, 6, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 107, 4, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 4, 108, 1, 7 } })

        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -101, 0, 4 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -102, 0, 2 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -103, 0, 5 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -104, 0, 1 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -105, 0, 4 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -106, 0, 3 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -107, 0, 6 } })
        make_page(0x0010, { { " THE SHOW MUST GO ON ", 6, -108, 0, 7 } })

        make_skip(0x0100 * 8)

        make_page(0x0020, { { " RESTORER/TGT ", 1, 102, 2, 7 } })
        make_page(0x0020, { { " RESTORER/TGT ", 1, 102, 2, 7 }, { " AS CODER ", 5, -102, 2, 7 } })
        make_page(0x0020, { { " RESTORER/TGT ", 1, 0, 2, 7 }, { " AS CODER ", 5, 0, 2, 7 } })
        make_page(0x0020, { { " RESTORER/TGT ", 0, 0, 2, 7 }, { " AS CODER ", 6, 0, 2, 7 } })

        make_page(0x0020, { { " FATALSNIPE ", 1, 102, 1, 7 } })
        make_page(0x0020, { { " FATALSNIPE ", 1, 102, 1, 7 }, { " AS MUSICIAN ", 5, -102, 1, 7 } })
        make_page(0x0020, { { " FATALSNIPE ", 1, 0, 1, 7 }, { " AS MUSICIAN ", 5, 0, 1, 7 } })
        make_page(0x0020, { { " FATALSNIPE ", 0, 0, 1, 7 }, { " AS MUSICIAN ", 6, 0, 1, 7 } })

        make_page(0x0020, { { " ROC/LSK ", 1, 102, 6, 0 } })
        make_page(0x0020, { { " ROC/LSK ", 1, 102, 6, 0 }, { " AS ARTIST ", 5, -102, 6, 0 } })
        make_page(0x0020, { { " ROC/LSK ", 1, 0, 6, 0 }, { " AS ARTIST ", 5, 0, 6, 0 } })
        make_page(0x0020, { { " ROC/LSK ", 0, 0, 6, 0 }, { " AS ARTIST ", 6, 0, 6, 0 } })

        make_page(0x0008, { { " P ", 3, -3, 7, 0 } })
        make_page(0x0008, { { " PR ", 3, -3, 7, 0 } })
        make_page(0x0008, { { " PRE ", 3, -2, 7, 0 } })
        make_page(0x0008, { { " PRES ", 3, -2, 7, 0 } })
        make_page(0x0008, { { " PRESE ", 3, -1, 7, 0 } })
        make_page(0x0008, { { " PRESEN ", 3, -1, 7, 0 } })
        make_page(0x0008, { { " PRESENT ", 3, 0, 7, 0 } })
        make_page(0x0048, { { " PRESENTS ", 3, 0, 7, 0 } })

        make_page(0x0020, { { " A NEW DEMO ", 3, 0, 2, 7 } })
        make_page(0x0020, { { " A NEW DEMO ", 1, 0, 2, 7 }, { " ESPECIALLY FOR ", 5, 0, 5, 0 } })
        make_page(0x0040, { { " A NEW DEMO ", 0, 0, 2, 7 }, { " ESPECIALLY FOR ", 3, 0, 5, 0 }, { " DIHALT WINTER 2020 ", 6, 0, 1, 7 } })

        make_page(0x0020, { { " LO ", 3, -7, 0, 7 } })
        make_page(0x0020, { { " LO ", 3, -7, 0, 7 }, { " FI ", 3, -2, 0, 7 } })
        make_page(0x0020, { { " LO ", 3, -7, 0, 7 }, { " FI ", 3, -2, 0, 7 }, { " MOTION ", 3, 5, 0, 7 } })
        make_page(0x0020, { { " LO FI MOTION ", 3, 0, 0, 7 } })

        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 3 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 6 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 2 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 5 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 4 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 1 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 3 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 7 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 1 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 4 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 2 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 3 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 6 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 1 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 5 } })
        make_page(0x0010, { { " LO FI MOTION ", 3, 0, 0, 7 } })

        make_skip(0x0200 * 4)

        make_page(0x0080, { { " LEAVES HAS FALLEN ", 3, -102, 3, 7 } })
        make_page(0x0080, { { " EFFECTS HAVE BEEN SHOWN ", 3, -104, 1, 7 } })
        make_page(0x0080, { { " TIME HAS COME ", 3, 106, 2, 7 } })
        make_page(0x0080, { { " THE DEMO IS OVER ", 3, 102, 0, 7 } })

        sj.parse_line(".loop")

        make_page(0x0080, { { " AND NOW ", 0, 0, 4, 0 } })
        make_page(0x0080, { { " WE WANT TO ", 2, 0, 5, 0 } })
        make_page(0x0080, { { " SEND GREETZ ", 4, 0, 3, 7 } })
        make_page(0x0080, { { " TO THE LEGENDS ", 6, 0, 1, 7 } })

        make_page(0x0010, { { " GREETZ: 1 ", 6, 8, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 3 ", 0, 1, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 2 ", 5, -5, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 3 ", 2, 5, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 4 ", 5, 6, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 2 ", 6, 4, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 6, 3, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 5 ", 0, -7, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 3 ", 1, -2, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 0 ", 3, -4, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 4, 7, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 1 ", 6, -8, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 4 ", 1, -2, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 2 ", 0, 0, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 2 ", 6, -4, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 4 ", 4, 5, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 7 ", 0, 2, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 0 ", 5, -8, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 5, -4, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 2 ", 6, 5, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 5 ", 3, 6, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 0 ", 3, 4, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 0 ", 1, 8, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 0 ", 1, 0, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 3, -7, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 4 ", 2, 2, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 4 ", 4, -5, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 4 ", 1, 1, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 6 ", 2, 6, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 6 ", 0, -2, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 3 ", 1, -5, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 6 ", 5, -7, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 0 ", 1, 7, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 3 ", 4, 4, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 3, -3, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 5 ", 1, 2, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 5 ", 5, 1, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 6 ", 4, 7, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 1 ", 4, -4, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 1 ", 3, -5, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 2 ", 4, -1, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 4, -8, 7, 0 } })
        make_page(0x0010, { { " GREETZ: 4 ", 3, -1, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 5 ", 6, -6, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 6 ", 2, -3, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 4 ", 6, -6, 4, 0 } })
        make_page(0x0010, { { " GREETZ: 2 ", 3, 1, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 6 ", 0, -6, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 5 ", 4, -2, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 1 ", 2, 0, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 3 ", 2, -6, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 1 ", 0, 4, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 5 ", 2, -3, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 5 ", 6, 5, 5, 0 } })
        make_page(0x0010, { { " GREETZ: 0 ", 2, -3, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 6 ", 0, 3, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 6 ", 5, 2, 6, 0 } })
        make_page(0x0010, { { " GREETZ: 1 ", 1, -1, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 0 ", 0, 3, 0, 7 } })
        make_page(0x0010, { { " GREETZ: 1 ", 2, 3, 1, 7 } })
        make_page(0x0010, { { " GREETZ: 3 ", 3, -1, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 3 ", 0, 0, 3, 7 } })
        make_page(0x0010, { { " GREETZ: 2 ", 5, 8, 2, 7 } })
        make_page(0x0010, { { " GREETZ: 7 ", 5, 6, 7, 0 } })

    endlua

    dw 0 : dw pages.loop

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
