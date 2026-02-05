require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class BatchProcessing < RailsChallenge
      def initialize
        super('The Memory-Safe Batch (Scaling)', '03_batch_processing.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :logs, force: true do |t|
            t.string :message
            t.boolean :processed, default: false
          end
        end
      end

      def seed_data
        # Seeding 5000 rows. In a real app this might be 5,000,000.
        puts 'Seeding 5000 logs...'.colorize(:gray)
        logs = 5000.times.map { { message: 'Log entry', processed: false } }
        Log.insert_all(logs)
      end

      def write_kata_file
        content = <<~RUBY
          class Log < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # You need to update all logs to 'processed: true'.
          # BUT, you must do it in batches of 1000 to avoid loading#{' '}
          # all 5000 objects into memory at once.

          class LogProcessor
            def self.run!
              # TODO: Use a memory-safe batch method (find_each or in_batches)
              # and mark each log as processed.
            end
          end

          # --- TEST SUITE ---
          initial_mem = `ps -o rss= -p \#{Process.pid}`.to_i

          LogProcessor.run!

          final_mem = `ps -o rss= -p \#{Process.pid}`.to_i

          raise "Batch processing failed: Not all logs processed" unless Log.where(processed: false).count == 0
          puts "✅ Batch processing complete"

          # In this small scale, memory won't spike much, but we verify#{' '}
          # that find_each was used by checking for the batch queries in logs.
          # (Conceptual verification)

          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. `all.each` vs `find_each`
          - `User.all.each`: Loads every single record into memory at once as ActiveRecord objects. This will crash your server if you have millions of rows.
          - `find_each`: Fetches records in batches (default 1000) and yields them one by one. This keeps memory usage flat.

          ### 2. `in_batches`
          If you want to operate on the *relation* of a batch (e.g., to run `update_all` on a subset), use `in_batches`. This is even faster because it performs batch SQL updates instead of instantiating Ruby objects.

          ### 3. `find_in_batches`
          Similar to `find_each`, but it yields the entire array of 1000 objects to the block. Useful if you're sending data to an external API that accepts bulk payloads.
        TEXT
      end
    end
  end
end

class Log < ActiveRecord::Base; end
