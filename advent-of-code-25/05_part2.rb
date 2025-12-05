require_relative './assert'

def fresh_ingredients(input)
  ranges = parse(input)
  # sort the ranges to make it easier to merge them
  # O(n * log n)
  ranges = ranges.sort { |a, b| a[0] <=> b[0] }
  
  merged_ranges = []
  merged_ranges << ranges.first

  # merge the ranges O(n)
  ranges.each do |range|
    range_start = range[0]
    range_end = range[1]
    last_end = merged_ranges.last[1]

    if range_start <= last_end
      merged_ranges.last[1] = [last_end, range_end].max
    else
      merged_ranges << range
    end
  end

  # finally count the unique ids
  merged_ranges.reduce(0) do |acc, range|
    acc + (range[1] - range[0] + 1)
  end
end

def parse(input)
  input.split("\n").map { |r| r.split("-").map(&:to_i) }
end


extend SuperDuperAssertions

small_input = <<~INPUT
3-5
10-14
16-20
12-18
INPUT

assert("works with the small input", fresh_ingredients(small_input), 14)

real_input = File.read('input05.txt')


require 'benchmark'

puts Benchmark.measure {
  assert("works with the real input", fresh_ingredients(real_input), 343329651880509)
}
