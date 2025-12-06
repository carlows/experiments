def solve_cephalopod_problems(input)
  grid, operators = parse(input)

  total = 0
  current_numbers = []
  current_operator = operators.shift

  (0...grid[0].size).each do |i|
    num = ""

    (0...grid.size).each do |y|
      num += grid[y][i]
    end

    if num.to_i == 0
      total += partial_total(current_numbers, current_operator)
      current_numbers = []
      current_operator = operators.shift
    else
      current_numbers << num.to_i
    end
  end
  
  # process the last rows
  total += partial_total(current_numbers, current_operator)
  total
end

def partial_total(current_numbers, current_operator)
  current_numbers.reduce(current_operator == '*' ? 1 : 0) do |result, num|
    result.send(current_operator, num)
  end
end

def parse(input)
  grid = input.split("\n").map do |line|
    line.split('')
  end

  operators = grid[-1].reject { |char| char == ' ' }

  [grid[0...-1], operators]
end

require_relative './assert'

extend SuperDuperAssertions

sample_input = <<~SAMPLE
123 328  51 64 
 45 64  387 23 
  6 98  215 314
*   +   *   + 
SAMPLE

assert("works with the sample input", solve_cephalopod_problems(sample_input), 3263827)

real_input = File.read('input06.txt')

assert("works with the real input", solve_cephalopod_problems(real_input), 10227753257799)
