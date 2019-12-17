    module data

;-----------------------------------------------------------------------------------------------------------------------

    org (($ + 255) / 256) * 256

sintab

    lua allpass
        for i = 0, 255 do
            local val = math.floor(math.sin(i * math.pi / 128) * 127) + 128
            sj.add_byte(val)
        end
    endlua

    display "end of sintab = ", $

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
