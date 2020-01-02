#!/usr/bin/ruby

class TapMaker
    def initialize
        @data = []
    end

    # flag
    #   0 - header
    #   255 - data
    def append_block(flag, block)
        block_size = block.size + 2

        @data << block_size % 256
        @data << block_size / 256

        @data << flag
        @data += block

        checksum = flag
        block.each { |v| checksum ^= v }

        @data << checksum
    end

    # tap_type
    #   0 - program
    #   1 - number array
    #   2 - character array
    #   3 - code
    # tap_name
    #   max 10 characters
    # param_1
    #   for tap_type == 0 -- autostart line number (or 32768 if no autostart)
    #   for tap_type == 3 -- start of code block
    def append_file(file_name, is_hobeta, tap_type, tap_name, param_1)
        content = File.read(file_name)
        content = content[17..] if is_hobeta
        content = content.bytes

        block = [tap_type]
        block += ('%-10.10s' % tap_name).bytes

        block << content.size % 256
        block << content.size / 256

        block << param_1 % 256
        block << param_1 / 256

        if tap_type == 0
            param_2 = content.size
        else
            param_2 = 32768
        end

        block << param_2 % 256
        block << param_2 / 256

        append_block(0, block)
        append_block(255, content)
    end

    def save(file_name)
        File.open(file_name, 'wb') do |fo|
            fo << @data.map { |v| v.chr }.join
        end
    end
end

tm = TapMaker.new
tm.append_file(File.dirname(__FILE__) + '/data/LFM-tap.!B', true, 0, 'LFM', 1)
tm.append_file(File.dirname(__FILE__) + '/_build/lfm-pack.bin', false, 3, 'LFM', 28672)
tm.save(File.dirname(__FILE__) + '/_build/lfm.tap')

puts "Tap saved"
