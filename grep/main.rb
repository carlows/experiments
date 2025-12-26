#!/usr/bin/env ruby

require 'optparse'
require_relative './grep'

options = {}

if !STDIN.tty?
  options[:piped] = STDIN.read
end
OptionParser.new do |o|
  o.on('-r', '--recursive', 'Recursively search subdirectories') do |v|
    options[:recursive] = true
  end
  o.on('-v', '--invert', 'Inverts the pattern to exclude the matches') do |v|
    options[:invert] = true
  end
  o.parse!
end
pattern = ARGV[0]
filenames = ARGV[1..]

grep = Grep.new(pattern, filenames, options)
options[:piped] ? grep.run_from_pipe : grep.run_from_filepaths

