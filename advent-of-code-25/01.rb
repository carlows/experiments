require './assert'

def crack_password(input)
  current = 50
  data = parse(input)
  count = 0
  max = 100

  data.each do |dir, distance|
    if dir == 'L'
      current = (current - distance) % max
    else
      current = (current + distance) % max
    end
    count += 1 if current == 0
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

assert('works with the test example', crack_password(test_input), 3)

real_input = File.read('input01.txt')
assert('works with the real example', crack_password(real_input), 1105)
