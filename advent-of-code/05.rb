def calculate(file)
  rules, updates = process_input(file)
  map = build_map(rules)

  middle_nums = updates.filter_map do |update|
    numbers = update.split(',').map(&:to_i)
    raise StandardError.new("No even rows accepted") if numbers.size % 2 == 0
    
    missordered = false
    numbers.each_with_index do |num, idx|
      remaining = numbers[idx + 1..]
      missordered = true if map[num].intersect?(remaining)
    end

    next nil if missordered

    numbers[numbers.size / 2]
  end

  middle_nums.sum
end

def process_input(file)
  rules, updates = file.split("\n\n")
  rules = rules.split("\n")
  updates = updates.split("\n")
  [rules, updates]
end

def build_map(rules)
  map = Hash.new { |hsh, key| hsh[key] = [] }
  rules.each_with_object(map) do |rule, obj|
    x, y = rule.split("|")
    obj[y.to_i] << x.to_i
  end
  map
end

require_relative './assert'

extend SuperDuperAssertions

simple = <<~TEXT
  47|53
  12|42

  12,42,53
TEXT
assert("Simple case", calculate(simple), 42)

even_rows = <<~TEXT
  47|53
  12|42

  12,42,53,30
TEXT

begin
  assert("Shall not accept even rows", calculate(even_rows), [])
rescue StandardError
  puts "Success!"
end

page_example = <<~TEXT
  47|53
  97|13
  97|61
  97|47
  75|29
  61|13
  75|53
  29|13
  97|29
  53|29
  61|53
  97|53
  61|29
  47|13
  75|47
  97|75
  47|61
  75|61
  47|29
  75|13
  53|13

  75,47,61,53,29
  97,61,53,29,13
  75,29,13
  75,97,47,61,53
  61,13,29
  97,13,75,29,47
TEXT

assert("More contrived example", calculate(page_example), 143)

real_input = File.read('./input05.txt')

assert("Gives teh result!!", calculate(real_input), 6260)
