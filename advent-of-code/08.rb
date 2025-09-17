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
        
        antinode_i = second_position[0] + diff_i
        antinode_y = second_position[1] + diff_y
        valid_locations << [antinode_i, antinode_y] if within_bounds?(matrix, antinode_i, antinode_y)
      end
    end
  end

  valid_locations.uniq.size
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

assert("finds the antinodes for two antennas", find_antinode_locations(sample1), 2)

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

assert("when an antinode is out of bounds", find_antinode_locations(sample3), 1)

sample4 = <<~TEXT
.
.
a
.
a
.
TEXT

assert("when an antinode is out of bounds vertically", find_antinode_locations(sample4), 1)

sample4 = <<~TEXT
..aaa..
TEXT

assert("when an antinode overlaps an antenna", find_antinode_locations(sample4), 6)

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

assert("calculates the sample from the page", find_antinode_locations(sample_from_page), 14)

assert("calculates the result for the real input", find_antinode_locations(File.read('./input08.txt')), 426)
