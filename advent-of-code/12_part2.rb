def total_fence_price(input)
  grid = parse(input)
  
  calculate_total_cost(grid)
end

def parse(input)
  input.split("\n").map(&:chars)
end

def sides_for(visited_region, grid)
  sides_for_region = 0

  visited_region.each do |(i, j)|
    # search horizontally
    has_top_fence = has_top_fence?(grid, i, j)
    has_bottom_fence = has_bottom_fence?(grid, i, j)

    horizontal_prev_out_of_bounds = !within_bounds?(grid, i, j - 1)

    previous_has_top_fence = has_top_fence?(grid, i, j - 1)
    previous_has_bottom_fence = has_bottom_fence?(grid, i, j - 1)

    horizontal_prev_same_region = !horizontal_prev_out_of_bounds && grid[i][j - 1] == grid[i][j]

    sides_for_region += 1 if has_top_fence && horizontal_prev_out_of_bounds
    sides_for_region += 1 if has_bottom_fence && horizontal_prev_out_of_bounds
    sides_for_region += 1 if has_top_fence && !horizontal_prev_out_of_bounds && !horizontal_prev_same_region
    sides_for_region += 1 if has_bottom_fence && !horizontal_prev_out_of_bounds && !horizontal_prev_same_region
    sides_for_region += 1 if has_top_fence && !horizontal_prev_out_of_bounds && !previous_has_top_fence && horizontal_prev_same_region
    sides_for_region += 1 if has_bottom_fence && !horizontal_prev_out_of_bounds && !previous_has_bottom_fence && horizontal_prev_same_region

    # search vertically
    has_left_fence = has_left_fence?(grid, i, j)
    has_right_fence = has_right_fence?(grid, i, j)

    vertical_prev_out_of_bounds = !within_bounds?(grid, i - 1, j)

    previous_has_left_fence = has_left_fence?(grid, i - 1, j)
    previous_has_right_fence = has_right_fence?(grid, i - 1, j)

    vertical_prev_same_region = !vertical_prev_out_of_bounds && grid[i - 1][j] == grid[i][j]

    sides_for_region += 1 if has_left_fence && vertical_prev_out_of_bounds
    sides_for_region += 1 if has_right_fence && vertical_prev_out_of_bounds
    sides_for_region += 1 if has_left_fence && !vertical_prev_out_of_bounds && !vertical_prev_same_region
    sides_for_region += 1 if has_right_fence && !vertical_prev_out_of_bounds && !vertical_prev_same_region
    sides_for_region += 1 if has_left_fence && !vertical_prev_out_of_bounds && !previous_has_left_fence && vertical_prev_same_region
    sides_for_region += 1 if has_right_fence && !vertical_prev_out_of_bounds && !previous_has_right_fence && vertical_prev_same_region
  end

  sides_for_region
end

def has_top_fence?(grid, i, j)
  !within_bounds?(grid, i - 1, j) || grid[i - 1][j] != grid[i][j]
end

def has_bottom_fence?(grid, i, j)
  !within_bounds?(grid, i + 1, j) || grid[i + 1][j] != grid[i][j]
end

def has_left_fence?(grid, i, j)
  !within_bounds?(grid, i, j - 1) || grid[i][j - 1] != grid[i][j]
end

def has_right_fence?(grid, i, j)
  !within_bounds?(grid, i, j + 1) || grid[i][j + 1] != grid[i][j]
end


def calculate_total_cost(grid)
  total_cost = 0
  global_map = Set.new
  
  (0...grid.size).map do |i|
    (0...grid[0].size).map do |j|
      next if global_map.include?("#{i},#{j}")

      visited_region = []
      sides = visit_region(grid, i, j, visited_region, global_map)
      sides = sides_for(visited_region, grid)
      total_cost = total_cost + (visited_region.size * sides)
    end
  end

  total_cost
end

def visit_region(grid, i, j, visited_region, global_map)
  return unless within_bounds?(grid, i, j)

  last_region = visited_region.last
  return if last_region && grid[last_region[0]][last_region[1]] != grid[i][j]
  
  return if visited_region.find { |r| r == [i, j] }

  directions = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ]

  global_map.add("#{i},#{j}")
  visited_region << [i, j]

  directions.each do |direction|
    next_position = [i + direction[0], j + direction[1]]
    visit_region(grid, next_position[0], next_position[1], visited_region, global_map)
  end
end

def within_bounds?(grid, i, j)
  i >= 0 && i < grid.size && j >= 0 && j < grid[0].size
end

require_relative './assert'

extend SuperDuperAssertions

input2 = <<~INPUT
EEEEE
EXXXX
EEEEE
EXXXX
EEEEE
INPUT

assert("works in the E shaped map", total_fence_price(input2), 236)

real_input = File.read('./input12.txt')
assert("calculates the real result", total_fence_price(real_input), 877492)
