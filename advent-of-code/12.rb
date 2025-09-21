# sample:
# AAAA
# BBCD
# BBCC
# EEEC
#
# notes:
# - I can't use a global hash because I need to be able to differentiate between the plant types
#   - If we bump into the same platn type, but we have alredy seen it in our current visit, then
#     it should not count as a perimeter.
#   - If we bump into a different plant type or we run out of bounds, then we should count it as a perimeter.
# - I think we need to keep track of the current path we're on.
# - We also need to update the result hash after the recursive call, and at this point we can count
#   the number of perimeters we've seen for the current plot.

def total_fence_price(input)
  grid = parse(input)
  
  global_map = Set.new
  total_cost = 0

  (0...grid.size).map do |i|
    (0...grid[0].size).map do |j|
      next if global_map.include?("#{i},#{j}")

      visited_region = []
      perimeter = visit_region(grid, i, j, visited_region, global_map)
      total_cost = total_cost + (visited_region.size * perimeter)
    end
  end

  total_cost
end

def parse(input)
  input.split("\n").map(&:chars)
end

def visit_region(grid, i, j, visited_region, global_map)
  # +1 perimeter if we're out of bounds
  return 1 unless within_bounds?(grid, i, j)

  # +1 perimeter if the region is a different plant
  last_region = visited_region.last
  return 1 if last_region && grid[last_region[0]][last_region[1]] != grid[i][j]
  
  # for when we find the same plant but we've already seen it
  return 0 if visited_region.find { |r| r == [i, j] }

  directions = [
    [0, 1],
    [1, 0],
    [0, -1],
    [-1, 0]
  ]

  global_map.add("#{i},#{j}")
  visited_region << [i, j]

  directions.reduce(0) do |acc, direction|
    next_position = [i + direction[0], j + direction[1]]
    acc + visit_region(grid, next_position[0], next_position[1], visited_region, global_map)
  end
end

def within_bounds?(grid, i, j)
  i >= 0 && i < grid.size && j >= 0 && j < grid[0].size
end

require_relative './assert'

extend SuperDuperAssertions

input1 = <<~INPUT
AB
INPUT

assert("calculates the total fence price for a simple example", total_fence_price(input1), 8)

input2 = <<~INPUT
AB
AB
INPUT

assert("calculates the result for another sample", total_fence_price(input2), 24)

input3 = <<~INPUT
AAAA
BBCD
BBCC
EEEC
INPUT

assert("works on an even bigger example", total_fence_price(input3), 140)

input4 = <<~INPUT
OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
INPUT

assert("works on a weird example", total_fence_price(input4), 772)

input5 = <<~INPUT
RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE
INPUT

assert("works on a larger example", total_fence_price(input5), 1930)

real_input = File.read('./input12.txt')
assert("calculates the real result", total_fence_price(real_input), 1464678)
