def part_two(input)
  points = parse(input)
  distances = points.combination(2).map { |a, b| [a, b, distance(a, b)] }
  distances = distances.sort { |a, b| a[2] <=> b[2] }
  
  position = 0
  map_of_points = points.reduce({}) do |acc, point|
    acc[point.to_s] = position
    position += 1
    acc
  end

  result = 0

  distances.each do |distance|
    position_a = map_of_points[distance[0].to_s]
    position_b = map_of_points[distance[1].to_s]
    next if position_a == position_b
  
    map_of_points.each do |point, position|
      if position == position_b
        map_of_points[point] = position_a
      end
    end

    remaining = map_of_points.group_by { |k, v| v }.map { |k, v| v.size }

    if remaining.size == 1
      result = distance[0].x * distance[1].x
      break
    end
  end

  result
end

Point = Struct.new(:x, :y, :z) do
  def to_s
    "(#{x},#{y},#{z})"
  end
end

def parse(input)
  input.split("\n").map do |row| 
    coords = row.split(',').map(&:to_i)
    Point.new(coords[0], coords[1], coords[2])
  end
end

def distance(a, b)
  Math.sqrt((a.x - b.x)**2 + (a.y - b.y)**2 + (a.z - b.z)**2)
end

require_relative './assert'

extend SuperDuperAssertions

input = <<~INPUT
162,817,812
57,618,57
906,360,560
592,479,940
352,342,300
466,668,158
542,29,236
431,825,988
739,650,466
52,470,668
216,146,977
819,987,18
117,168,530
805,96,715
346,949,466
970,615,88
941,993,340
862,61,35
984,92,344
425,690,689
INPUT

assert('calculates all the distances', part_two(input), 25272)

real_input = File.read('input08.txt')

assert('calculates all the distances for the real input', part_two(real_input), 51294528)
