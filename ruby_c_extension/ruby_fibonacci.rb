def nth_fibonacci(n)
  if n <= 1
    return n
  end
  nth_fibonacci(n - 1) + nth_fibonacci(n - 2)
end

puts nth_fibonacci(44)