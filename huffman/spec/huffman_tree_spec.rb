require_relative "../huffman_tree"

describe "HuffmanTree" do
  context 'initialize' do
    it 'should create a tree with a root leaf node' do
      tree = HuffmanTree.new(weight: 1, element: 'a')
      expect(tree.root.element).to eq('a')
      expect(tree.root.weight).to eq(1)
      expect(tree.root.leaf?).to be_truthy
    end

    it 'should create a tree with a root non-leaf node' do
      tree = HuffmanTree.new(weight: 3, left: HuffmanNode.new(weight: 2, element: 'b'), right: HuffmanNode.new(weight: 3, element: 'c'))
      expect(tree.root.element).to be_nil
      expect(tree.root.weight).to eq(3)
      expect(tree.root.leaf?).to be_falsey
      expect(tree.root.left.element).to eq('b')
      expect(tree.root.left.weight).to eq(2)
      expect(tree.root.left.leaf?).to be_truthy
      expect(tree.root.right.element).to eq('c')
      expect(tree.root.right.weight).to eq(3)
      expect(tree.root.right.leaf?).to be_truthy
    end
  end

  context 'compare' do
    it 'should compare two trees by their root weight' do
      tree1 = HuffmanTree.new(weight: 1, element: 'a')
      tree2 = HuffmanTree.new(weight: 2, element: 'b')
      expect(tree1 <=> tree2).to eq(-1)
      expect(tree2 <=> tree1).to eq(1)
      expect(tree1 <=> tree1).to eq(0)
    end
  end

  context 'leaf?' do
    it 'should return true if the node is a leaf' do
      tree = HuffmanTree.new(weight: 1, element: 'a')
      expect(tree.root.leaf?).to be_truthy
    end

    it 'should return false if the node is not a leaf' do
      tree = HuffmanTree.new(weight: 1, left: HuffmanNode.new(weight: 2, element: 'b'))
      expect(tree.root.leaf?).to be_falsey
    end
  end

  context 'build_tree' do
    it 'should build a tree and return a root node' do
      frequencies = { 'a' => 1, 'b' => 2, 'c' => 3 }
      tree = HuffmanTree.build_tree(frequencies)
      expect(tree.weight).to eq(6)
    end
  end
end