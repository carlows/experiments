#!/usr/bin/env ruby

require_relative './grep'

pattern = ARGV[0]
filename = ARGV[1]

grep = Grep.new(pattern, filename)
grep.run

