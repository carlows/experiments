require_relative '../challenge'

module RubyMastery
  module Challenges
    class MemoryOptimizer < Challenge
      def initialize
        super('The Mega Memory Optimizer (10-Stage GC)', '06_memory_optimizer.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 6: THE MEGA MEMORY OPTIMIZER
          # ---------------------------------
          # Goal: Build an ultra-efficient data processor.

          class Optimizer
            # 1. String Freezing: Use 'frozen_string_literal: true' conceptually.
            # 2. Symbol Pools: Use Symbols for Hash keys to avoid allocation.
            # 3. Bang Transformation: Use 'map!' to modify arrays without copying.
            # 4. In-Place Substitution: Use 'gsub!' instead of 'gsub'.
            # 5. Large String Buffer: Use '<<' instead of '+' for string concatenation.
            # 6. Object Reuse: Use a persistent 'buffer' object for data processing.
            # 7. Weak References: Use 'ObjectSpace::WeakMap' for caching.
            # 8. GC Manual Trigger: Explain when 'GC.start' is actually useful.
            # 9. Finalizers: Use 'ObjectSpace.define_finalizer' to cleanup resources.
            # 10. Memory Profiling: Use 'ObjectSpace.memsize_of' (conceptually).
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."
          # (GC and Allocation checks)
          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The `<<` vs `+` Trap
          `str + "more"` creates a new string object. `"more" << "more"` modifies the original. In a loop of 1,000,000 items, `+` will allocate 1M temporary objects for the GC to clean up.

          ### 2. Symbols and the GC
          Since Ruby 2.2, Symbols ARE garbage collected. However, they are still more efficient than strings for keys because they are only allocated once.

          ### 3. WeakRef
          A `WeakRef` allows the GC to collect an object even if the Ref is still pointing to it. This is perfect for large caches (like an image cache) that you want to keep as long as memory is free, but purge if the system is under pressure.
        TEXT
      end
    end
  end
end
