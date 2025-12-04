require_relative './assert'

def remove_rolls(input)
  grid = parse(input)
  removed_rolls = 0

  loop do
    accessible_rolls = 0

    (0...grid.size).each do |row|
      (0...grid[row].size).each do |col|
        next if grid[row][col] == '.'

        neighbour_count = valid_neighbours(grid, row, col)
        if neighbour_count < 4
          accessible_rolls += 1
          grid[row][col] = '.'
        end
      end
    end

    removed_rolls += accessible_rolls

    break if accessible_rolls == 0
  end

  removed_rolls
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

assert('works with the sample input', remove_rolls(input), 43)

real_input = File.read('input04.txt')

assert('works with the real input', remove_rolls(real_input), 8538)
