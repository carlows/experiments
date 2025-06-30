# frozen_string_literal: true

class PriorityQueue
  attr_reader :heap

  def initialize()
    @heap = []
  end

  def insert(element)
    @heap << element
    heapify_up
  end

  def size
    @heap.size
  end

  def min
    @heap.first
  end

  def extract_min
    return nil if @heap.empty?
    
    min = @heap.first
    
    if @heap.size == 1
      @heap.clear
    else
      @heap[0] = @heap.pop
      heapify_down
    end
    
    min
  end


  private

  def heapify_up
    current_index = heap.size - 1

    while has_parent?(current_index) && (heap[current_index] <=> heap[parent(current_index)]) < 0
      swap(current_index, parent(current_index))
      current_index = parent(current_index)
    end
  end

  def heapify_down
    current_index = 0

    while left_child_index(current_index) < heap.size
      smaller_child_index = left_child_index(current_index)

      if right_child_index(current_index) < heap.size && (heap[right_child_index(current_index)] <=> heap[smaller_child_index]) < 0
        smaller_child_index = right_child_index(current_index)
      end

      break if (heap[current_index] <=> heap[smaller_child_index]) < 0

      swap(current_index, smaller_child_index)
      current_index = smaller_child_index
    end
  end

  def left_child_index(index)
    (index * 2) + 1
  end

  def right_child_index(index)
    (index * 2) + 2
  end

  def has_parent?(index)
    index > 0
  end

  def parent(index)
    (index - 1) / 2
  end

  def swap(index1, index2)
    heap[index1], heap[index2] = heap[index2], heap[index1]
  end
end