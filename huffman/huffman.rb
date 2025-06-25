# frozen_string_literal: true

require_relative 'huffman_tree'
require_relative 'prefix_codes'

class Huffman
  def encode(filename)
    frequencies = File.read(filename).split('').tally
    tree = HuffmanTree.build_tree(frequencies)
    prefix_codes = PrefixCodes.new(tree)
    prefix_codes.generate_table
  end
end