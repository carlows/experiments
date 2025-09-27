def min_tokens(input)
  inputs = input.split("\n\n")
  inputs.map { |input| min_tokens_for(input) }.compact.sum
end

def min_tokens_for(input)
  claw_machine_data = parse_claw_machine(input)

  button_a_x = claw_machine_data[:button_a_x]
  button_a_y = claw_machine_data[:button_a_y]
  button_b_x = claw_machine_data[:button_b_x]
  button_b_y = claw_machine_data[:button_b_y]
  prize_x = claw_machine_data[:prize_x]
  prize_y = claw_machine_data[:prize_y]

  determinant = button_a_x * button_b_y - button_a_y * button_b_x

  # when the determinan is 0 then there's no solution
  # when the determinant is negative then the solution is on the opposite side
  # and we cannot really unpress buttons

  dx = prize_x * button_b_y - button_b_x * prize_y
  dy = button_a_x * prize_y - button_a_y * prize_x

  x = dx.to_f / determinant
  y = dy.to_f / determinant

  return nil if x % 1 != 0 || y % 1 != 0
  
  # tokens used to get to the prize
  x.to_i * 3 + y.to_i * 1
end

def parse_claw_machine(input)
  button_a, button_b, prize = input.split("\n")
  button_a_x, button_a_y = button_a.scan(/X\+(\d+), Y\+(\d+)/)[0]
  button_b_x, button_b_y = button_b.scan(/X\+(\d+), Y\+(\d+)/)[0]

  prize_x, prize_y = prize.scan(/X=(\d+), Y=(\d+)/)[0]

  {
    button_a_x: button_a_x.to_i,
    button_a_y: button_a_y.to_i,
    button_b_x: button_b_x.to_i,
    button_b_y: button_b_y.to_i,
    prize_x: prize_x.to_i + 10000000000000,
    prize_y: prize_y.to_i + 10000000000000
  }
end


require_relative 'assert'

extend SuperDuperAssertions

single_input = <<~INPUT
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

INPUT

assert("calculates the result of a single input", min_tokens(single_input), 280)

single_input_third_row = <<~INPUT
Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

INPUT

assert("calculates the result for another single input", min_tokens(single_input_third_row), 200)

both_inputs_combined = <<~INPUT
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450
INPUT

assert("calculates the result of both inputs combined", min_tokens(both_inputs_combined), 480)

invalid_result = <<~INPUT
Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176
INPUT

assert("returns zero when input has no valid solution", min_tokens(invalid_result), 0)

input5 = <<~INPUT
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
INPUT

assert("calculates the result of multiple inputs", min_tokens(input5), 480)

real_input = File.read("input13.txt")

assert("calculates the result for the real deal!!!", min_tokens(real_input), 99968222587852)
