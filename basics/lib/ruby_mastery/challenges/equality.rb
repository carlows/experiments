require_relative '../challenge'

module RubyMastery
  module Challenges
    class Equality < Challenge
      def initialize
        super('Equality', '01_equality.rb')
      end

      def setup
        content = <<~RUBY
          # PHASE 1: OBSERVATION
          # Run this script and look at the output.#{' '}
          # Try to spot the pattern without reading any tutorials.

          def experiment(expression_string)
            result = eval(expression_string)
            puts "The result of [\#{expression_string}] is: \#{result.inspect}"
          end

          if ENV['OBSERVE']
            puts "--- Ruby Equality Lab ---"
            experiment "1 == 1.0"
            experiment "1.eql?(1.0)"
            experiment "1.equal?(1.0)"
            experiment "Integer === 42"
            experiment "String === 42"
            experiment ":hello.equal?(:hello)"
            experiment "'hello'.equal?('hello')"
            exit
          end

          # PHASE 2: APPLICATION
          # Now, based on what you saw (or by running 'OBSERVE=1 ruby 01_equality.rb'),
          # fill in the missing code to make these assertions pass.

          def verify(actual, expected)
            if actual != expected
              puts "❌ Mismatch!"
              puts "  You thought the result was: \#{expected.inspect}"
              puts "  Ruby says the result is:    \#{actual.inspect}"
              exit 1
            end
          end

          # Replace the blanks with your guess (true or false)
          verify (1 == 1.0),         __
          verify (1.eql? 1.0),       __
          verify (Integer === 42),   __
          verify (:a.equal? :a),     __
          verify ("a".equal? "a"),   __

          # EXTRA CHALLENGE:#{' '}
          # Write an expression involving '1' and '1.0' that returns TRUE.
          # actual_expr1 = ...
          # verify actual_expr1, true

          puts "✨ Level Cleared!"
        RUBY
        write_kata(content)
      end
    end
  end
end
