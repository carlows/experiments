def __; :blank; end
# Ruby Mastery Kata: Common Gotchas
# Replace __ with the correct value or fix the logic.

def assert_equal(expected, actual, msg)
  if expected != actual
    puts "Assertion Failed: #{msg}"
    puts "  Expected: #{expected.inspect}"
    puts "  Actual:   #{actual.inspect}"
    exit 1
  end
end

# Define the blank placeholder
def test
  :blank
end

# Gotcha 1: Truthiness
# In many languages, 0 or "" are falsey. What about Ruby?
assert_equal true, !!0, "!!0 (Truthiness of 0)"
assert_equal true, !!"", '!!"" (Truthiness of empty string)'

# Gotcha 2: Local variable shadowing
# What is the value of 'x' after the block?
x = 10
[1].each do |x|
  x = 20
end
assert_equal 20, x, "Local variable x after block"

# Gotcha 3: Multiple assignment
a, b = [1, 2, 3]
assert_equal 2, b, "Multiple assignment b"

# Gotcha 4: Array initialization
# Why is this a gotcha? 
# arr = Array.new(3, [])
# arr[0] << "hit"
# What is arr[1]?
arr = Array.new(3, [])
arr[0] << "hit"
assert_equal "hit", arr[1], "Array initialization with default object"

puts "All gotcha tests passed!"
