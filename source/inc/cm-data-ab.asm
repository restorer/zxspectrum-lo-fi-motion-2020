    module data

;-----------------------------------------------------------------------------------------------------------------------

    org (($ + 255) / 256) * 256

sintab_u8
    lua allpass
        for i = 0, 255 do
            local val = math.floor(math.sin(i * math.pi / 128) * 127) + 128
            sj.add_byte(val)
        end
    endlua

sintab_s8
    lua allpass
        for i = 0, 255 do
            local val = math.floor(math.sin(i * math.pi / 128) * 127)
            sj.add_byte(val)
        end
    endlua

tex_16x16_1
    incbin "../data/tex_16x16_1.dat"

tex_16x16_2
    incbin "../data/tex_16x16_2.dat"

font
    lua allpass
        local fp = assert(io.open("data/font.s", "rb"))
        local data = fp:read("*all")
        assert(fp:close())

        for line = 0, 7 do
            for half = 0, 1 do
                for char = 0, 127 do
                    sj.add_byte(data:byte(half * 32 + math.floor(char / 32) * 64 + (char % 32) + line * 256 + 1))
                end
            end
        end
    endlua

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
