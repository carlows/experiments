# frozen_string_literal: true

def parse_line(line)
  line.split(' ').map(&:to_i)
end

def safe_report?(levels, change_count = 0)
  # as soon as we encounter a second error then we're kaput!
  return false if change_count > 1

  increasing = levels[0] < levels[1]

  (0...levels.size - 1).each do |i|
    first = levels[i]
    second = levels[i + 1]
    difference = (first - second).abs
    if difference < 1 || 
       difference > 3 || 
       increasing && first > second || 
       !increasing && first < second
      return (0...levels.size).any? do |y|
        safe_report?(levels[0...y] + levels[y + 1..], change_count + 1)
      end
    end
  end

  true
end

# This solution is better because we only check removing 3 invalid characters: the previous, current or next.
# While the previous solution had to check for every single character again.
def safe_report_2?(levels, change_count = 0)
  # as soon as we encounter a second error then we're kaput!
  return false if change_count > 1

  increasing = levels[0] < levels[1]

  (0...levels.size - 1).each do |i|
    first = levels[i]
    second = levels[i + 1]
    difference = (first - second).abs
    if difference < 1 || 
       difference > 3 || 
       increasing && first > second || 
       !increasing && first < second
      return safe_report?(levels[0...i] + levels[i + 1..], change_count + 1) ||
             safe_report?(levels[0..i] + levels[i + 2..], change_count + 1) ||
             safe_report?(levels[0...i - 1] + levels[i..], change_count + 1)
    end
  end

  true
end

def assert(line, expected)
  levels = parse_line(line)
  raise "Woops, invalid output for: #{levels}" if safe_report?(levels) != expected
  puts "Test passed. #{line} == #{expected}"
end

assert("7 6 4 2 1", true)
assert("1 2 7 8 9", false)
assert("9 7 6 2 1", false)
assert("1 3 2 4 5", true)
assert("8 6 4 4 1", true)
assert("1 3 6 7 9", true)
assert("51 48 46 43 42 41 38 36", true)
assert("82 79 78 77 74", true)
assert("8 8 9 11 8 12", false)
assert("83 77 75 73 71 67 65 62", false)
assert("2 7 9 10 9 14", false)
assert("70 65 63 62 61 58 56 53", true)
assert("60 64 63", true)
assert("60 60 60", false)
assert("10 20 19", true)
assert("33 35 38 39 42 45", true)
assert("76 79 80 82 83 84 87", true)
assert("10 14 15 18 19 20 22 27", false)
assert("49 48 47 46 43 42 41 34", true)
assert("34 41 42 43 46 47 48 49", true)
assert("1 2 3 7 8 6 10 12", false)

safe_reports = 0 

File.foreach('input02.txt') do |line|
  levels = parse_line(line)
  safe_reports += 1 if safe_report?(levels)

  # Turns out there are cases where the correction we're looking for is in a different place.
  puts "Failed: #{line}" if safe_report?(levels) != safe_report_2?(levels)
end

puts "The total number of safe reports is: #{safe_reports}"

