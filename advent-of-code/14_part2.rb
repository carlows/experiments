class TimeTraveler
  def initialize(input, grid_x = nil, grid_y = nil)
    @input = input
    @grid_x = grid_x || 11
    @grid_y = grid_y || 7
  end

  attr_reader :input, :grid_x, :grid_y

  def run(seconds = 100)
    guards = parse(input)
    
    seconds.times do |i|
      guards = guards.map do |guard|
        guard.move(1, grid_x, grid_y)
        guard
      end
      if calculate_spread_by_std_dev(guards) < 30
        puts "Image after #{i + 1} seconds"
        draw(guards)
        return i + 1
      end
    end

    calculate_safety_factor(guards)
  end

  def calculate_spread_by_std_dev(guards)
    x_coords = guards.map { |pos| pos.px }
    y_coords = guards.map { |pos| pos.py }

    x_std_dev = standard_deviation(x_coords)
    y_std_dev = standard_deviation(y_coords)

    Math.sqrt(x_std_dev**2 + y_std_dev**2)
  end

  def standard_deviation(values)
    return 0.0 if values.length < 2

    mean = values.sum.to_f / values.length

    variance = values.map { |x| (x - mean)**2 }.sum / values.length

    Math.sqrt(variance)
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

  def draw(guards)
    (0...grid_x).each do |x|
      line = ''
      (0...grid_y).each do |y|
        guard = guards.find { |guard| guard.px == x && guard.py == y }
        line += guard ? "#".send(guard.color) : "."
        guard.color = :green if guard
      end
      puts line
    end
    puts `clear`
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
    @color = :green
  end
  attr_reader :px, :py, :vx, :vy
  attr_accessor :color

  def move(seconds, grid_x, grid_y)
    @px = (@px + (@vx * seconds)) % grid_x
    @py = (@py + (@vy * seconds)) % grid_y
  end
end

class String
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end
end

require_relative 'assert'

extend SuperDuperAssertions

real_input = File.read("input14.txt")

assert("gives the real result", TimeTraveler.new(real_input, 101, 103).run(20000), 7623)

