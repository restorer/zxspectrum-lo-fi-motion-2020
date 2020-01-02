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

        __rand_seed = 4314110594

        function rand_init(seed)
            __rand_seed = seed
        end

        function rand_next()
            __rand_seed = (__rand_seed * 0x05deece66d + 0x0b) % 0x1000000000000
            return __rand_seed / 0x1000000000000
        end

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

                sj.add_byte(str_len)
                sj.add_byte(y * 32 + x)
                sj.add_byte(paper * 8 + ink)

                for str_idx = 1, str_len do
                    sj.add_byte(str:byte(str_idx))
                end
            end

            sj.add_byte(0)
        end

        function make_page_rnd(duration, str)
            str = " " .. str .. " "

            local y = math.floor(rand_next() * (3 + 1)) * 2
            local x = math.floor(rand_next() * (28 - str:len() + 1)) + 2
            local paper = math.floor(rand_next() * 7)
            local ink

            if paper < 4 then
                ink = 7
            else
                ink = 0
            end

            make_page(duration, { { str, y, -100 - x, paper, ink } })
        end

        make_skip(0x0100 * 8)

        make_page(0x0010, { { " EMPTY SPACES ", 0, -102, 1, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 2, -102, 3, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 4, -102, 2, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 6, -102, 0, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 0, -102, 2, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 2, -102, 3, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 4, -102, 1, 7 } })
        make_page(0x0010, { { " EMPTY SPACES ", 6, -102, 0, 7 } })

        make_page(0x0010, { { " ABANDONED PLACES ", 6, 102, 4, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 4, 102, 7, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, 102, 6, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 0, 102, 5, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 6, 102, 4, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 4, 102, 6, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 2, 102, 7, 0 } })
        make_page(0x0010, { { " ABANDONED PLACES ", 0, 102, 5, 0 } })

        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 101, 1, 7 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 102, 5, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 103, 7, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 104, 3, 7 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 105, 2, 7 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 106, 6, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 107, 4, 0 } })
        make_page(0x0010, { { " BEHIND THE CURTAIN ", 0, 108, 1, 7 } })

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

        make_page(0x0020, { { " A NEW DEMO ", 0, 0, 2, 7 } })
        make_page(0x0020, { { " A NEW DEMO ", 0, 0, 2, 7 }, { " ESPECIALLY FOR ", 3, 0, 5, 0 } })
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

        make_page(0x0080, { { " LEAVES HAVE FALLEN ", 3, -102, 3, 7 } })
        make_page(0x0080, { { " EFFECTS HAVE BEEN SHOWN ", 3, -104, 1, 7 } })
        make_page(0x0080, { { " TIME HAS COME ", 3, 106, 2, 7 } })
        make_page(0x0080, { { " THE DEMO IS OVER ", 3, 102, 0, 7 } })

        sj.parse_line(".loop")

        make_page(0x0080, { { " AND NOW ", 0, 0, 4, 0 } })
        make_page(0x0080, { { " WE WANT TO ", 2, 0, 5, 0 } })
        make_page(0x0080, { { " SEND GREETZ ", 4, 0, 3, 7 } })
        make_page(0x0080, { { " TO THE LEGENDS ", 6, 0, 1, 7 } })

        make_page_rnd(0x0010, "COPPERFEET")
        make_page_rnd(0x0010, "BILL GILBERT")
        make_page_rnd(0x0010, "RST#7")
        make_page_rnd(0x0010, "MAX IWAMOTO")
        make_page_rnd(0x0010, "KLAV")
        make_page_rnd(0x0010, "VASILYEV ANTON")
        make_page_rnd(0x0010, "KANO")
        make_page_rnd(0x0010, "KSA")
        make_page_rnd(0x0010, "AIG")
        make_page_rnd(0x0010, "TITOV ANDREI")
        make_page_rnd(0x0010, "BUSY")
        make_page_rnd(0x0010, "NORO")
        make_page_rnd(0x0010, "KAZ")
        make_page_rnd(0x0010, "MAT")
        make_page_rnd(0x0010, "MUAD'DIB")
        make_page_rnd(0x0010, "RACKNE")
        make_page_rnd(0x0010, "ZIUTEK")
        make_page_rnd(0x0010, "FREEMAN")
        make_page_rnd(0x0010, "MAST")
        make_page_rnd(0x0010, "IMP")
        make_page_rnd(0x0010, "SHAMAN")
        make_page_rnd(0x0010, "VMP")
        make_page_rnd(0x0010, "STALKER")
        make_page_rnd(0x0010, "KVA")
        make_page_rnd(0x0010, "RUM")
        make_page_rnd(0x0010, "SCRATCHER")
        make_page_rnd(0x0010, "EXPLODER")
        make_page_rnd(0x0010, "SNAKE")
        make_page_rnd(0x0010, "FLYING")
        make_page_rnd(0x0010, "ARTY")
        make_page_rnd(0x0010, "TERROR")
        make_page_rnd(0x0010, "JOE")
        make_page_rnd(0x0010, "SAURON")
        make_page_rnd(0x0010, "DIVER")
        make_page_rnd(0x0010, "VIATOR")
        make_page_rnd(0x0010, "FACTOR 6")
        make_page_rnd(0x0010, "CAT-MAN")
        make_page_rnd(0x0010, "MAGIC")
        make_page_rnd(0x0010, "TEERAY")
        make_page_rnd(0x0010, "VISUAL")
        make_page_rnd(0x0010, "VOXON")
        make_page_rnd(0x0010, "EVOLVER")
        make_page_rnd(0x0010, "PARACELS")
        make_page_rnd(0x0010, "SAIROOS")
        make_page_rnd(0x0010, "DMAN")
        make_page_rnd(0x0010, "SPY")
        make_page_rnd(0x0010, "AGENT-X")
        make_page_rnd(0x0010, "JORDAN")
        make_page_rnd(0x0010, "EA")
        make_page_rnd(0x0010, "MMCM")
        make_page_rnd(0x0010, "TANKARD")
        make_page_rnd(0x0010, "DOC")
        make_page_rnd(0x0010, "ROM")
        make_page_rnd(0x0010, "FUX")
        make_page_rnd(0x0010, "MIC")
        make_page_rnd(0x0010, "KOLVER")
        make_page_rnd(0x0010, "DARK")
        make_page_rnd(0x0010, "FYREX")
        make_page_rnd(0x0010, "WOLF")
        make_page_rnd(0x0010, "GANS")
        make_page_rnd(0x0010, "FLYER")
        make_page_rnd(0x0010, "UNBELIVER")
        make_page_rnd(0x0010, "MAXSOFT")
        make_page_rnd(0x0010, "MONSTER")

    endlua

    dw 0 : dw pages.loop

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
