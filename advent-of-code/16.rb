class Maze
  def initialize(input)
    @grid = parse(input)
    @initial_position = find(grid, 'S')
    @initial_dir = 0
  end

  attr_reader :grid, :initial_position, :initial_dir, :goal_position

  def parse(input)
    input.split("\n").map { |line| line.chars }
  end

  def find(grid, node)
    (0...grid.size).each do |x|
      (0...grid[0].size).each do |y|
        return [x, y] if grid[x][y] == node
      end
    end
  end

  def find_optimal_score
    start_x, start_y = initial_position
    start_item = PathItem.new(start_x, start_y, initial_dir)

    calculate_optimal_score(start_item)
  end

  def calculate_optimal_score(item)
    min_heap = MinHeap.new
    min_heap.push([0, item])
    visited = Set.new

    directions = [[0, 1], [1, 0], [0, -1], [-1, 0]]
    
    until min_heap.empty?
      current = min_heap.shift
      score = current[0]
      ux, uy, udir = current[1].x, current[1].y, current[1].dir

      if grid[ux][uy] == 'E'
        return score
      end

      if visited.include?("#{ux},#{uy},#{udir}")
        next
      end

      visited.add("#{ux},#{uy},#{udir}")

      directions.each_with_index do |_dir, dir_idx|
        vx, vy = ux + directions[dir_idx][0], uy + directions[dir_idx][1]

        if grid[vx][vy] != '#'
          cost = dir_idx == udir ? 1 : 1001
          min_heap.push([score + cost, PathItem.new(vx, vy, dir_idx)])
        end
      end
    end
  end
end

class MinHeap
  def initialize
    @heap = []
  end
  
  attr_reader :heap

  def empty?
    @heap.empty?
  end

  def push(item)
    @heap << item
    # 0 represents the weight, 1 represents the node
    @heap.sort_by! { |i| i[0] }
  end

  def shift
    @heap.shift
  end
end

class Compass
  def self.directions
    {
      up: [-1, 0],
      right: [0, 1],
      down: [1, 0],
      left: [0, -1]
    }
  end

  def self.possible_directions(item)
    dirs = directions.keys
    next_idx = (dirs.index(item.dir) + 1) % dirs.size
    prev_idx = (dirs.index(item.dir) - 1) % dirs.size
    [item.dir, dirs[prev_idx], dirs[next_idx]]
  end
end

class PathItem
  attr_reader :x, :y, :dir

  def initialize(x, y, dir)
    @x = x
    @y = y
    @dir = dir
  end
end

require_relative './assert'

extend SuperDuperAssertions


input = <<~INPUT
###############
#.#..##.#####E#
#############.#
#.............#
#.###########.#
#.###########.#
#.#...#######.#
#.#.#.#######.#
#S..#.........#
###############
INPUT

assert('finds the optimal path with a T junction', Maze.new(input).find_optimal_score, 3019)

input = <<~INPUT
###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############
INPUT

assert('it finds the optimal path', Maze.new(input).find_optimal_score, 7036)

input2 = <<~INPUT
#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################
INPUT

assert("solves the second example", Maze.new(input2).find_optimal_score, 11048)

input_real = File.read('input16.txt')

assert('it finds the optimal result for the real input', Maze.new(input_real).find_optimal_score, 82464)
