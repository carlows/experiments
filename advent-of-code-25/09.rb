def part_one(input)
  points = parse(input)

  points.combination(2).map do |p1, p2|
    ((p1.x - p2.x).abs + 1) * ((p1.y - p2.y).abs + 1)
  end.max
end

Point = Struct.new(:x, :y)

def parse(input)
  input.split("\n").map do |line|
    Point.new(*line.split(',').map(&:to_i))
  end
end

require_relative './assert'

extend SuperDuperAssertions

input = <<~INPUT
7,1
11,1
11,7
9,7
9,5
2,5
2,3
7,3
INPUT

assert('works with the test input', part_one(input), 50)

real_input = File.read('input09.txt')

assert('works with the real input', part_one(real_input), 4759531084)
