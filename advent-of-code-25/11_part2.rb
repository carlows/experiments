def solve_part_two(input)
  nodes = parse(input)
  count_output_paths('svr', nodes['svr'], nodes)
end

def parse(input)
  input.split("\n").map do |line|
    parts = line.split(': ')
    [parts[0], parts[1].strip.split(' ')]
  end.each_with_object({}) do |node, acc|
    acc[node[0]] = node[1]
  end
end

def count_output_paths(key, children, nodes, visited = Set.new, cache = {})
  includes_fft = visited.include?('fft')
  includes_dac = visited.include?('dac')

  if children == ['out']
    return includes_fft && includes_dac ? 1 : 0
  end
  
  visited_key = [includes_fft ? "1": "0", includes_dac ? "1" : "0"].join(',')
  if cache.key?("#{key}-#{visited_key}")
    return cache["#{key}-#{visited_key}"]
  end

  children.reduce(0) do |acc, node|
    visited.add(node)
    sum = acc + count_output_paths(node, nodes[node], nodes, visited, cache)
    cache["#{key}-#{visited_key}"] = sum
    visited.delete(node)
    sum
  end
end

require_relative './assert'

extend SuperDuperAssertions

input = <<~INPUT
  svr: aaa bbb
  aaa: fft
  fft: ccc
  bbb: tty
  tty: ccc
  ccc: ddd eee
  ddd: hub
  hub: fff
  eee: dac
  dac: fff
  fff: ggg hhh
  ggg: out
  hhh: out
INPUT

assert('works with the sample input', solve_part_two(input), 2)

real_input = File.read('input11.txt')
assert('works with the real input', solve_part_two(real_input), 417190406827152)
