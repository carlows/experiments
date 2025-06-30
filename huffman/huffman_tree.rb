# frozen_string_literal: true

require_relative 'priority_queue'

class HuffmanTree
  attr_reader :root

  def initialize(weight:, element: nil, left: nil, right: nil)
    @root = HuffmanNode.new(weight:, element:, left:, right:)
  end

  def weight
    root.weight
  end

  def <=>(other)
    root.weight <=> other.root.weight
  end

  def self.build_tree(frequencies)
    trees = frequencies.map { |element, frequency| HuffmanTree.new(weight: frequency, element:) }
    priority_queue = PriorityQueue.new
    trees.each { |tree| priority_queue.insert(tree) }
    tree = nil

    while priority_queue.size > 1
      left = priority_queue.extract_min
      right = priority_queue.extract_min
      
      tree = HuffmanTree.new(weight: left.weight + right.weight, left: left.root, right: right.root)
      priority_queue.insert(tree)
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