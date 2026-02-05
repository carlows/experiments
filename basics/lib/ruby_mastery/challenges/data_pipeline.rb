require_relative '../challenge'

module RubyMastery
  module Challenges
    class DataPipeline < Challenge
      def initialize
        super('The Data Pipeline (Enumerables)', '04_data_pipeline.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 4: THE DATA PIPELINE
          # ------------------------
          # You are building a log analyzer. The logs are huge (simulated here).
          # You need to process them efficiently without loading everything into memory.
          #
          # Requirements:
          # 1. Use 'lazy' to process the stream of logs.
          # 2. Filter logs that contain "ERROR".
          # 3. Use 'with_index' to tag each error with its original line number (1-based).
          # 4. Use 'reduce' (or 'inject') to count the frequency of different error types.
          #    Error types are the word immediately following "ERROR: ".
          #    e.g. "ERROR: Database connection failed" -> type is "Database"

          class LogAnalyzer
            def initialize(logs_enumerator)
              @logs = logs_enumerator
            end

            def analyze
              # TODO: Implement the pipeline
              # Result should be a Hash like: { "Database" => 2, "Network" => 1 }
            end
          end

          # --- TEST SUITE ---
          raw_logs = [
            "INFO: System started",
            "ERROR: Database connection failed",
            "INFO: User logged in",
            "ERROR: Network timeout",
            "ERROR: Database disk full",
            "INFO: Backup complete"
          ].to_enum

          analyzer = LogAnalyzer.new(raw_logs)
          results = analyzer.analyze

          raise "Analysis failed: Expected Hash" unless results.is_a?(Hash)
          raise "Analysis failed: Expected 2 Database errors" unless results["Database"] == 2
          raise "Analysis failed: Expected 1 Network error" unless results["Network"] == 1

          # Challenge: Line numbers
          # We want to ensure you used with_index correctly.#{' '}
          # Modify your analyze method to also print the line numbers of errors#{' '}
          # (stdout is not checked, but it's good practice).

          puts "✅ Data Pipeline analysis passed"
          puts "✨ KATA COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. The Power of `lazy`
          *Effective Ruby Item 9* - Use `lazy` enumerators to avoid creating large intermediate arrays. When you chain methods like `map` and `select` on a standard array, Ruby creates a new array at every step. `lazy` creates a pipeline where each element flows through all steps before the next element is even touched. This is essential for processing large files or infinite streams.

          ### 2. `with_index` and the Enumerator Chain
          Many people think `with_index` only belongs to `each`. In reality, most Enumerable methods return an `Enumerator` if no block is given. This allows you to chain `with_index` onto anything:#{' '}
          `@logs.lazy.select { ... }.with_index(1).map { ... }`
          The `(1)` argument tells it to start counting at 1 instead of 0.

          ### 3. `reduce` (The Swiss Army Knife)
          `reduce` (also known as `inject`) is the most powerful Enumerable method. It allows you to transform a collection into a single value (like a Hash of counts, a sum, or even a complex object).#{' '}
          *Expert Tip:* Always provide an initial value to `reduce` (e.g., `reduce({})`) to avoid the first element being used as the initial accumulator, which can cause type errors.

          ### 4. `chunk` and `slice_when` (Advanced Filtering)
          While not used in this specific solution, expert Rubyists use `chunk` to group consecutive elements and `slice_when` to split a collection based on a transition in logic. These are much cleaner than manual state tracking with `each`.
        TEXT
      end
    end
  end
end
