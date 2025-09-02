list1 = []
list2 = []

File.readlines('./input01.txt').each do |line|
  split = line.split(' ')
  raise StandardError.new("We're not supposed to see more than 1 pair of numbers here... #{line}") if split.size > 2

  list1 << split[0].strip.to_i
  list2 << split[1].strip.to_i
end

def similarity_score(list1, list2)
  occurrences_of_numbers = list2.tally
  list1.reduce(0) do |acc, num|
    next acc if occurrences_of_numbers[num].nil?
    acc += num * occurrences_of_numbers[num]
  end
end

require_relative './assert.rb'
extend SuperDuperAssertions

assert("Returns a number", similarity_score([1], [1]), 1)
assert("Multiplies number by occurrences", similarity_score([2, 2], [2, 2]), 8)
assert("Ignores numbers with no occurrences", similarity_score([2, 2], [0, 0]), 0)
assert("Gives me dah result!", similarity_score(list1, list2), 18567089)
