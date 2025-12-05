require_relative './assert'

def fresh_ingredients(input)
  ranges, ingredient_ids = parse(input)

  ingredient_ids.reduce(0) do |acc, id|
    is_fresh = ranges.any? { |range| (range[0]..range[1]).include?(id) }
    acc += 1 if is_fresh
    acc
  end
end

def parse(input)
  ranges, ingredient_ids = input.split("\n\n")
  ranges = ranges.split("\n").map { |r| r.split("-").map(&:to_i) }
  ingredient_ids = ingredient_ids.split("\n").map(&:to_i)
  [ranges, ingredient_ids]
end


extend SuperDuperAssertions

small_input = <<~INPUT
3-5
10-14
16-20
12-18

1
5
8
11
17
32
INPUT

assert("works with the small input", fresh_ingredients(small_input), 3)

real_input = File.read('input05.txt')

assert("works with the real input", fresh_ingredients(real_input), 789)
