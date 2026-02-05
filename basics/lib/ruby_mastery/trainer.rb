require 'tty-prompt'
require 'colorize'
require_relative 'stats'

module RubyMastery
  class Trainer
    def initialize
      @prompt = TTY::Prompt.new
      @challenges = []
    end

    def add_challenge(challenge)
      @challenges << challenge
    end

    def start
      puts 'Welcome to Ruby Mastery Katas!'.colorize(:cyan).bold
      puts "Now in 'Fix-it' mode. You will edit files to make tests pass."

      loop do
        choices = [
          { name: 'View Mastery Profile', value: :profile },
          { name: '--- Modules ---', disabled: '(Select below)' }
        ]
        choices += @challenges.map { |c| { name: c.name, value: c } }
        choices << { name: 'Exit', value: :exit }

        choice = @prompt.select('Main Menu:', choices)

        case choice
        when :profile
          RubyMastery::Stats.display
          @prompt.keypress('Press any key to return...')
          next
        when :exit
          break
        end

        challenge = choice
        challenge.setup

        loop do
          action = @prompt.select("File is ready at #{challenge.file_path}. What's next?", [
                                    { name: 'Verify my solution', value: :verify },
                                    { name: 'Reset file (Warning: Overwrites your changes)', value: :reset },
                                    { name: 'Back to main menu', value: :back }
                                  ])

          case action
          when :verify
            break if challenge.verify
          when :reset
            challenge.setup
          when :back
            break
          end
        end
      end

      puts 'Keep practicing! Goodbye.'
    end
  end
end
