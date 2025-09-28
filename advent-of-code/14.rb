class TimeTraveler
  def initialize(input, grid_x = nil, grid_y = nil)
    @input = input
    @grid_x = grid_x || 11
    @grid_y = grid_y || 7
  end

  attr_reader :input, :grid_x, :grid_y

  def run(seconds = 100)
    guards = parse(input)

    guards.map do |guard|
      guard.move(seconds, grid_x, grid_y)
    end

    calculate_safety_factor(guards)
  end

  def calculate_safety_factor(guards)
    middle_x = (grid_x - 1) / 2
    middle_y = (grid_y - 1) / 2

    quadrants = guards.reduce([0, 0, 0, 0]) do |acc, guard|
      acc[0] += 1 if guard.px < middle_x && guard.py < middle_y
      acc[1] += 1 if guard.px > middle_x && guard.py < middle_y
      acc[2] += 1 if guard.px < middle_x && guard.py > middle_y
      acc[3] += 1 if guard.px > middle_x && guard.py > middle_y
      acc
    end
    
    quadrants.reduce(1, :*)
  end

  def parse(input)
    input.split("\n").map do |line|
      px, py, vx, vy = line.scan(/p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/).first
      Guard.new(px.to_i, py.to_i, vx.to_i, vy.to_i)
    end
  end
end

class Guard
  def initialize(px, py, vx, vy)
    @px = px
    @py = py
    @vx = vx
    @vy = vy
  end
  attr_reader :px, :py, :vx, :vy

  def move(seconds, grid_x, grid_y)
    @px = (@px + (@vx * seconds)) % grid_x
    @py = (@py + (@vy * seconds)) % grid_y
  end
end

require_relative 'assert'

extend SuperDuperAssertions

input = <<~INPUT
p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3
INPUT

assert("works with input", TimeTraveler.new(input).run(100), 12)

real_input = File.read("input14.txt")

assert("gives the real result", TimeTraveler.new(real_input, 101, 103).run(100), 222208000)

