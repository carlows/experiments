# frozen_string_literal: true

require 'find'

class Grep
  attr_reader :pattern, :filedirs, :recursive, :invert, :piped

  def initialize(pattern, filedirs, options = {})
    @pattern = pattern
    @filedirs = filedirs
    @recursive = options[:recursive]
    @invert = options[:invert]
    @piped = options[:piped]
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
    invert ? !line.include?(pattern) : line.include?(pattern)
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
