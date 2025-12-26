#!/usr/bin/env ruby

require 'optparse'
require_relative './grep'

options = {}

OptionParser.new do |o|
  o.on('-R', '--recursive', 'Recursively search subdirectories') do |v|
    options[:recursive] = true
  end
  o.parse!
end
pattern = ARGV[0]
filenames = ARGV[1..]

grep = Grep.new(pattern, filenames, options)
grep.run

