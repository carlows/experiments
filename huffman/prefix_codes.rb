# frozen_string_literal: true

class PrefixCodes
  def initialize(tree)
    @tree = tree
  end

  def generate_table
    table = {}
    generate(@tree.root, '', table)
    table
  end

  private

  def generate(node, prefix, table)
    if node.leaf?
      table[node.element] = prefix
      return
    end

    generate(node.left, prefix + '0', table)
    generate(node.right, prefix + '1', table)
  end
end