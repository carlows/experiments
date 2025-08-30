corrupted_file = File.read('./input03.txt')

def get_total_value_from_corrupted_file(file)
  valid_mul_fns = file.scan(/mul\([0-9]{1,3},[0-9]{1,3}\)/)
  valid_mul_fns.reduce(0) do |acc, mul_str|
    matches = mul_str.match(/mul\(([0-9]{1,3}),([0-9]{1,3})\)/)
    x = matches[1].to_i
    y = matches[2].to_i

    acc + (x * y)
  end
end

def assert(file, expected)
  total = get_total_value_from_corrupted_file(file)
  raise StandardError.new("Woops, wrong output #{total} expected: #{expected}") if total != expected
  puts "#{expected} Test passed :D"
end

assert("mul(5,5)", 25)
assert("mul(2,4)", 8)
assert("mul(2,2)mul(3,3)", 13)
assert("mult(5,5)", 0)
assert("mul(1000,0)", 0)
assert("mul (1,1)", 0)
assert("mul( 1,1 )", 0)
assert("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))", 161)

puts "The answer to life is: #{get_total_value_from_corrupted_file(corrupted_file)}"
