require "bundler/setup"
require "ruby_c_extension"

def nth_fibonacci(n)
  if n <= 1
    return n
  end
  nth_fibonacci(n - 1) + nth_fibonacci(n - 2)
end

# time these two function calls and print the time taken together with the result
start_time = Time.now
RubyCExtension::Fibonacci.nth_fibonacci(44)
end_time = Time.now
puts "Time taken for C extension: #{end_time - start_time} seconds"

start_time = Time.now
nth_fibonacci(44)
end_time = Time.now
puts "Time taken ruby function: #{end_time - start_time} seconds"