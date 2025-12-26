# frozen_string_literal: true

require 'find'

class Grep
  attr_reader :pattern, :filedirs, :recursive

  def initialize(pattern, filedirs, options = {})
    @pattern = pattern
    @filedirs = filedirs
    @recursive = options[:recursive]
  end

  def run
    match = false
    paths_to_read do |path|
      File.readlines(path).each do |line|
        if line.include?(pattern)
          puts "#{path}: #{line}"
          match = true
        end
      end
    end
    exit(match ? 0 : 1)
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
