def find_antinode_locations(input)
  matrix = parse(input)

  antenna_locations = Hash.new { |k, v| k[v] = [] }

  (0...matrix.size).each do |i|
    (0...matrix[0].size).each do |y|
      cell = matrix[i][y]
      antenna_locations[cell] << [i, y] if cell != '.'
    end
  end

  valid_locations = []
  antenna_locations.each do |_frequency, positions|
    positions.each do |first_position|
      positions.each do |second_position|
        next if first_position == second_position

        diff_i = second_position[0] - first_position[0]
        diff_y = second_position[1] - first_position[1]
        
        antinodes = [first_position, second_position]
        antinodes = antinodes.concat(find_antinodes(matrix, diff_i, diff_y, second_position))
        valid_locations.concat(antinodes)
      end
    end
  end

  valid_locations.uniq.size
end

def find_antinodes(matrix, diff_i, diff_y, position)
  next_antinode_i = position[0] + diff_i
  next_antinode_y = position[1] + diff_y
  antinodes = []

  while within_bounds?(matrix, next_antinode_i, next_antinode_y)
    antinodes << [next_antinode_i, next_antinode_y]
    next_antinode_i += diff_i
    next_antinode_y += diff_y
  end

  antinodes
end

def parse(input)
  rows = input.split("\n")
  rows.map { |r| r.split('') }
end

def within_bounds?(matrix, i, y)
  return false if i < 0 || i >= matrix.size
  return false if y < 0 || y >= matrix[0].size
  true
end

require_relative './assert'

extend SuperDuperAssertions

sample1 = <<~TEXT
..........
..........
..........
....a.....
..........
.....a....
..........
..........
..........
..........
TEXT

assert("finds the antinodes for two antennas", find_antinode_locations(sample1), 5)

sample2 = <<~TEXT
..........
..........
..........
....ao....
..........
..........
..........
TEXT

assert("when there are only nodes with different freqs", find_antinode_locations(sample2), 0)

sample3 = <<~TEXT
..a.a.
TEXT

assert("when an antinode is out of bounds", find_antinode_locations(sample3), 3)

sample4 = <<~TEXT
.
.
a
.
a
.
TEXT

assert("when an antinode is out of bounds vertically", find_antinode_locations(sample4), 3)

sample4 = <<~TEXT
..a.a........
TEXT

assert("when an antinode overlaps an antenna", find_antinode_locations(sample4), 7)

sample_from_page = <<~TEXT
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
TEXT

assert("calculates the sample from the page", find_antinode_locations(sample_from_page), 34)

assert("calculates the result for the real input", find_antinode_locations(File.read('./input08.txt')), 1359)
