require 'colorize'

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

    def verify
      # We check for __ but we should define it so the file actually runs
      # if the user hasn't replaced it yet.

      content = File.read(@file_path)

      # Inject the __ helper if it's missing, so the file is syntactically valid
      unless content.include?('def __')
        content = "def __; :blank; end\n" + content
        File.write(@file_path, content)
      end

      # Run the ruby file and capture output
      output = `ruby #{@file_path} 2>&1`
      success = $?.success?

      if success && !File.read(@file_path).include?(':blank')
        puts '✨ Excellent work! The kata is complete.'.colorize(:green).bold
        true
      else
        if File.read(@file_path).include?(':blank') || content.include?('__')
          puts 'You still have some blanks (__) to fill in!'.colorize(:yellow)
        else
          puts '❌ Not quite there yet. Ruby reported an error:'.colorize(:red)
        end
        puts '-' * 40
        puts output.colorize(:light_black)
        puts '-' * 40
        false
      end
    end

    protected

    def write_kata(content)
      # Ensure the directory exists
      FileUtils.mkdir_p(File.dirname(@file_path))
      File.write(@file_path, content)
      puts "Kata generated at: #{@file_path.colorize(:cyan)}"
    end
  end
end
require 'fileutils'
