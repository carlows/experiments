require_relative '../challenge'

module RubyMastery
  module Challenges
    class PatternMatcher < Challenge
      def initialize
        super('The Pattern Matcher (Ruby 3)', '08_pattern_matcher.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 8: THE PATTERN MATCHER
          # --------------------------
          # Goal: Parse a nested API response using Ruby 3 Pattern Matching.
          #
          # Requirements:
          # 1. Use 'case ... in' to deconstruct the hash.
          # 2. Extract 'name' and 'city' from the nested structure.
          # 3. Handle cases where the status is "error" by extracting the message.

          class ApiParser
            def self.parse(response)
              # TODO: Use case...in here
              # response looks like:
              # { status: "success", data: { user: { name: "Matz", location: { city: "Tokyo" } } } }
              # OR
              # { status: "error", message: "Not found" }
            end
          end

          # --- TEST SUITE ---
          success_res = { status: "success", data: { user: { name: "Matz", location: { city: "Tokyo" } } } }
          error_res = { status: "error", message: "Not found" }

          name, city = ApiParser.parse(success_res)
          raise "Pattern matching failed: name mismatch" unless name == "Matz"
          raise "Pattern matching failed: city mismatch" unless city == "Tokyo"
          puts "✅ Success deconstruction passed"

          error_msg = ApiParser.parse(error_res)
          raise "Pattern matching failed: error message mismatch" unless error_msg == "Not found"
          puts "✅ Error handling passed"

          puts "✨ KATA COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Pattern Matching (`case...in`)
          Introduced in Ruby 2.7 and perfected in 3.0, Pattern Matching is a game-changer for working with structured data (JSON, XML, Abstract Syntax Trees). It combines branching with variable assignment.

          ### 2. Variable Pinning (`^`)
          If you want to match against an existing variable instead of assigning to a new one, you use the pin operator:
          `case x; in ^existing_val; ...`
          Without the `^`, Ruby would just create a new local variable `existing_val` and assign it the value of `x`.

          ### 3. Array and Hash Deconstruction
          You can match on structure:
          `in { data: [first, *rest] }`
          This extracts the first element of an array inside a hash key. It's much safer and more readable than `res[:data][0]`.

          ### 4. Right-ward Assignment
          Ruby 3 also introduced `data => { user: { name: name } }`. This is a one-line pattern match that raises a `NoMatchingPatternError` if the structure doesn't match. It's great for "asserting" the shape of data in your code.
        TEXT
      end
    end
  end
end
