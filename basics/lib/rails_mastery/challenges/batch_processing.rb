require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class BatchProcessing < RailsChallenge
      def initialize
        super('The Memory-Safe Batch (10-Stage Mastery)', '03_batch_processing.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :logs, force: true do |t|
            t.string :message
            t.boolean :processed, default: false
            t.integer :severity, default: 0
            t.datetime :created_at
          end
        end
      end

      def seed_data
        puts 'Seeding 5000 logs...'.colorize(:gray)
        logs = 5000.times.map do |i|
          { message: "Log \#{i}", processed: false, severity: rand(0..3), created_at: Time.now }
        end
        Log.insert_all(logs)
      end

      def write_kata_file
        content = <<~RUBY
          class Log < ActiveRecord::Base; end

          # --- YOUR MISSION ---
          # Master large-scale data processing without crashing the server.

          class LogProcessor
            # 1. Basic: Process all logs in batches of 1000 using 'find_each'
            def self.process_all
            end

            # 2. Relation Batching: Mark all logs as processed in batches of 500 using 'in_batches'
            # Hint: Use update_all on the batch relation for speed.
            def self.bulk_mark_processed
            end

            # 3. Custom Batch Size: Use 'find_in_batches' to process logs in groups of 100
            def self.small_batches
            end

            # 4. Filtered Batching: Process only 'severity > 2' logs in batches
            def self.process_critical
            end

            # 5. Reverse Batching: Does find_each support reverse order?#{' '}
            # (Answer: Not natively by ID. How would you do it manually or for another column?)
            # Requirement: Process logs from NEWEST to OLDEST in batches of 500.
            def self.process_reverse
            end

            # 6. Memory Limit: Implement a loop that stops if RSS memory exceeds a certain limit
            def self.safe_loop
            end

            # 7. Throttling: Pause for 0.1 seconds between batches to give the DB a breather
            def self.throttled_process
            end

            # 8. Deletion Batching: Delete logs older than 1 year in batches of 1000
            # (Prevents long-held table locks)
            def self.bulk_delete_old
            end

            # 9. Plucking in Batches: Fetch only the IDs of all logs without loading objects
            def self.pluck_all_ids
            end

            # 10. Parallel Batching Concept: Divide the logs into 4 "buckets" by ID#{' '}
            # and return the relation for the 1st bucket.
            def self.get_bucket(bucket_num, total_buckets)
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

          # 1. find_each
          verify_stage("Stage 1 (find_each)") do
            Log.update_all(processed: false)
            LogProcessor.process_all
            raise "Not all logs processed" unless Log.where(processed: false).count == 0
          end

          # 2. in_batches
          verify_stage("Stage 2 (in_batches)") do
            Log.update_all(processed: false)
            LogProcessor.bulk_mark_processed
            raise "Batch mark failed" unless Log.where(processed: false).count == 0
          end

          # 3. find_in_batches
          verify_stage("Stage 3 (find_in_batches)") do
            LogProcessor.small_batches
            # Conceptual
          end

          # 4. Filtered
          verify_stage("Stage 4 (Filtered Batching)") do
            LogProcessor.process_critical
          end

          # 8. Delete
          verify_stage("Stage 8 (Batch Deletion)") do
            Log.create!(created_at: 2.years.ago)
            LogProcessor.bulk_delete_old
            raise "Old logs still exist" if Log.where("created_at < ?", 1.year.ago).any?
          end

          # 9. Pluck
          verify_stage("Stage 9 (Plucking)") do
            ids = LogProcessor.pluck_all_ids
            raise "Expected Array of IDs" unless ids.is_a?(Array) && ids.size >= 5000
          end

          if @stages_passed >= 6 # Allowing some flexibility for conceptual ones
            puts "\n🏆 ALL STAGES COMPLETE! You are a Batch Processing Master."
          else
            puts "\n❌ You passed \#{@stages_passed} stages. Keep going!"
            exit 1
          end
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `find_each` vs `find_in_batches`
          `find_each` yields individual records, while `find_in_batches` yields an array of records. Use the latter if you need to perform bulk operations (like sending an email to 1000 people at once).

          ### 2. `in_batches`
          This is the fastest way to perform batch updates. Instead of instantiating 1000 Ruby objects, it yields a **Relation** representing that batch. You can then call `update_all` or `delete_all` on that relation, keeping the entire operation inside the database.

          ### 3. Order Restrictions
          *Expert Gotcha:* `find_each` and `in_batches` **force** an order by primary key. You cannot use `.order(:name).find_each`. If you need a specific order, you have to implement your own batching logic using `limit` and `offset` (which is dangerous for moving targets) or use a "Keyset Pagination" strategy.

          ### 4. Database Locks
          Deleting millions of rows in one transaction (`delete_all`) will lock the table for a long time, potentially causing a downtime. Batching deletions (`in_batches.delete_all`) allows other transactions to sneak in between batches, keeping the app responsive.
        TEXT
      end
    end
  end
end

class Log < ActiveRecord::Base; end
