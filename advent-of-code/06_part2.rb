def solve_day_06_part_2(input)
  grid = input.split("\n").map { |row| row.split('') }
  position = nil

  (0...grid.size).each do |i|
    (0...grid[0].size).each do |y|
      position = [i, y] if grid[i][y] == '^'
    end
  end
  start_position = position.dup

  infinite_loops = 0

  (0...grid.size).each do |i|
    (0...grid[0].size).each do |y|
      next if start_position == [i, y]
      next if grid[i][y] == '#'

      current_direction = 0
      position = start_position
      path = Set.new(["#{position[0]},#{position[1]},#{position}"])
      visual_path = [[start_position, current_direction, :start]]
      grid[i][y] = '#'

      loop do
        position, current_direction = step(grid, position, current_direction)
        break if position.nil?

        item = "#{position[0]},#{position[1]},#{current_direction}"
        if path.include?(item)
          infinite_loops += 1
          break
        end

        path.add(item)
        visual_path << [position, current_direction, :normal]
      end

      grid[i][y] = '.'
    end
  end
  
  infinite_loops
end

def step(grid, position, current_direction)
  prev_position = position
  new_position = step_forwards(position, current_direction)
  return nil unless within_bounds?(grid, new_position)
  
  while grid[new_position[0]][new_position[1]] == '#'
    current_direction = next_direction(current_direction)
    new_position = step_forwards(prev_position, current_direction)
    return nil unless within_bounds?(grid, new_position)
  end

  [new_position, current_direction]
end

def within_bounds?(grid, pos)
  return false if pos[0] < 0 || pos[0] >= grid.size
  return false if pos[1] < 0 || pos[1] >= grid[0].size
  true
end

def directions
  [
    [-1, 0],
    [0, 1],
    [1, 0],
    [0, -1]
  ]
end

def next_direction(current_direction)
  (current_direction + 1) % directions.size
end

def step_forwards(position, current_direction)
  # move the guard one step in the correct direction
  direction_vector = directions[current_direction]
  [
    position[0] + direction_vector[0], 
    position[1] + direction_vector[1]
  ]
end

require './assert.rb'

extend SuperDuperAssertions

obstacles = <<~TEXT
.#........
#........#
#.........
#^..#.....
.#......#.
TEXT
assert("Gets stuck in a loop forever", solve_day_06_part_2(obstacles), 5)

obstacles = <<~TEXT
.##.......
.........#
..........
.^........
.#......#.
TEXT
assert("We should avoid counting the starting position", solve_day_06_part_2(obstacles), 1)

obstacles = <<~TEXT
.#..
...#
....
.^#.
TEXT
assert("Turns right when it finds an obstacle", solve_day_06_part_2(obstacles), 1)

obstacles = <<~TEXT
.#..
..#.
....
.^..
TEXT
assert("Does a 180 when faced with two walls", solve_day_06_part_2(obstacles), 0)

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

assert("The example from the page should work", solve_day_06_part_2(sample_from_page), 6)

real_input_part_2 = File.read('./input06.txt')
assert("Gives dah answer", solve_day_06_part_2(real_input_part_2), 2151)
