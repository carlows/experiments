require_relative './assert'

def total_joltage(input)
  banks = parse(input)

  total_joltage = 0

  banks.each do |bank|
    max_joltage_for_bank = dfs(bank, 0, 1)
    total_joltage += max_joltage_for_bank.join('').to_i
  end

  total_joltage
end

def dfs(bank, i, battery_count = 1, cache = {})
  return [] if i >= bank.size
  return [] if battery_count > 12
  return cache["#{i},#{battery_count}"].split(',').map(&:to_i) if cache.key?("#{i},#{battery_count}")

  joltage_including_current = [bank[i]] + dfs(bank, i + 1, battery_count + 1, cache)
  joltage_excluding_current = dfs(bank, i + 1, battery_count, cache)

  if joltage_including_current.join('').to_i > joltage_excluding_current.join('').to_i
    cache["#{i},#{battery_count}"] = joltage_including_current.join(',')
    return joltage_including_current
  end

  cache["#{i},#{battery_count}"] = joltage_excluding_current.join(',')
  joltage_excluding_current
end

def parse(input)
  input.split("\n").map do |line|
    line.split("").map do |char|
      char.to_i
    end
  end
end

extend SuperDuperAssertions

test_input = <<~INPUT
987654321111111
811111111111119
234234234234278
818181911112111
INPUT

assert("works with test input", total_joltage(test_input), 3121910778619)

real_input = File.read("input03.txt")

assert("works with real input", total_joltage(real_input), 171518260283767)
