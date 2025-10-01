require_relative 'colorizer'

def sum_of_gps_coordinates(input)
  grid, moves = parse(input)
  grid = double_grid(grid)

  robot = nil
  grid.each_with_index do |row, i|
    row.each_with_index do |cell, y|
      robot = [i, y] if cell == '@'
    end
  end

  moves.each_with_index do |move, idx|
    dir = next_direction(move)
    result = if %[<>].include?(move)
               # horizontal moves are pretty easy
               # as they happen always in a single row
               move_horizontally(robot, dir, grid)
             else
               # vertical moves have more complex issues
               # as boxes might not be aligned vertically
               # an an important edge case is that there could be an obstacle
               # at any point of the chain, not only at the end of the chain
               can_move = can_move_vertically?(robot, dir, grid)
               move_vertically(robot, dir, grid) if can_move
               can_move
             end
    robot = [robot[0] + dir[0], robot[1] + dir[1]] if result
  end

  sum = 0
  grid.each_with_index do |row, i|
    row.each_with_index do |cell, y|
      next unless cell == '['
      sum += 100 * i + y
    end
  end

  sum
end

def double_grid(grid)
  new_grid = []

  grid.each do |row|
    new_row = []

    row.each do |cell|
      if cell == '#'
        new_row << ['#', '#']
      elsif cell == '@'
        new_row << ['@', '.']
      elsif cell == '.'
        new_row << ['.', '.']
      else
        new_row << ['[', ']']
      end
    end

    new_grid << new_row.flatten
  end

  new_grid
end

def move_horizontally(cell, dir, grid)
  return nil if grid[cell[0]][cell[1]] == '#'
  return true if grid[cell[0]][cell[1]] == '.'
  result = false

  # when moving left or right we simply move all boxes across a line
  result = move_horizontally([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) 
  move_cell(cell, dir, grid) if result
end

def can_move_vertically?(cell, dir, grid)
  # if wall, do nothing
  return nil if grid[cell[0]][cell[1]] == '#'
  return true if grid[cell[0]][cell[1]] == '.'
  result = false

  if robot?(grid, cell)
    result = can_move_vertically?([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) 
  end

  if left_box?(grid, cell)
    result = can_move_vertically?([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) &&
               can_move_vertically?([cell[0] + dir[0], cell[1] + 1 + dir[1]], dir, grid)
  end

  if right_box?(grid, cell)
    result = can_move_vertically?([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) &&
               can_move_vertically?([cell[0] + dir[0], cell[1] - 1 + dir[1]], dir, grid)
  end

  result
end

def move_vertically(cell, dir, grid)
  # if wall, do nothing
  return nil if grid[cell[0]][cell[1]] == '#'
  return true if grid[cell[0]][cell[1]] == '.'
  result = false

  if robot?(grid, cell)
    result = move_vertically([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) 
    move_cell(cell, dir, grid) if result
  end

  if left_box?(grid, cell)
    result = move_vertically([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) &&
              move_vertically([cell[0] + dir[0], cell[1] + 1 + dir[1]], dir, grid)
    if result
      move_cell(cell, dir, grid)
      move_cell([cell[0], cell[1] + 1], dir, grid)
      return result
    end
  end

  if right_box?(grid, cell)
    result = move_vertically([cell[0] + dir[0], cell[1] + dir[1]], dir, grid) &&
      move_vertically([cell[0] + dir[0], cell[1] - 1 + dir[1]], dir, grid)
    if result
      move_cell(cell, dir, grid)
      move_cell([cell[0], cell[1] - 1], dir, grid)
      return result
    end
  end

  result
end

def move_cell(cell, dir, grid)
  next_cell = [cell[0] + dir[0], cell[1] + dir[1]]

  tmp = grid[cell[0]][cell[1]]
  grid[cell[0]][cell[1]] = grid[next_cell[0]][next_cell[1]]
  grid[next_cell[0]][next_cell[1]] = tmp
end

def left_box?(grid, cell)
  grid[cell[0]][cell[1]] == '['
end

def right_box?(grid, cell)
  grid[cell[0]][cell[1]] == ']'
end

def box?(grid, cell)
  left_box?(grid, cell) || right_box?(grid, cell)
end

def robot?(grid, cell)
  grid[cell[0]][cell[1]] == '@'
end

def parse(input)
  grid, moves = input.split("\n\n")
  grid = grid.split("\n").map { |row| row.chars }
  moves = moves.split("\n").join('').chars
  [grid, moves]
end

def next_direction(move)
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

horizontal = <<~INPUT
#########
#.@.OO..#
#########

>>>>>>>>>
INPUT

assert("moves boxes right horizontally", sum_of_gps_coordinates(horizontal), 226)

horizontal = <<~INPUT
#########
#..OO..@#
#########

<<<<<<<<<<
INPUT

assert("moves boxes left horizontally", sum_of_gps_coordinates(horizontal), 206)

vertical_1 = <<~INPUT
#########
#.......#
#....O..#
#....@..#
#########

>^
INPUT

assert("moves simple boxes vertically upwards", sum_of_gps_coordinates(vertical_1), 110)

vertical_2 = <<~INPUT
#########
#....@..#
#....O..#
#.......#
#########

>v
INPUT

assert("moves simple boxes vertically downwards", sum_of_gps_coordinates(vertical_2), 310)

vertical_3 = <<~INPUT
#########
#....@..#
#....O..#
#....O..#
#.......#
#.......#
#########

>vvv
INPUT

assert("moves connected boxes 1", sum_of_gps_coordinates(vertical_3), 920)

vertical_4 = <<~INPUT
#########
#.......#
#...@O..#
#....OO.#
#.......#
#.......#
#########

>>^>>vv
INPUT

assert("moves connected boxes 1", sum_of_gps_coordinates(vertical_4), 1433)

vertical_5 = <<~INPUT
##########
#........#
#.@O.....#
#..#O....#
#...O....#
#....#...#
#........#
##########

>>^>>v
INPUT

assert("moves a pyramid of boxes", sum_of_gps_coordinates(vertical_5), 923)

larger_example = <<~INPUT
##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^
INPUT

assert("calculates with the larger example", sum_of_gps_coordinates(larger_example), 9021)

real_input = File.read('input15.txt')

assert("calculates with the real input", sum_of_gps_coordinates(real_input), 1550677)
