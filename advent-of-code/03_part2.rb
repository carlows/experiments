corrupted_file = File.read('./input03.txt')

def get_total_value_from_corrupted_file(file)
  mul_allowed = true
  regexpr = /(mul\([0-9]{1,3},[0-9]{1,3}\))|(do\(\))|(don't\(\))/

  file.scan(regexpr).reduce(0) do |acc, (mul, allow, disallow)|
    mul_allowed = false if !disallow.nil?
    mul_allowed = true if !allow.nil?

    if !mul.nil? && mul_allowed
      x, y = extract_operands(mul)
      next acc + (x * y)
    end

    acc
  end
end

def extract_operands(mul)
  matches = mul.match(/mul\(([0-9]{1,3}),([0-9]{1,3})\)/)
  [matches[1].to_i, matches[2].to_i]
end

require_relative './assert'
extend SuperDuperAssertions

assert("Excludes based on don't rules", get_total_value_from_corrupted_file("xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"), 48)
assert("Gives me dah answer!", get_total_value_from_corrupted_file(corrupted_file), 78683433)
