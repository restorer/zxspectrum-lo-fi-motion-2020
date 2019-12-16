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

    savesna "../_build/main.sna", @entry
    labelslist "../_build/main.l"

;-----------------------------------------------------------------------------------------------------------------------

    endmodule
