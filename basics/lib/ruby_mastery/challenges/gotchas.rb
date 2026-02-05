require_relative '../challenge'

module RubyMastery
  module Challenges
    class Gotchas < Challenge
      def initialize
        super('Ruby Gotchas', '04_gotchas.rb')
      end

      def setup
        content = <<~RUBY
          # Ruby Mastery Kata: Common Gotchas
          # Replace __ with the correct value or fix the logic.

          def assert_equal(expected, actual, msg)
            if expected != actual
              puts "Assertion Failed: \#{msg}"
              puts "  Expected: \#{expected.inspect}"
              puts "  Actual:   \#{actual.inspect}"
              exit 1
            end
          end

          # Define the blank placeholder
          def __
            :blank
          end

          # Gotcha 1: Truthiness
          # In many languages, 0 or "" are falsey. What about Ruby?
          assert_equal __, !!0, "!!0 (Truthiness of 0)"
          assert_equal __, !!"", '!!"" (Truthiness of empty string)'

          # Gotcha 2: Local variable shadowing
          # What is the value of 'x' after the block?
          x = 10
          [1].each do |x|
            x = 20
          end
          assert_equal __, x, "Local variable x after block"

          # Gotcha 3: Multiple assignment
          a, b = [1, 2, 3]
          assert_equal __, b, "Multiple assignment b"

          # Gotcha 4: Array initialization
          # Why is this a gotcha?#{' '}
          # arr = Array.new(3, [])
          # arr[0] << "hit"
          # What is arr[1]?
          arr = Array.new(3, [])
          arr[0] << "hit"
          assert_equal __, arr[1], "Array initialization with default object"

          puts "All gotcha tests passed!"
        RUBY
        write_kata(content)
      end
    end
  end
end
