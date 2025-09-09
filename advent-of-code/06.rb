def solve_day_06_part_1(input)
  grid = input.split("\n").map { |row| row.split('') }
  next_pos = nil

  (0...grid.size).each do |i|
    (0...grid[0].size).each do |y|
      next_pos = [i, y] if grid[i][y] == '^'
    end
  end
  
  # store in a set to avoid checking for duplicates
  travel_path = Set.new
  travel_path.add("#{next_pos[0]}.#{next_pos[1]}")

  current_direction = 0
  directions = [
    [-1, 0],
    [0, 1],
    [1, 0],
    [0, -1]
  ]

  loop do
    position = step_forwards(directions, next_pos, current_direction)
    break unless within_bounds?(grid, position)

    if grid[position[0]][position[1]] == '#'
      current_direction = (current_direction + 1) % directions.size
      position = step_forwards(directions, next_pos, current_direction)
    end

    # save the new position in our travel_path
    travel_path.add("#{position[0]}.#{position[1]}")
    next_pos = position
  end

  travel_path.size
end

def within_bounds?(grid, pos)
  return false if pos[0] < 0 || pos[0] >= grid.size
  return false if pos[1] < 0 || pos[1] >= grid[0].size
  true
end

def step_forwards(directions, position, current_direction)
  # move the guard one step in the correct direction
  direction_vector = directions[current_direction]
  [
    position[0] + direction_vector[0], 
    position[1] + direction_vector[1]
  ]
end

require './assert.rb'

extend SuperDuperAssertions

small_grid = <<~TEXT
....
....
.^..
....
TEXT
assert("Moves in one direction until its out of bounds", solve_day_06_part_1(small_grid), 3)

obstacles = <<~TEXT
.#..
...#
....
.^..
TEXT
assert("Turns right when it finds an obstacle", solve_day_06_part_1(obstacles), 6)

sample_from_page = <<~TEXT
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
TEXT

assert("The example from the page should work", solve_day_06_part_1(sample_from_page), 41)

real_input_part_1 = File.read('./input06.txt')
assert("Gives dah answer", solve_day_06_part_1(real_input_part_1), 5080)
