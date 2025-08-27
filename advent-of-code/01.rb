list1 = []
list2 = []

File.readlines('./input01.txt').each do |line|
  split = line.split(' ')
  raise StandardError.new("We're not supposed to see more than 1 pair of numbers here... #{line}") if split.size > 2

  list1 << split[0].strip.to_i
  list2 << split[1].strip.to_i
end

list1.sort!
list2.sort!

joined_list = list1.zip(list2)

total_distance = joined_list.reduce(0) do |acc, (item1, item2)|
  distance = (item1 - item2).abs
  acc + distance
end

puts "The total distance is: #{total_distance}"
