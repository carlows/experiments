# frozen_string_literal: true

require_relative 'huffman_tree'

class Huffman
  def encode(filename)
    frequencies = File.read(filename).split('').tally
    tree = HuffmanTree.build_tree(frequencies)
    tree.root
  end
end