# frozen_string_literal: true

safe_reports = 0 

def valid_report?(line)
  levels = line.split(' ').map(&:to_i)

  increasing = levels[0] < levels[1]

  (0...levels.size - 1).each do |i|
    first = levels[i]
    second = levels[i + 1]

    # at least one of difference
    return false if (first - second).abs < 1
    # at most three of difference
    return false if (first - second).abs > 3
    return false if increasing && first > second
    return false if !increasing && first < second
  end

  true
end

def assert(line, expected)
  raise "Woops, invalid output for: #{line}" if valid_report?(line) != expected
  puts "Test passed. #{line} == #{expected}"
end

assert("10 7 4 1", true)
assert("5 6 7 10 13 16 13", false)
assert("19 21 24 27 28 28", false)
assert("1 2 3 4 5 6 7 8", true)
assert("8 7 6 5 4", true)
assert("1 1 23", false)
assert("2 3 1", false)
assert("1 2 1", false)
assert("1 4 7 10", true)
assert("1 4 8 10", false)

File.foreach('input02.txt') do |line|
  safe_reports += 1 if valid_report?(line)
end

puts "The total number of safe reports is: #{safe_reports}"

