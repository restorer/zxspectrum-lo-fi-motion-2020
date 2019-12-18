    lua allpass

-- -----------------------------------------------------------------------------------------------------------------------

    function bit_and(a, b)
        local result = 0
        local bit = 1

        while a > 0 and b > 0 do
            if (a % 2 == 1) and (b % 2 == 1) then
                result = result + bit
            end

            bit = bit * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end

        return result
    end

    function bit_or(a, b)
        local result = 0
        local bit = 1

        while a > 0 or b > 0 do
            if (a % 2 == 1) or (b % 2 == 1) then
                result = result + bit
            end

            bit = bit * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end

        return result
    end

    function bit_xor(a, b)
        local result = 0
        local bit = 1

        while a > 0 or b > 0 do
            if ((a % 2 == 1) and (b % 2 == 0)) or ((a % 2 == 0) and (b % 2 == 1)) then
                result = result + bit
            end

            bit = bit * 2
            a = math.floor(a / 2)
            b = math.floor(b / 2)
        end

        return result
    end

    function bit_lshift(a, b)
        return a * math.pow(2, b)
    end

    function bit_rshift(a, b)
        return math.floor(a / math.pow(2, b))
    end

-- -----------------------------------------------------------------------------------------------------------------------

    endlua
