# frozen_string_literal: true

require_relative 'huffman_tree'
require_relative 'prefix_codes'
require 'json'

class Encoder
  attr_reader :debug

  def initialize(debug = false)
    @debug = debug
  end

  # Our encoded binary file structure has the following format:
    # 4 bytes: length of the JSON table
    # N bytes: the JSON table
    # 1 byte: padding length
    # N bytes: the encoded data
  def encode(filename, output_file)
    content = File.read(filename)
    frequencies = content.split('').tally
    tree = HuffmanTree.build_tree(frequencies)
    prefix_codes = PrefixCodes.new(tree)
    table = prefix_codes.generate_table
    encoded_bytes, padding_length = encoded_text(content, table)

    File.open(output_file, 'wb') do |file|
      # Convert JSON table to bytes
      json_bytes = table.to_json.bytes
      
      # Write JSON length as uint32 (4 bytes, little-endian)
      file.write([json_bytes.length].pack('V'))
      
      # Write JSON bytes
      file.write(json_bytes.pack('C*'))
      
      # Write padding length as uint8 (1 byte)
      file.write([padding_length].pack('C'))
      
      # Write encoded data
      file.write(encoded_bytes)
    end
    
    # Show compression info
    show_compression_info(content, encoded_bytes, table, padding_length) if debug
  end

  private

  def encoded_text(content, table)
    # Convert each character to its binary code and join them
    binary_string = content.split('').map { |char| table[char] }.join('')
    
    # Pad the binary string to make it a multiple of 8
    padding_length = (8 - (binary_string.length % 8)) % 8
    binary_string += '0' * padding_length
    
    # Convert binary string to bytes
    encoded_bytes = [binary_string].pack('B*')
    [encoded_bytes, padding_length]
  end

  def show_compression_info(content, encoded_bytes, table, padding_length)
    # Calculate the raw binary string before padding
    raw_binary_string = content.split('').map { |char| table[char] }.join('')
    raw_bits = raw_binary_string.length
    
    original_bits = content.length * 8
    encoded_bits = encoded_bytes.length * 8
    padding_bits = padding_length
    
    puts "Compression Analysis:"
    puts "Original text: #{content.length} characters = #{original_bits} bits"
    puts "Raw encoded (before padding): #{raw_bits} bits"
    puts "Final encoded (after padding): #{encoded_bits} bits"
    puts "Padding added: #{padding_bits} bits"
    puts "Compression ratio: #{(encoded_bits.to_f / original_bits * 100).round(1)}%"
    puts "Space saved: #{original_bits - encoded_bits} bits"
  end
end