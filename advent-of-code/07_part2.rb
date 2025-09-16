def total_calibration_result(input)
  equations = parse(input)

  valid_equations = equations.filter do |eq|
    valid_equation?(eq[0], eq[1])
  end

  valid_equations.reduce(0) do |acc, eq|
    acc + eq.first
  end
end

def parse(input)
  lines = input.split("\n")
  lines.map do |l|
    total, operands = l.split(':')
    operands = operands.strip.split(' ').map(&:to_i)
    [total.to_i, operands]
  end
end

def valid_equation?(target, nums, sum = nil)
  return true if sum && sum == target
  return false if sum && sum > target
  return false if nums.size == 0

  next_num = nums.first

  valid_equation?(target, nums[1..], (sum || 0) + next_num) || 
    valid_equation?(target, nums[1..], (sum || 1) * next_num) ||
    valid_equation?(target, nums[1..], (sum.to_s + next_num.to_s).to_i)
end

require_relative './assert.rb'

extend SuperDuperAssertions

assert("Concatenates some numbers", total_calibration_result("156: 15 6"), 156)
assert("Works with the simple example", total_calibration_result("190: 10 19"), 190)
assert("Equation is not included in the result", total_calibration_result("7290: 6 8 6 15"), 7290)

sample_from_page = <<~TEXT
  190: 10 19
  3267: 81 40 27
  83: 17 5
  156: 15 6
  7290: 6 8 6 15
  161011: 16 10 13
  192: 17 8 14
  21037: 9 7 18 13
  292: 11 6 16 20
TEXT

assert("Works with the example from the page", total_calibration_result(sample_from_page), 11387)

assert("Works with the real deal!", total_calibration_result(File.read('./input07.txt')), 637696070419031)
