    module last

;-----------------------------------------------------------------------------------------------------------------------

    display "[ MAIN ]"
    display "first_b : ", @first_b, " ; sizeof first_b : ", /D, @first-@first_b
    display "first   : ", @first,   " ; sizeof first   : ", /D, @entry-@first
    display "entry   : ", @entry,   " ; sizeof entry   : ", /D, @data-@entry
    display "data    : ", @data,    " ; sizeof data    : ", /D, @last-@data
    display "last    : ", @last,    " ; sizeof last    : ", /D, @last_b-@last
    display "last_b  : ", @last_b,  " ; FREE           : ", /D, #be00-@last_b
    display "END     : 0xBE00"
    display " "
    display "[ BANK 0 ]"
    display "last    : ", @bank_0_last,   " ; sizeof last : ", /D, @bank_0_last-#c000
    display "last_b  : ", @bank_0_last_b, " ; FREE        : ", /D, #ffff-@bank_0_last_b+1
    display " "
    display "[ BANK 1 ]"
    display "last    : ", @bank_1_last,   " ; sizeof last : ", /D, @bank_1_last-#c000
    display "last_b  : ", @bank_1_last_b, " ; FREE        : ", /D, #ffff-@bank_1_last_b+1

    savesna "../_build/main.sna", @entry
    labelslist "../_build/main.l"

    savebin "../_build/lfm-main.bin", @first, @last-@first
    page 0 : savebin "../_build/lfm-page0.bin", #c000, @bank_0_last-#c000
    page 1 : savebin "../_build/lfm-page1.bin", #c000, @bank_1_last-#c000

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
