# frozen_string_literal: true

require_relative 'encoder'

class Huffman
  attr_reader :debug

  def initialize(debug = false)
    @debug = debug
  end

  def encode(filename, output_file)
    Encoder.new(debug).encode(filename, output_file)
  end
end
