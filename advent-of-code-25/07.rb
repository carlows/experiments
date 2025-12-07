require_relative './assert'

def solve_tachyon_manifolds(input)
  grid = parse(input)
  tachyons = Set.new
  splits = 0

  # find start point
  start_col = grid[0].find_index { |c| c == 'S' }
  tachyons << "0,#{start_col}"

  (0...grid.size).each do |i|
    iterations = tachyons.size
    iterations.times do
      tachyon = tachyons.first

      i, y = tachyon.split(',').map(&:to_i)

      next_position_i = i + 1

      # boundaries of the grid vertically
      # do nothing :)
      next if next_position_i >= grid.size

      if grid[next_position_i][y] == '.'
        tachyons << "#{next_position_i},#{y}"
      end

      if grid[next_position_i][y] == '^'
        tachyons << "#{next_position_i},#{y - 1}" if y - 1 >= 0
        tachyons << "#{next_position_i},#{y + 1}" if y + 1 < grid[0].size
        splits += 1
      end

      # after processing we delete it from its previous position
      tachyons.delete(tachyon)
    end

    # print_grid(grid, tachyons)
  end

  splits
end

def parse(input)
  input.split("\n").map(&:chars)
end

require_relative './colorize'

def print_grid(grid, tachyons)
  puts `clear`
  grid.each_with_index do |row, i|
    row.each_with_index do |cell, j|
      if tachyons.include?("#{i},#{j}")
        print('|'.yellow)
      elsif grid[i][j] == '^'
        print('|'.green)
      else
        print(cell)
      end
    end
    puts
  end
  sleep 0.1
end

extend SuperDuperAssertions

test_input = <<~INPUT
.......S.......
...............
.......^.......
...............
......^.^......
...............
.....^.^.^.....
...............
....^.^...^....
...............
...^.^...^.^...
...............
..^...^.....^..
...............
.^.^.^.^.^...^.
...............
INPUT

assert("works with the test input", solve_tachyon_manifolds(test_input), 21)

real_input = File.read('input07.txt')

assert("works with the real input", solve_tachyon_manifolds(real_input), 1658)
