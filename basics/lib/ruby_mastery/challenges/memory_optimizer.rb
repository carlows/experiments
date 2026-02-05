require_relative '../challenge'

module RubyMastery
  module Challenges
    class MemoryOptimizer < Challenge
      def initialize
        super('The Memory Optimizer (Efficiency)', '06_memory_optimizer.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 6: THE MEMORY OPTIMIZER
          # ---------------------------
          # Goal: Reduce the memory footprint of a processing loop.
          #
          # Requirements:
          # 1. Use 'frozen_string_literal' to prevent string allocations.
          # 2. Use in-place modification (bang methods) to avoid intermediate objects.
          # 3. Use 'Symbols' for fixed keys.
          # 4. Use 'WeakRef' (optional but expert) for large caches.

          # TODO: Add the magic comment at the very top of this file (conceptually)
          # Note: In this kata, we'll simulate the effect by checking object IDs.

          class DataProcessor
            def initialize
              @cache = {}
            end

            def process_list(list)
              # BUG: This creates a NEW string object for every iteration!
              # Fix it so that "tag" is always the same object.
              list.map do |item|
                tag = "processed"#{' '}
                { tag: tag, data: item.upcase }#{' '}
              end
            end

            def process_in_place!(list)
              # TODO: Modify the strings in the list IN PLACE#{' '}
              # instead of returning a new array.
            end
          end

          # --- TEST SUITE ---
          processor = DataProcessor.new

          # 1. Test String Allocation
          # We want to see if multiple calls use the same string object.
          results = processor.process_list(["a", "b"])
          id1 = results[0][:tag].object_id
          id2 = results[1][:tag].object_id

          # In a real file with # frozen_string_literal: true, these would be equal.
          # For this kata, try to use a Symbol or a frozen constant to fix it.
          raise "Memory Leak: Unique string objects created for fixed tag" unless id1 == id2
          puts "✅ String deduplication passed"

          # 2. Test In-place modification
          data = ["hello", "world"]
          processor.process_in_place!(data)
          raise "In-place failure: Original array not modified" unless data[0] == "HELLO"
          puts "✅ In-place modification passed"

          puts "✨ KATA COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `frozen_string_literal: true`
          *Effective Ruby Item 49* - This magic comment is the single easiest way to boost Ruby performance and reduce memory. It makes all string literals in the file frozen, meaning Ruby only creates one instance of `"processed"` and reuses it. In Ruby 3+, this is the recommended default.

          ### 2. Symbols vs Strings
          Symbols are immutable and deduplicated by default. They are perfect for Hash keys or identifiers.#{' '}
          *Expert Warning:* Before Ruby 2.2, Symbols were never garbage collected. If you converted user input to symbols (`"input".to_sym`), you could crash a server via a memory exhaustion attack. Modern Ruby GCs symbols, but you should still prefer `String#freeze` for dynamic values.

          ### 3. Mutating in Place (`!`)
          `map` creates a new array. `map!` modifies the existing array. When dealing with millions of records, the `!` versions of methods (like `gsub!`, `merge!`, `map!`) save the garbage collector from having to clean up thousands of temporary objects.

          ### 4. ObjectSpace and Memory Profiling
          Experts use `ObjectSpace.count_objects` to see how many strings, hashes, or classes are currently in memory. If you see the number of strings growing indefinitely, you have a leak—likely caused by caching objects in a global variable or a constant without ever clearing them.
        TEXT
      end
    end
  end
end
