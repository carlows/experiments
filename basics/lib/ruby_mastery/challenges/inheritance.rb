require_relative '../challenge'

module RubyMastery
  module Challenges
    class Inheritance < Challenge
      def initialize
        super('Module Hierarchy', '02_inheritance.rb')
      end

      def setup
        content = <<~RUBY
          # Ruby Mastery Kata: Inheritance & Modules
          # Use 'include', 'extend', or 'prepend' to make the tests pass.

          def assert_ancestors(klass, expected_first_few)
            actual = klass.ancestors.first(expected_first_few.size).map(&:to_s)
            if actual != expected_first_few
              puts "Ancestor mismatch for \#{klass}!"
              puts "  Expected: \#{expected_first_few}"
              puts "  Actual:   \#{actual}"
              exit 1
            end
          end

          module M1; end
          module M2; end

          # Challenge 1: Make M1 appear AFTER Class A in the ancestor chain
          class A
            # __ M1
          end
          # assert_ancestors(A, ["A", "M1"])

          # Challenge 2: Make M2 appear BEFORE Class B in the ancestor chain
          class B
            # __ M2
          end
          # assert_ancestors(B, ["M2", "B"])

          # Challenge 3: Use extend to add methods to the CLASS itself (not instances)
          module ClassMethods
            def who_am_i; "A Class"; end
          end

          class C
            # __ ClassMethods
          end

          if C.respond_to?(:who_am_i) && C.who_am_i == "A Class"
            puts "Challenge 3 passed!"
          else
            puts "Challenge 3 failed: C should respond to who_am_i"
            exit 1
          end

          puts "All inheritance tests passed!"
          # Note: Uncomment the assertions above and replace __ with the right keyword.
        RUBY
        write_kata(content)
      end
    end
  end
end
