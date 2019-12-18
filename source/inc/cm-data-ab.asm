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

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
