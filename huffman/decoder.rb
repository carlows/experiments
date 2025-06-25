# frozen_string_literal: true

require 'stringio'

class Decoder
  attr_reader :debug

  def initialize(debug = false)
    @debug = debug
  end

  def decode(filename, output_file)
    File.open(filename, 'rb') do |file|
      prefix_table_length = file.read(4).unpack('V').first
      prefix_table_json = file.read(prefix_table_length)
      prefix_table = JSON.parse(prefix_table_json)
      puts "Prefix table: #{prefix_table}" if debug

      padding_length = file.read(1).unpack('C').first
      encoded_data = file.read
      puts "Padding length: #{padding_length}" if debug
      puts "Encoded data size: #{encoded_data.size}" if debug

      decoded_data = decode_data(encoded_data, prefix_table, padding_length)

      File.write(output_file, decoded_data)
    end
  end

  private

  def decode_data(encoded_data, prefix_table, padding_length)
    decoded_data = StringIO.new
    current_bits = ''

    reverse_table = prefix_table.invert
    puts "Table reversed!" if debug
    
    binary_string = encoded_data.unpack('B*').first
    binary_string = binary_string[0...-padding_length] if padding_length > 0
    
    total_bits = binary_string.length
    
    binary_string.each_char.with_index do |bit, index|
      current_bits += bit
      
      if reverse_table.key?(current_bits)
        decoded_data << reverse_table[current_bits]
        current_bits = ''
      end
      
      # Show progress every 10000 bits when debug is enabled
      if debug && index % 10000 == 0
        progress = (index.to_f / total_bits * 100).round(1)
        puts "Decoding progress: #{progress}% (#{index}/#{total_bits} bits)"
      end
    end
    
    decoded_data.string
  end
end
