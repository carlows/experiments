def solve_part_one(input)
  nodes = parse(input)
  count_output_paths(nodes['you'], nodes)
end

def parse(input)
  input.split("\n").map do |line|
    parts = line.split(': ')
    [parts[0], parts[1].strip.split(' ')]
  end.each_with_object({}) do |node, acc|
    acc[node[0]] = node[1]
  end
end

def count_output_paths(current, nodes)
  return 1 if current == ['out']

  current.reduce(0) do |acc, node|
    acc + count_output_paths(nodes[node], nodes)
  end
end

require_relative './assert'

extend SuperDuperAssertions

input = <<~INPUT
  aaa: you hhh
  you: bbb ccc
  bbb: ddd eee
  ccc: ddd eee fff
  ddd: ggg
  eee: out
  fff: out
  ggg: out
  hhh: ccc fff iii
  iii: out
INPUT

assert('works with the sample input', solve_part_one(input), 5)

real_input = File.read('input11.txt')
assert('works with the real input', solve_part_one(real_input), 643)
