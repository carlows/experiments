def stones(input, blinks)
  stones = parse(input)
  cache = {}

  stones.reduce(0) do |acc, stone|
    acc + expand(stone, blinks, cache)
  end
end

def parse(input)
  input.split(' ').map(&:to_i)
end

def expand(stone, blinks, cache)
  return 1 if blinks.zero?

  cache_key = "#{stone},#{blinks}"
  return cache[cache_key] if cache.key?(cache_key)

  if stone == 0
    result = expand(1, blinks - 1, cache)
    cache[cache_key] = result

    return result
  end
  
  if (Math.log10(stone).to_i + 1).even?
    stone_size = Math.log10(stone).to_i + 1
    num = 1
    (stone_size / 2).times { num *= 10 }
    result = expand(stone / num, blinks - 1, cache) + expand(stone % num, blinks - 1, cache)
    cache[cache_key] = result

    return result
  end

  result = expand(stone * 2024, blinks - 1, cache)
  cache[cache_key] = result
  result
end

require_relative './assert'

extend SuperDuperAssertions

assert('does 25 blinks and returns the number of stones', stones('125 17', 25), 55312)

assert('calculates the real result', stones(File.read('./input11.txt'), 25), 207_683)

assert('calculates the result for part 2', stones(File.read('./input11.txt'), 75), 244782991106220)

