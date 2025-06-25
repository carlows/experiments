# frozen_string_literal: true

require 'sorted_set'

class HuffmanTree
  attr_reader :root

  def initialize(weight:, element: nil, left: nil, right: nil)
    @root = HuffmanNode.new(weight:, element:, left:, right:)
  end

  def weight
    root.weight
  end

  def <=>(other)
    weight_comparison = root.weight <=> other.root.weight
    return weight_comparison unless weight_comparison == 0
    
    # If weights are equal, use object_id to maintain uniqueness
    object_id <=> other.object_id
  end

  def self.build_tree(frequencies)
    trees = frequencies.map { |element, frequency| HuffmanTree.new(weight: frequency, element:) }
    sorted_set = SortedSet.new(trees)
    tree = nil
    
    while sorted_set.size > 1
      left = sorted_set.first
      sorted_set.delete(left)
      right = sorted_set.first
      sorted_set.delete(right)
      
      tree = HuffmanTree.new(weight: left.weight + right.weight, left: left.root, right: right.root)
      sorted_set.add(tree)
    end

    tree
  end
end

class HuffmanNode
  attr_reader :weight, :element, :left, :right

  def initialize(weight:, element: nil, left: nil, right: nil)
    @weight = weight
    @element = element
    @left = left
    @right = right
  end

  def leaf?
    !element.nil?
  end
end