def checksum(input)
  items = input.strip.chars.map { |c| c.to_i }
  uncompressed = []
  id = 0

  items.each_with_index do |item, index|
    if index.even?
      item.times { uncompressed << id }
      id += 1
    else
      item.times { uncompressed << nil }
    end
  end

  left = 0
  right = uncompressed.size - 1

  while left < right
    if uncompressed[left] == nil
      while uncompressed[right] == nil
        right -= 1
      end
      next unless left < right

      tmp = uncompressed[left]
      uncompressed[left] = uncompressed[right]
      uncompressed[right] = tmp
      right -= 1
    end

    left += 1
  end

  checksum = 0
  uncompressed.each_with_index do |id, position|
    next unless id
    checksum += id * position
  end

  checksum
end

require_relative './assert'

extend SuperDuperAssertions

assert("calculates the result for a simple input", checksum("12345"), 60)

assert("handles zeros", checksum("101010"), 5)

assert("test1", checksum("90909"), 513)

assert("handles multiple zeroes", checksum("10000"), 0)

assert("just zeroes", checksum("000000000"), 0)

assert("just ones", checksum("111111111"), 23)

assert("calculates the result for the sample input in page", checksum("2333133121414131402"), 1928)

assert("sample input", checksum("748770289980535691"), 8046)

assert("sample input", checksum("111111111111111111111111"), 381)

file = File.readlines('./input09.txt')[0]
assert("calculates the real result", checksum(file), 6385338159127)
