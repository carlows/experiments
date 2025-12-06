def solve_math_problems(input)
  problem_grid = parse(input)
  total_result = 0

  (0...problem_grid[0].size).each do |i|
    operator = problem_grid[-1][i]
    problem_result = operator == '*' ? 1 : 0

    (0...problem_grid.size - 1).each do |y|
      problem_result = problem_result.send(operator, problem_grid[y][i].to_i)
    end

    total_result += problem_result
  end

  total_result
end

def parse(input)
  input.split("\n").map do |line|
    line.split(" ")
  end
end

require_relative './assert'

extend SuperDuperAssertions

sample_input = <<~SAMPLE
123 328  51 64  1 1
 45 64  387 23  1 1
  6 98  215 314 1 1
*   +   *   +   + +
SAMPLE

assert("works with the sample input", solve_math_problems(sample_input), 4277562)

real_input = File.read('input06.txt')

assert("works with the real input", solve_math_problems(real_input), 5227286044585)
