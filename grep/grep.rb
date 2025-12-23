# frozen_string_literal: true

class Grep
  attr_reader :pattern, :filename

  def initialize(pattern, filename)
    @pattern = pattern
    @filename = filename
  end

  def run
    match = false
    File.readlines(filename).each do |line|
      if line.include?(pattern)
        puts line
        match = true
      end
    end
    exit(match ? 0 : 1)
  end
end
