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

          # --- TEST SUITE (DO NOT MODIFY) ---
          @stages_passed = 0
          def verify_stage(name)
            yield
            puts "✅ \#{name} Passed"
            @stages_passed += 1
          rescue => e
            puts "❌ \#{name} Failed: \#{e.message}"
          end

          puts "Starting 10-Stage Verification..."

          # 1. Lazy
          verify_stage("Stage 1 (Lazy Loading)") do
            infinite = (1..Float::INFINITY).to_enum
            res = Pipeline.stream(infinite)
            raise "Must return an Enumerator::Lazy" unless res.is_a?(Enumerator::Lazy)
            raise "Should be able to take 5" unless res.take(5).to_a == [1, 2, 3, 4, 5]
          end

          # 2. Chunking
          verify_stage("Stage 2 (Chunking)") do
            logs = [{u: 1, m: "a"}, {u: 1, m: "b"}, {u: 2, m: "c"}]
            res = Pipeline.group_by_user(logs.to_enum).to_a
            raise "Chunking failed" unless res.size == 2 && res[0][0] == 1
          end

          # 3. Slicing
          verify_stage("Stage 3 (Slicing)") do
            logs = ["INFO", "ERROR", "INFO", "INFO", "ERROR"]
            res = Pipeline.split_on_error(logs.to_enum).to_a
            raise "Slicing failed" unless res.size >= 2
          end

          # 4. Indexing
          verify_stage("Stage 4 (Indexing)") do
            res = Pipeline.tag_lines(["a", "b"].to_enum).to_a
            raise "Indexing failed" unless res == [["a", 1], ["b", 2]]
          end

          # 5. Reduce
          verify_stage("Stage 5 (Stateful Reduce)") do
            times = [10, 20, 30]
            res = Pipeline.total_latency(times.to_enum)
            raise "Reduce failed" unless res == 60
          end

          # 6. Flat Map
          verify_stage("Stage 6 (Flat Map)") do
            User = Struct.new(:posts)
            users = [User.new([1, 2]), User.new([3])]
            res = Pipeline.extract_posts(users.to_enum).to_a
            raise "Flat map failed" unless res == [1, 2, 3]
          end

          # 7. Zip
          verify_stage("Stage 7 (Zip)") do
            res = Pipeline.pair_data(["a", "b"], [1, 2])
            raise "Zip failed" unless res == {"a" => 1, "b" => 2}
          end

          # 8. Grep
          verify_stage("Stage 8 (Grep)") do
            res = Pipeline.filter_errors(["INFO: x", "ERROR: y"].to_enum).to_a
            raise "Grep failed" unless res == ["ERROR: y"]
          end

          # 9. Tally
          verify_stage("Stage 9 (Tally)") do
            res = Pipeline.count_statuses([200, 200, 404].to_enum)
            raise "Tally failed" unless res == {200 => 2, 404 => 1}
          end

          # 10. Cycle
          verify_stage("Stage 10 (Cycle)") do
            res = Pipeline.work_loop([:a, :b]).take(4).to_a
            raise "Cycle failed" unless res == [:a, :b, :a, :b]
          end

          if @stages_passed == 10
            puts "\n🏆 ALL STAGES COMPLETE! You are an Enumerable Master."
          else
            puts "\n❌ You passed \#{@stages_passed}/10 stages. Keep going!"
            exit 1
          end
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
