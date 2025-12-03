require_relative './assert'

def total_joltage(input)
  banks = parse(input)

  total_joltage = 0

  banks.each do |bank|
    max_bank_joltage = 0
    max_first_battery = 0

    (0...bank.size).each do |i|
      next if bank[i] < max_first_battery

      (i + 1...bank.size).each do |j|
        num = (bank[i].to_s + bank[j].to_s).to_i
        if num > max_bank_joltage
          max_bank_joltage = num 
          max_first_battery = bank[i]
        end
      end
    end

    total_joltage += max_bank_joltage
  end

  total_joltage
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

assert("works with test input", total_joltage(test_input), 357)

real_input = File.read("input03.txt")

assert("works with real input", total_joltage(real_input), 17330)
