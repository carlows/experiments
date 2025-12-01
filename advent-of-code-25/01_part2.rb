require './assert'

def crack_password(input)
  current = 50
  data = parse(input)
  count = 0
  max = 100

  data.each do |dir, distance|
    # Instead of implementing all of the discrete cases, just brute force.
    # The input is small enough that this is fine.
    operator = dir == 'L' ? :- : :+
    distance.times { current = (current.send(operator, 1)) % max; count += 1 if current == 0 }
  end

  count
end

def parse(input)
  lines = input.split("\n")
  lines.map do |line|
    matches = line.match(/(L|R)(\d+)/)
    [matches[1], matches[2].to_i]
  end
end

extend SuperDuperAssertions

test_input = <<~INPUT
  L68
  L30
  R48
  L5
  R60
  L55
  L1
  L99
  R14
  L82
INPUT

assert('works with the test example', crack_password(test_input), 6)

assert('works with bigger numbers', crack_password('L300'), 3)

real_input = File.read('input01.txt')
assert('works with the real example', crack_password(real_input), 6599)

