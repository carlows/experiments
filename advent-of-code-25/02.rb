require_relative './assert'
require 'benchmark'

def invalid_ids(input)
  ranges = parse(input)

  ranges.reduce(0) do |sum, range|
    range_sum = range.filter do |i|
      num = i.to_s
      
      (1..num.size / 2).any? do |y|
        num.size % y == 0 && num[...y] * (num.size / y) == num
      end
    end.flatten.sum
    sum += range_sum
  end
end

def parse(input)
  ranges = input.split(',').map(&:strip)
  ranges.map do |range|
    start, ending = range.split('-').map(&:to_i)
    (start..ending)  
  end
end

extend SuperDuperAssertions

assert('works with simple double digit ranges', invalid_ids("11-22,95-115"), 243)

assert('works with the sample input', invalid_ids("11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"), 4174379265)

real_input = File.read('input02.txt')

puts Benchmark.measure {
  assert('works with the real deal', invalid_ids(real_input), 22617871034)
}
