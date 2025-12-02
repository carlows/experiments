require_relative './assert'

def invalid_ids(input)
  ranges = parse(input)

  ranges.reduce(0) do |sum, range|
    range_sum = range.filter do |i|
      num = i.to_s
      half_of_num = num[0...num.size / 2]
      num.size.even? && num.match?(/(#{half_of_num}){2}/)
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

assert('works with simple double digit ranges', invalid_ids("11-22,95-115"), 132)

assert('works with the sample input', invalid_ids("11-22,95-115,998-1012,1188511880-1188511890,222220-222224,1698522-1698528,446443-446449,38593856-38593862,565653-565659,824824821-824824827,2121212118-2121212124"), 1227775554)

real_input = File.read('input02.txt')

assert('works with the real deal', invalid_ids(real_input), 15873079081)
