require_relative "../priority_queue"
require_relative "../huffman_tree"

describe PriorityQueue do
  context 'insert' do
    it 'inserts the first element in the queue' do
      queue = PriorityQueue.new
      queue.insert(1)
      expect(queue.heap).to eq([1])
    end

    it 'inserts the second element in the queue' do
      queue = PriorityQueue.new
      queue.insert(2)
      queue.insert(1)
      expect(queue.heap).to eq([1, 2])
    end

    it 'inserts the third element in the queue' do
      queue = PriorityQueue.new
      queue.insert(2)
      queue.insert(3)
      queue.insert(1)
      expect(queue.heap).to eq([1, 3, 2])
    end
  end 

  context 'min' do
    it 'returns the minimum element in the queue' do
      queue = PriorityQueue.new
      queue.insert(2)
      queue.insert(1)
      expect(queue.min).to eq(1)
    end
  end

  context 'extract_min' do
    it 'returns the minimum element in the queue' do
      queue = PriorityQueue.new
      queue.insert(2)
      queue.insert(1)
      expect(queue.extract_min).to eq(1)
    end

    it 'removes the minimum element from the queue' do
      queue = PriorityQueue.new
      queue.insert(2)
      queue.insert(3)
      queue.insert(3)
      queue.insert(2)
      queue.insert(1)
      queue.extract_min
      expect(queue.heap).to eq([2, 2, 3, 3])
    end

    it 'returns nil if the queue is empty' do
      queue = PriorityQueue.new
      expect(queue.extract_min).to eq(nil)
    end

    it 'removes the last element from the queue' do
      queue = PriorityQueue.new
      queue.insert(1)
      queue.extract_min
      expect(queue.heap).to eq([])
    end
  end

  context 'works with objects that implement <=>' do
    it 'works with objects that implement <=>' do
      queue = PriorityQueue.new
      tree1 = HuffmanTree.new(weight: 1)
      tree2 = HuffmanTree.new(weight: 2)

      queue.insert(tree1)
      queue.insert(tree2)
      expect(queue.extract_min).to eq(tree1)
    end
  end
end