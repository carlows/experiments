def checksum(input)
  items = input.strip.chars.map { |c| c.to_i }
  chunks = split_items_in_chunks(items)

  (chunks.size - 1).downto(0) do |index|
    # means it's a file chunk, so we attempt to move it once
    if index.even? && chunks[index].size > 0
      file = chunks[index]
      file_size = file.size
      
      # always start from the start to find our free spaces
      (0...index).each do |free_space_index|
        chunk = chunks[free_space_index]
        free_space = chunk_free_space(chunk)

        if free_space >= file_size
          replacements = 0

          (0...chunk.size).each do |chunk_index|
            break if replacements >= file_size

            if chunk[chunk_index].nil?
              chunk[chunk_index] = file[replacements]
              file[replacements] = nil
              replacements += 1
            end
          end
          break # make sure not to keep finding free spaces if we already found a fitting space
        end
      end
    end
  end

  calculate_checksum(chunks.flatten)
end

def split_items_in_chunks(items)
  chunks = []
  items.each_with_index do |item, index|
    if index.even?
      chunk = item.times.map { index / 2 }
    else
      chunk = item.times.map { nil }
    end
    chunks << chunk
  end
  chunks
end

def chunk_free_space(chunk)
  chunk.filter(&:nil?).size
end

def calculate_checksum(file)
  checksum = 0
  file.each_with_index do |id, position|
    next unless id
    checksum += id * position
  end
  checksum
end

require_relative './assert'

extend SuperDuperAssertions

assert("calculates the result for part 2", checksum("2333133121414131402"), 2858)

file = File.readlines('./input09.txt')[0]
assert("calculates the real result", checksum(file), 6415163624282)
