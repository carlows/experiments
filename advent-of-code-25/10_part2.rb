
def solve_part_two(input)
  machines = parse(input)
  idx = 1
  machines.reduce(0) do |acc, machine|
    puts "processing machine #{idx}"
    idx += 1
    acc + solve_machine(machine)
  end
end

def parse(input)
  lines = input.split("\n")
  lines.map do |line|
    parts = line.match(/\[(.+)\] (\(.+\))+ {(.+)}/)
    goal = parts[3].split(',').map(&:to_i)
    buttons = parts[2].split(' ').map { |b| b.tr('()', '') }
    buttons = buttons.map { |b| b.split(',').map(&:to_i) }
    buttons = buttons.map do |b|
      output = Array.new(parts[1].size) { 0 }
      b.each do |i|
        output[i] = 1
      end
      output
    end
    [goal, buttons]
  end
end

def solve_machine(input)
  goal, buttons = input

  next_states = []
  # presses, state
  next_states << [0, Array.new(goal.size, 0)]

  while next_states.any?
    current_presses, current_state = next_states.shift

    buttons.each do |button|
      next_state = current_state.zip(button).map { |a, b| a + b }

      if next_state == goal
        return current_presses + 1
      end
      
      # if we surpassed the goal then stop
      next if next_state.zip(goal).any? { |a, b| a > b }
      next_states << [current_presses + 1, next_state]
    end
  end
end

require_relative './assert'

extend SuperDuperAssertions

input = <<~INPUT
[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
INPUT

assert("works with the sample input", solve_part_two(input), 33)

real_input = File.read('input10.txt')
assert('works with the real input', solve_part_two(real_input), 441)
