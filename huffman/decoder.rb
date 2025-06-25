# frozen_string_literal: true

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

      prefix_table
    end
  end
end