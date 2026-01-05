# frozen_string_literal: true

require 'find'
require_relative './regex'

class String
  def match?(expr)
    Regex::Matcher.new(expr).match?(self)
  end
end

class Grep
  attr_reader :pattern, :filedirs, :recursive, :invert, :piped
  attr_reader :ignore_case

  def initialize(pattern, filedirs, options = {})
    @pattern = pattern
    @filedirs = filedirs
    @recursive = options[:recursive]
    @invert = options[:invert]
    @piped = options[:piped]
    @ignore_case = options[:ignore_case]
  end

  def run_from_filepaths
    match = false
    paths_to_read do |path|
      File.readlines(path).each do |line|
        if matches?(line)
          puts "#{path}: #{line}"
          match = true
        end
      end
    end
    exit(match ? 0 : 1)
  end

  def run_from_pipe
    match = false
    piped.split("\n").each do |line|
      if matches?(line)
        puts line
        match = true
      end
    end
    exit(match ? 0 : 1)
  end

  def matches?(line)
    # opts = ignore_case ? 'i' : ''
    # expr = Regexp.compile(pattern, opts)
    invert ? !line.match?(pattern) : line.match?(pattern)
  end

  def paths_to_read
    filedirs.each do |filedir| 
      if File.directory?(filedir)
        next unless recursive

        Find.find(filedir) do |path|
          next if FileTest.directory?(path)

          yield path
        end
        next
      end

      yield filedir
    end
  end
end
