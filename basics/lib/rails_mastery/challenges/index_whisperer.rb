require_relative '../rails_challenge'

module RailsMastery
  module Challenges
    class IndexWhisperer < RailsChallenge
      def initialize
        super('The Index Whisperer (B-Trees)', '04_index_whisperer.rb')
      end

      def define_schema
        ActiveRecord::Schema.define do
          create_table :orders, force: true do |t|
            t.string :status
            t.datetime :placed_at
            t.integer :customer_id
            t.decimal :total
          end
          # Intentionally missing indexes
        end
      end

      def seed_data
        puts 'Seeding 10,000 orders...'.colorize(:gray)
        statuses = %w[pending shipped cancelled delivered]
        orders = 10_000.times.map do
          {
            status: statuses.sample,
            placed_at: Faker::Time.backward(days: 30),
            customer_id: rand(1..1000),
            total: rand(10.0..500.0)
          }
        end
        Order.insert_all(orders)
      end

      def write_kata_file
        content = <<~RUBY
          class Order < ActiveRecord::Base; end

          # --- YOUR TASK ---
          # 1. Look at the query below.#{' '}
          # 2. It is currently slow because it performs a "Sequential Scan".
          # 3. Add the correct index(es) to make it an "Index Scan".
          #
          # Query: Order.where(status: 'pending').order(placed_at: :desc)

          # --- SOLUTION ---
          # Add your migration-like code here:
          # ActiveRecord::Base.connection.add_index :orders, [...]

          # --- TEST SUITE ---
          query = "SELECT * FROM orders WHERE status = 'pending' ORDER BY placed_at DESC"
          explain = ActiveRecord::Base.connection.execute("EXPLAIN \#{query}").map { |row| row.values.join }.join("\n")

          puts "EXPLAIN output:"
          puts explain.colorize(:light_black)

          if explain.include?("Index Scan") || explain.include?("Index Only Scan") || explain.include?("Bitmap Index Scan")
            puts "✅ Index detected!"
          else
            raise "Performance Bug: Query is using a Sequential Scan. Add an index!"
          end

          puts "✨ KATA COMPLETE!"
        RUBY
        write_file(content)
      end

      def debrief
        super
        puts <<~TEXT
          ### 1. Sequential Scan vs Index Scan
          A "Seq Scan" means Postgres has to read every single row on disk to find your data. An "Index Scan" uses a B-Tree to find exactly what it needs in logarithmic time.

          ### 2. Composite Indexes
          When you have a `WHERE` and an `ORDER BY`, a single-column index on `status` might not be enough. A **composite index** on `(status, placed_at DESC)` allows Postgres to find the pending orders AND have them already sorted in the correct order on disk.

          ### 3. Column Order Matters
          *High Performance PostgreSQL Rule:* In a composite index, put the columns with the highest selectivity (most unique values) or the ones used in equality filters (`=`) first, and range filters (`>`, `<`) or sorts last.
        TEXT
      end
    end
  end
end

class Order < ActiveRecord::Base; end
