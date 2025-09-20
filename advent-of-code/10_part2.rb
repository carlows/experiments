def total_trailhead_score(input)
  grid = parse(input)

  score = 0

  (0...grid.size).map do |i|
    (0...grid[0].size).map do |j|
      next unless grid[i][j] == 0
      
      all_ends = []
      score_for_trailhead(grid, [i, j], all_ends)
      score += all_ends.size
    end
  end

  score
end

def parse(input)
  input.split("\n").map(&:chars).map { |row| row.map(&:to_i) }
end

def score_for_trailhead(grid, position, all_ends)
  if grid[position[0]][position[1]] == 9
    all_ends << position
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

    score_for_trailhead(grid, next_position, all_ends)
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

assert("calculates the larger example from the page", total_trailhead_score(input5), 81)

assert("calculates the real result", total_trailhead_score(File.read('./input10.txt')), 1238)
