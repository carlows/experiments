require 'colorize'
require 'fileutils'

module RubyMastery
  class Challenge
    attr_reader :name, :file_path

    def initialize(name, file_name)
      @name = name
      @file_path = File.join(Dir.pwd, 'playground', file_name)
    end

    def setup
      raise NotImplementedError
    end

    # This should be overridden by subclasses to provide expert-level explanations
    def debrief
      puts "\n--- Sensei's Note ---".colorize(:blue).bold
      puts "Great job completing this kata! Here's a breakdown of the core concepts you explored."
    end

    def verify
      # We check if the file exists first
      unless File.exist?(@file_path)
        puts 'File not found! Run setup first.'.colorize(:red)
        return false
      end

      # Run the ruby file and capture output
      output = `ruby #{@file_path} 2>&1`
      success = $?.success?

      if success
        puts '✨ Excellent work! The kata is complete.'.colorize(:green).bold
        debrief
        true
      else
        puts '❌ Not quite there yet. Ruby reported an error:'.colorize(:red)
        puts '-' * 40
        puts output.colorize(:light_black)
        puts '-' * 40
        false
      end
    end

    protected

    def write_kata(content)
      FileUtils.mkdir_p(File.dirname(@file_path))
      File.write(@file_path, content)
      puts "Kata generated at: #{@file_path.colorize(:cyan)}"
    end
  end
end
