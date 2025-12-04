require_relative './assert'

def available_rolls(input)
  grid = parse(input)

  accessible_rolls = 0

  (0...grid.size).each do |row|
    (0...grid[row].size).each do |col|
      next if grid[row][col] == '.'

      neighbour_count = valid_neighbours(grid, row, col)
      accessible_rolls += 1 if neighbour_count < 4
    end
  end

  accessible_rolls
end

def parse(input)
  input.split("\n").map do |line|
    line.split('')
  end
end

def valid_neighbours(grid, row, col)
  directions = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ]

  directions.reduce(0) do |acc, direction|
    x_row = row + direction[0]
    y_col = col + direction[1]

    if x_row < 0 || y_col < 0 || x_row >= grid.size || y_col >= grid[row].size
      next acc
    end

    acc += 1 if grid[x_row][y_col] == '@'
    acc
  end
end

extend SuperDuperAssertions

input = <<~INPUT
..@@.@@@@.
@@@.@.@.@@
@@@@@.@.@@
@.@@@@..@.
@@.@@@@.@@
.@@@@@@@.@
.@.@.@.@@@
@.@@@.@@@@
.@@@@@@@@.
@.@.@@@.@.
INPUT

assert('works with the sample input', available_rolls(input), 13)

real_input = File.read('input04.txt')

assert('works with the real input', available_rolls(real_input), 1508)
