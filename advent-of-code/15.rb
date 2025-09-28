def sum_of_gps_coordinates(input)
  grid, moves = parse(input)
  
  robot = nil
  (0...grid.size).each do |i|
    (0...grid[0].size).each do |y|
      robot = [i, y] if grid[i][y] == '@'
    end
  end

  moves.each do |move|
    dir = move_to_direction(move)
    result = move(robot, dir, grid)
    robot = [robot[0] + dir[0], robot[1] + dir[1]] if result
  end
  print(grid)
    
  sum = 0
  (0...grid.size).each do |i|
    (0...grid[0].size).each do |y|
      next unless grid[i][y] == 'O'
      sum += 100 * i + y
    end
  end

  sum
end

def print(grid)
  grid.each do |row|
    puts row.join('')
  end
end

def move(cell, dir, grid)
  # if wall, do nothing
  return nil if grid[cell[0]][cell[1]] == '#'
  return true if grid[cell[0]][cell[1]] == '.'
  # if box, recursion
  result = move([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) if grid[cell[0]][cell[1]] == 'O' || grid[cell[0]][cell[1]] == '@'
  return unless result

  # else move stuff
  next_cell = [cell[0] + dir[0], cell[1] + dir[1]]

  tmp = grid[cell[0]][cell[1]]
  grid[cell[0]][cell[1]] = grid[next_cell[0]][next_cell[1]]
  grid[next_cell[0]][next_cell[1]] = tmp

  true
end

def parse(input)
  grid, moves = input.split("\n\n")
  grid = grid.split("\n").map { |row| row.chars }
  moves = moves.split("\n").join('').chars
  [grid, moves]
end

def move_to_direction(move)
  case move
  when '^'
    [-1, 0]
  when 'v'
    [1, 0]
  when '>'
    [0, 1]
  when '<'
    [0, -1]
  end
end

require_relative 'assert'

extend SuperDuperAssertions

input = <<~INPUT
########
#@..OO.#
########

>><>><<>>>>
INPUT

assert("when it moves to the wall it does nothing", sum_of_gps_coordinates(input), 211)

input2 = <<~INPUT
########
#@..OO.#
#......#
#......#
#O.....#
#......#
########

vvvv>
INPUT

assert("when it moves to the wall it does nothing", sum_of_gps_coordinates(input2), 710)

input2 = <<~INPUT
########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<
INPUT

assert("calculates with the simple input", sum_of_gps_coordinates(input2), 2028)

real_input = File.read('input15.txt')

assert("calculates with the real input", sum_of_gps_coordinates(real_input), 1526018)
