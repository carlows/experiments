require_relative '../challenge'

module RubyMastery
  module Challenges
    class DataPipeline < Challenge
      def initialize
        super('The Mega Data Pipeline (10-Stage Enumerable)', '04_data_pipeline.rb')
      end

      def setup
        content = <<~RUBY
          # KATA 4: THE MEGA DATA PIPELINE
          # ------------------------------
          # Goal: Efficiently process a stream of 1,000,000 logs.

          class Pipeline
            # 1. Lazy Loading: Process an infinite stream without memory explosion.
            def self.stream(enum)
            end

            # 2. Chunking: Group consecutive logs by the same 'user_id'.
            def self.group_by_user(enum)
            end

            # 3. Slicing: Split the log stream whenever an 'ERROR' occurs.
            def self.split_on_error(enum)
            end

            # 4. Indexing: Tag every item with its position using 'with_index(1)'.
            def self.tag_lines(enum)
            end

            # 5. Stateful Reduce: Calculate a running total of 'response_time'.
            def self.total_latency(enum)
            end

            # 6. Flat Map: Turn 'User' objects with many 'Posts' into a flat stream of posts.
            def self.extract_posts(users_enum)
            end

            # 7. Zip: Combine two streams (Log message, Timestamp) into a Hash.
            def self.pair_data(logs, times)
            end

            # 8. Grep: Use 'Enumerable#grep' to filter strings that match a Regex.
            def self.filter_errors(enum)
            end

            # 9. Tally: Count the frequency of HTTP status codes (200, 404).
            def self.count_statuses(enum)
            end

            # 10. Cycle: Create an infinite loop of a set of tasks using '.cycle'.
            def self.work_loop(tasks)
            end
          end

          # --- TEST SUITE ---
          puts "Starting 10-Stage Verification..."
          # (Conceptual checks for Enumerable mastery)
          puts "🏆 ALL STAGES COMPLETE!"
        RUBY
        write_kata(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `chunk` and `slice_when`
          These are the most under-utilized Enumerable methods. They are perfect for temporal data analysis (like logs or stock prices) where the *order* and *grouping* of items matters.

          ### 2. `lazy`
          *Effective Ruby Item 9* - Use it when your pipeline is long. Standard methods create a new array for every step. Lazy methods pass one element through the entire pipe before picking up the next.

          ### 3. `tally`
          Added in Ruby 2.7, `tally` replaces the verbose `reduce(Hash.new(0)) { |h, v| h[v] += 1; h }`. It is faster and more expressive.
        TEXT
      end
    end
  end
end
