require 'benchmark'

def stones(input, blinks = 25)
  stones = parse(input)
  cache = {}

  blinks.times do |i|
    stones = blink(stones, cache)
  end

  stones.size
end

def parse(input)
  input.split(' ').map(&:to_i)
end

def blink(stones, cache = {})
  stones.each_with_object([]) do |stone, acc|
    if cache.key?(stone)
      cache[stone].each { |s| acc << s }
    else
      result = convert_stone(stone)
      result.each { |s| acc << s }
      cache[stone] = result
    end
  end
end

def convert_stone(stone)
  if stone == 0
    [1]
  elsif (Math.log10(stone).to_i + 1).even?
    stone_size = Math.log10(stone).to_i + 1
    num = 1
    (stone_size / 2).times { num *= 10 }
    [stone / num, stone % num]
  else
    [stone * 2024]
  end
end

require_relative './assert'

extend SuperDuperAssertions

assert('converts a zero into a one', convert_stone(0), [1])
assert('converts an even number of digits into two stones', convert_stone(10), [1, 0])
assert('does not preserve leading zeroes', convert_stone(2000), [20, 0])
assert('odd numbers of digits get multiplied by 2024', convert_stone(1), [2024])

assert('does a single blink', blink([0, 1, 50]), [1, 2024, 5, 0])
assert('does another blink', blink([1, 2024, 5, 0]), [2024, 20, 24, 10_120, 1])

assert('does 25 blinks and returns the number of stones', stones('125 17'), 55312)

assert('calculates the real result', stones(File.read('./input11.txt')), 207_683)

# rip, this is too slow :(
assert('calculates the result for part 2', stones(File.read('./input11.txt'), 75), 2_076_830)

