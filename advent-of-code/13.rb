def min_tokens(input)
  inputs = input.split("\n\n")
  inputs.map { |input| min_tokens_for(input) }.compact.sum
end

def min_tokens_for(input)
  claw_machine_data = parse_claw_machine(input)
  
  # we're trying to find the minimum number of steps to get to the prize
  min_tokens = Float::INFINITY

  button_a_x = claw_machine_data[:button_a_x]
  button_a_y = claw_machine_data[:button_a_y]
  button_b_x = claw_machine_data[:button_b_x]
  button_b_y = claw_machine_data[:button_b_y]
  prize_x = claw_machine_data[:prize_x]
  prize_y = claw_machine_data[:prize_y]

  (0...100).each do |a|
    (0...100).each do |b|
      next if (a * button_a_x) + (b * button_b_x) != prize_x || (a * button_a_y) + (b * button_b_y) != prize_y

      min_tokens = (a * 3) + (b * 1)
      break
    end
  end

  min_tokens == Float::INFINITY ? nil : min_tokens
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
    prize_x: prize_x.to_i,
    prize_y: prize_y.to_i,
  }
end


require_relative 'assert'

extend SuperDuperAssertions

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

assert("calculates the result for the real deal!!!", min_tokens(real_input), 29_187)
