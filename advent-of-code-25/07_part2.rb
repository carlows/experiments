require_relative './assert'

def calculate_timelines(input)
  grid = parse(input)

  # find start point
  start_col = grid[0].find_index { |c| c == 'S' }
  total = dfs(grid, 0, start_col)
  puts "total timelines: #{total}"

  total
end

def dfs(grid, i, y, cache = {})
  return 1 if i >= grid.size
  return cache["#{i},#{y}"] if cache.key?("#{i},#{y}")

  if grid[i][y] == '.' || grid[i][y] == 'S'
    cache["#{i},#{y}"] = dfs(grid, i + 1, y, cache)
  elsif grid[i][y] == '^'
    cache["#{i},#{y}"] = dfs(grid, i + 1, y - 1, cache) + dfs(grid, i + 1, y + 1, cache)
  end

  cache["#{i},#{y}"]
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

assert('works with the test input', calculate_timelines(test_input), 40)

require 'benchmark'

real_input = File.read('input07.txt')

puts Benchmark.measure {
  assert('works with the real input', calculate_timelines(real_input), 53916299384254)
}
