def part_one(input)
  spaces_needed_per_shape = [7, 7, 7, 5, 7, 6]
  lines = parse(input)
  count = lines.filter do |line|
    grid_x, grid_y = line[0]
    total_squares = line[1].map.with_index do |squares, index|
      spaces_needed = spaces_needed_per_shape[index]
      squares * spaces_needed
    end.sum
    grid_area = grid_x * grid_y
    grid_area >= total_squares
  end

  count.size
end

def parse(input)
  input_lines = []
  input.each_line do |line|
    next unless line.include?('x')

    input_lines << line
  end
  input_lines.map do |line|
    grid, squares = line.split(':')
    grid = grid.split('x').map(&:to_i)
    squares = squares.strip.split(' ').map(&:to_i)
    [grid, squares]
  end
end

require_relative './assert'

extend SuperDuperAssertions

input = File.read('input12.txt')

assert('works with the real input', part_one(input), 521)
