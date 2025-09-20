def total_trailhead_score(input)
  grid = parse(input)

  score = 0

  (0...grid.size).map do |i|
    (0...grid[0].size).map do |j|
      next unless grid[i][j] == 0
      
      uniq_ends = Set.new
      score_for_trailhead(grid, [i, j], uniq_ends)
      score += uniq_ends.size
    end
  end

  score
end

def parse(input)
  input.split("\n").map(&:chars).map { |row| row.map(&:to_i) }
end

def score_for_trailhead(grid, position, uniq_ends)
  if grid[position[0]][position[1]] == 9
    uniq_ends.add("#{position[0]},#{position[1]}")
    return
  end

  directions = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ]

  directions.each do |direction|
    next_position = [position[0] + direction[0], position[1] + direction[1]]
    next unless valid_next_position?(grid, position, next_position)

    score_for_trailhead(grid, next_position, uniq_ends)
  end
end

def valid_next_position?(grid, position, next_position)
  return false if out_of_bounds?(grid, next_position)
  return false if grid[next_position[0]][next_position[1]] != grid[position[0]][position[1]] + 1

  true
end

def out_of_bounds?(grid, position)
  position[0] < 0 || position[0] >= grid.size || 
    position[1] < 0 || position[1] >= grid[0].size
end

require_relative './assert'

extend SuperDuperAssertions

input1 = <<~INPUT
0123
2274
2215
9876
INPUT

assert("calculates the trailhead score for a single hiking trail", total_trailhead_score(input1), 1)

input2 = <<~INPUT
0123
2274
2015
9876
INPUT
assert("an unconnected trail leads nowhere and does not count", total_trailhead_score(input2), 1)


input3 = <<~INPUT
0123
2074
2215
9876
INPUT

assert("two different trailheads that are conencted to a valid path count in the result", total_trailhead_score(input3), 2)


input4 = <<~INPUT
0123
2534
2215
9876
INPUT

assert("when the same trailhead finds the same end via two different paths, it counts as one", total_trailhead_score(input4), 1)

input5 = <<~INPUT
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
INPUT

assert("calculates the larger example from the page", total_trailhead_score(input5), 36)

assert("calculates the real result", total_trailhead_score(File.read('./input10.txt')), 574)
