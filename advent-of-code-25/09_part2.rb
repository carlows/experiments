def part_two(input)
  points = parse(input)

  pairs = points.combination(2).map do |p1, p2|
    lx = [p1.x, p2.x].min
    ly = [p1.y, p2.y].max 
    rx = [p1.x, p2.x].max 
    ry = [p1.y, p2.y].min 

    { 
      a: p1,
      b: p2,
      l: Point.new(lx, ly),
      r: Point.new(rx, ry),
      area: ((p1.x - p2.x).abs + 1) * ((p1.y - p2.y).abs + 1)
    }
  end
  pairs = pairs.sort { |a, b| b[:area] <=> a[:area] }

  edges = points.each_with_index.map do |p, i|
    next_point = (i + 1) % points.size

    p2 = points[next_point]

    lx = [p.x, p2.x].min
    ly = [p.y, p2.y].max 
    rx = [p.x, p2.x].max 
    ry = [p.y, p2.y].min 

    [Point.new(lx, ly), Point.new(rx, ry)]
  end

  pairs.each do |pair|
    overlap = edges.any? do |edge|
      l1, r1 = pair[:l], pair[:r]
      l2, r2 = edge

      next false if l2.x >= r1.x || l1.x >= r2.x
      next false if l2.y <= r1.y || l1.y <= r2.y

      true
    end

    return pair[:area] if !overlap
  end
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

assert('works with the test input', part_two(input), 24)

real_input = File.read('input09.txt')

require 'benchmark'

puts Benchmark.measure {
  assert('works with the real input', part_two(real_input), 1539238860)
}
